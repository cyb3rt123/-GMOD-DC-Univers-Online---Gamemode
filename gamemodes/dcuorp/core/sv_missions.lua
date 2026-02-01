--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Missions (Server)
    Gestion serveur des missions et événements
═══════════════════════════════════════════════════════════════════════
--]]

if CLIENT then return end

DCUO.Missions.Active = DCUO.Missions.Active or {}
DCUO.Missions.Players = DCUO.Missions.Players or {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    DÉMARRER UNE MISSION                           ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Missions.Start(missionID, initiator, position)
    local mission = DCUO.Missions.Get(missionID)
    if not mission then
        DCUO.Log("Mission " .. missionID .. " not found", "ERROR")
        return false
    end
    
    -- Créer l'instance de mission
    local instance = {
        id = missionID,
        data = table.Copy(mission),
        startTime = CurTime(),
        endTime = CurTime() + mission.duration,
        position = position or Vector(0, 0, 0),
        participants = {},
        completed = false,
        spawned = {},
        dialogues = {},  -- Dialogues envoyés
    }
    
    -- Copier les objectifs
    instance.data.objectives = table.Copy(mission.objectives)
    
    -- Générer un ID unique pour cette instance
    instance.instanceID = missionID .. "_" .. os.time() .. "_" .. math.random(1000, 9999)
    
    -- Ajouter aux missions actives
    DCUO.Missions.Active[instance.instanceID] = instance
    
    -- Ajouter l'initiateur
    if IsValid(initiator) then
        DCUO.Missions.AddPlayer(instance.instanceID, initiator)
    end
    
    -- Dialogue de début de mission
    DCUO.Missions.SendDialogue(instance, "mission_start", "Coordinateur", mission.description or "Nouvelle mission disponible!")
    
    -- Activer la musique de combat pour tous les participants
    for _, ply in ipairs(instance.participants) do
        if IsValid(ply) then
            net.Start("DCUO:ChangeMusicMode")
                net.WriteString("combat")
            net.Send(ply)
        end
    end
    
    -- Spawner les entités nécessaires
    DCUO.Missions.SpawnEntities(instance)
    
    -- Timer pour l'expiration de la mission
    local timerName = "DCUO_Mission_" .. instance.instanceID
    timer.Create(timerName, mission.duration, 1, function()
        if DCUO.Missions.Active[instance.instanceID] and not instance.completed then
            DCUO.Missions.Fail(instance.instanceID, "Temps écoulé")
        end
    end)
    
    -- Notification
    local minutes = math.floor(mission.duration / 60)
    local seconds = mission.duration % 60
    local timeText = minutes > 0 and (minutes .. "min" .. (seconds > 0 and (" " .. seconds .. "s") or "")) or (seconds .. "s")
    DCUO.NotifyAll("📋 Nouvelle mission : " .. mission.name .. " (" .. timeText .. ")", DCUO.Colors.Electric)
    
    DCUO.Log("Mission started: " .. missionID .. " (Instance: " .. instance.instanceID .. ", Duration: " .. mission.duration .. "s)", "SUCCESS")
    
    return instance.instanceID
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    GESTION DES JOUEURS                            ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Missions.AddPlayer(instanceID, ply)
    if not IsValid(ply) then return false end
    
    local instance = DCUO.Missions.Active[instanceID]
    if not instance then return false end
    
    -- Vérifier si déjà participant
    if table.HasValue(instance.participants, ply) then
        return false
    end
    
    -- Vérifier le nombre maximum de joueurs
    if #instance.participants >= instance.data.maxPlayers then
        DCUO.Notify(ply, "Cette mission est complète", DCUO.Colors.Error)
        return false
    end
    
    -- Ajouter le joueur
    table.insert(instance.participants, ply)
    DCUO.Missions.Players[ply] = instanceID
    
    -- Notification
    DCUO.Notify(ply, "Vous avez rejoint la mission : " .. instance.data.name, DCUO.Colors.Success)
    
    -- Envoyer les données au client pour le HUD
    net.Start("DCUO:MissionUpdate")
        net.WriteString("start")
        local missionData = table.Copy(instance.data)
        missionData.endTime = instance.endTime
        net.WriteTable(missionData)
        net.WriteVector(instance.position)
    net.Send(ply)
    
    return true
end

function DCUO.Missions.RemovePlayer(instanceID, ply)
    if not IsValid(ply) then return end
    
    local instance = DCUO.Missions.Active[instanceID]
    if not instance then return end
    
    table.RemoveByValue(instance.participants, ply)
    DCUO.Missions.Players[ply] = nil
    
    DCUO.Notify(ply, "Vous avez quitté la mission", DCUO.Colors.Warning)
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    PROGRESSION DES OBJECTIFS                      ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Missions.UpdateObjective(instanceID, objectiveIndex, increment)
    local instance = DCUO.Missions.Active[instanceID]
    if not instance then return end
    
    local objective = instance.data.objectives[objectiveIndex]
    if not objective then return end
    
    -- Incrémenter
    objective.current = math.min(objective.current + (increment or 1), objective.count)
    
    -- Vérifier si l'objectif est complété
    if objective.current >= objective.count then
        -- Notifier tous les participants
        for _, ply in ipairs(instance.participants) do
            if IsValid(ply) then
                DCUO.Notify(ply, "Objectif complété: " .. objective.description, DCUO.Colors.Success)
            end
        end
    end
    
    -- Envoyer la mise à jour aux clients
    for _, ply in ipairs(instance.participants) do
        if IsValid(ply) then
            net.Start("DCUO:MissionUpdate")
                net.WriteString("objective")
                net.WriteTable(instance.data.objectives)
            net.Send(ply)
        end
    end
    
    -- Vérifier si tous les objectifs sont complétés
    DCUO.Missions.CheckCompletion(instanceID)
end

function DCUO.Missions.CheckCompletion(instanceID)
    local instance = DCUO.Missions.Active[instanceID]
    if not instance or instance.completed then return end
    
    -- Vérifier tous les objectifs
    local allCompleted = true
    for _, objective in ipairs(instance.data.objectives) do
        if objective.current < objective.count then
            allCompleted = false
            break
        end
    end
    
    if allCompleted then
        DCUO.Missions.Complete(instanceID)
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    COMPLÉTION DE MISSION                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    ÉCHEC DE MISSION                               ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Missions.Fail(instanceID, reason)
    local instance = DCUO.Missions.Active[instanceID]
    if not instance or instance.completed then return end
    
    instance.completed = true
    reason = reason or "Mission échouée"
    
    -- Notifier les participants
    for _, ply in ipairs(instance.participants) do
        if IsValid(ply) then
            DCUO.Notify(ply, "❌ Mission échouée : " .. reason, DCUO.Colors.Error)
            
            -- Retirer le joueur de la mission
            DCUO.Missions.Players[ply] = nil
            
            -- Notifier le client
            net.Start("DCUO:MissionUpdate")
                net.WriteString("failed")
            net.Send(ply)
        end
    end
    
    -- Notification globale
    DCUO.NotifyAll("❌ Mission échouée : " .. instance.data.name .. " (" .. reason .. ")", DCUO.Colors.Error)
    
    -- Supprimer le timer
    timer.Remove("DCUO_Mission_" .. instanceID)
    
    -- Nettoyer après 3 secondes
    timer.Simple(3, function()
        DCUO.Missions.Cleanup(instanceID)
    end)
end

function DCUO.Missions.Complete(instanceID)
    local instance = DCUO.Missions.Active[instanceID]
    if not instance or instance.completed then return end
    
    instance.completed = true
    
    -- Donner les récompenses
    for _, ply in ipairs(instance.participants) do
        if IsValid(ply) then
            -- XP
            if instance.data.rewards.xp then
                DCUO.XP.Give(ply, instance.data.rewards.xp, "Mission: " .. instance.data.name)
            end
            
            -- Items (à implémenter si vous avez un système d'inventaire)
            if instance.data.rewards.items then
                for _, item in ipairs(instance.data.rewards.items) do
                    -- Donner l'item
                end
            end
            
            -- Marquer la mission comme complétée
            if not ply.DCUOData.missions then
                ply.DCUOData.missions = {}
            end
            table.insert(ply.DCUOData.missions, instance.id)
            DCUO.Database.SaveMissionCompleted(ply, instance.id)
            
            -- Notification
            local msg = string.format(DCUO.Config.Messages.MissionComplete, instance.data.rewards.xp or 0)
            DCUO.Notify(ply, msg, DCUO.Colors.Success)
            
            -- Notifier le client pour mettre à jour le HUD
            net.Start("DCUO:MissionUpdate")
                net.WriteString("complete")
            net.Send(ply)
            
            -- Effets visuels
            local effectdata = EffectData()
            effectdata:SetOrigin(ply:GetPos())
            util.Effect("dcuo_mission_complete", effectdata, true, true)
            
            -- Retour à la musique normale
            net.Start("DCUO:ChangeMusicMode")
                net.WriteString("normal")
            net.Send(ply)
        end
    end
    
    -- Dialogue de succès
    DCUO.Missions.SendDialogue(instance, "mission_complete", "Coordinateur", "Mission accomplie ! " .. instance.data.name .. " terminée avec succès !")
    
    -- Notification globale
    DCUO.NotifyAll("✓ Mission complétée : " .. instance.data.name, DCUO.Colors.Success)
    
    -- Supprimer le timer
    timer.Remove("DCUO_Mission_" .. instanceID)
    
    -- Nettoyer après 5 secondes
    timer.Simple(5, function()
        DCUO.Missions.Cleanup(instanceID)
    end)
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    ÉCHEC DE MISSION                               ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Missions.Fail(instanceID, reason)
    local instance = DCUO.Missions.Active[instanceID]
    if not instance then return end
    
    -- Dialogue d'échec
    DCUO.Missions.SendDialogue(instance, "mission_fail", "Coordinateur", "Mission échouée... " .. (reason or "Temps écoulé"))
    
    -- Notifier les participants
    for _, ply in ipairs(instance.participants) do
        if IsValid(ply) then
            DCUO.Notify(ply, "Mission échouée : " .. (reason or "Temps écoulé"), DCUO.Colors.Error)
            
            -- Notifier le client pour mettre à jour le HUD
            net.Start("DCUO:MissionUpdate")
                net.WriteString("failed")
            net.Send(ply)
            
            -- Retour à la musique normale
            net.Start("DCUO:ChangeMusicMode")
                net.WriteString("normal")
            net.Send(ply)
        end
    end
    
    DCUO.NotifyAll("Mission échouée : " .. instance.data.name, DCUO.Colors.Error)
    
    -- Nettoyer
    DCUO.Missions.Cleanup(instanceID)
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    NETTOYAGE                                      ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Missions.SendDialogue(instance, dialogueType, speaker, text)
    if not instance then return end

    -- IMPORTANT: net.WriteString exige une string.
    -- On normalise AVANT net.Start pour éviter de laisser un net message "started" en cas d'erreur.
    local safeSpeaker = tostring(speaker or "")
    local safeText = tostring(text or "")
    local safeType = tostring(dialogueType or "")
    local faction = "Neutral"
    if instance.data then
        faction = tostring(instance.data.faction or "Neutral")
    end
    
    -- Envoyer à tous les participants
    for _, ply in ipairs(instance.participants) do
        if IsValid(ply) then
            net.Start("DCUO:MissionDialogue")
                net.WriteString(safeSpeaker)
                net.WriteString(safeText)
                net.WriteString(safeType)
                net.WriteString(faction)
            net.Send(ply)
        end
    end
    
    -- Aussi envoyer aux joueurs proches de la zone (500 unités)
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and not table.HasValue(instance.participants, ply) then
            local dist = ply:GetPos():Distance(instance.position)
            if dist <= 500 then
                net.Start("DCUO:MissionDialogue")
                    net.WriteString(safeSpeaker)
                    net.WriteString(safeText)
                    net.WriteString(safeType)
                    net.WriteString(faction)
                net.Send(ply)
            end
        end
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    NETTOYAGE                                      ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Missions.Cleanup(instanceID)
    local instance = DCUO.Missions.Active[instanceID]
    if not instance then return end
    
    -- Supprimer les entités spawnées
    for _, ent in ipairs(instance.spawned) do
        if IsValid(ent) then
            ent:Remove()
        end
    end
    
    -- Retirer les joueurs
    for _, ply in ipairs(instance.participants) do
        if IsValid(ply) then
            DCUO.Missions.Players[ply] = nil
        end
    end
    
    -- Supprimer l'instance
    DCUO.Missions.Active[instanceID] = nil
    
    DCUO.Log("Mission cleaned up: " .. instanceID, "INFO")
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    SPAWN D'ENTITÉS                                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Missions.SpawnEntities(instance)
    -- Spawner les NPCs/objets selon les objectifs
    local missionLevel = instance.data.levelRequired or 1
    
    DCUO.Log("Spawning entities for mission: " .. instance.id .. " at position: " .. tostring(instance.position), "INFO")
    
    for i, objective in ipairs(instance.data.objectives) do
        DCUO.Log("Processing objective " .. i .. ": type=" .. objective.type .. ", count=" .. objective.count, "INFO")
        
        if objective.type == "kill" and objective.enemyClass then
            -- Spawner des ennemis
            DCUO.Log("Spawning " .. objective.count .. " " .. objective.enemyClass, "INFO")
            for j = 1, objective.count do
                -- Position aléatoire dans le ciel
                local skyPos = instance.position + Vector(math.random(-400, 400), math.random(-400, 400), 300)
                
                -- TRACER VERS LE SOL pour trouver la position réelle
                local trace = util.TraceLine({
                    start = skyPos,
                    endpos = skyPos - Vector(0, 0, 800),
                    mask = MASK_SOLID_BRUSHONLY
                })
                
                local pos = trace.HitPos + Vector(0, 0, 10)  -- 10 unités au-dessus du sol
                
                -- MARKER VISUEL TEMPORAIRE (sprite rouge) pour débugger
                local marker = ents.Create("env_sprite")
                if IsValid(marker) then
                    marker:SetPos(pos + Vector(0, 0, 50))
                    marker:SetKeyValue("model", "sprites/glow01.spr")
                    marker:SetKeyValue("scale", "0.5")
                    marker:SetKeyValue("rendercolor", "255 0 0")
                    marker:SetKeyValue("rendermode", "5")
                    marker:Spawn()
                    timer.Simple(60, function() if IsValid(marker) then marker:Remove() end end)
                end
                
                local npc = ents.Create(objective.enemyClass)
                if IsValid(npc) then
                    npc:SetPos(pos)
                    npc:Spawn()
                    npc:Activate()
                    npc:DropToFloor()  -- Force le NPC à coller au sol
                    npc.DCUOMissionID = instance.instanceID
                    npc.DCUOObjectiveIndex = i
                    
                    DCUO.Log("✓ Spawned NPC #" .. j .. " at " .. tostring(pos) .. " (Ground found: " .. tostring(trace.Hit) .. ")", "SUCCESS")
                    
                    -- Définir le niveau du NPC selon la mission
                    npc.DCUOLevel = missionLevel + math.random(-2, 2)  -- Variation de ±2 niveaux
                    npc.DCUOLevel = math.max(1, npc.DCUOLevel)  -- Minimum niveau 1
                    
                    -- Scaler la santé selon le niveau
                    local baseHealth = npc:GetMaxHealth()
                    local newHealth = baseHealth * (1 + (npc.DCUOLevel * 0.15))  -- +15% par niveau
                    npc:SetMaxHealth(newHealth)
                    npc:SetHealth(newHealth)
                    
                    -- Nom pour l'affichage
                    npc.DCUOName = objective.enemyName or "Ennemi"
                    
                    -- ═══ CONFIGURATION D'AGRESSIVITÉ ═══
                    -- Définir comme Boss si marqué dans les objectifs
                    if objective.isBoss then
                        npc.DCUIsBoss = true
                        npc.DCUOLevel = missionLevel + math.random(3, 5)  -- Boss plus fort
                        npc:SetMaxHealth(newHealth * 2.5)  -- 250% de santé
                        npc:SetHealth(newHealth * 2.5)
                        npc.DCUOName = "[BOSS] " .. npc.DCUOName
                    end
                    
                    -- Configurer l'agressivité selon le type
                    timer.Simple(0.1, function()
                        if not IsValid(npc) then return end
                        
                        -- Régler la compétence de tir
                        npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
                        
                        -- Agressivité élevée
                        npc:SetSchedule(SCHED_COMBAT_FACE)
                        
                        -- Capacités selon si c'est un boss
                        if npc.DCUIsBoss then
                            -- Boss: Très agressif, tire souvent, réagit vite
                            npc:CapabilitiesAdd(CAP_MOVE_GROUND)
                            npc:CapabilitiesAdd(CAP_MOVE_JUMP)
                            npc:CapabilitiesAdd(CAP_USE)
                            npc:CapabilitiesAdd(CAP_WEAPON_RANGE_ATTACK1)
                            npc:CapabilitiesAdd(CAP_WEAPON_MELEE_ATTACK1)
                            npc:CapabilitiesAdd(CAP_ANIMATEDFACE)
                            npc:CapabilitiesAdd(CAP_TURN_HEAD)
                            npc:CapabilitiesAdd(CAP_DUCK)
                            
                            -- Réduire le délai entre les tirs (plus agressif)
                            npc:SetKeyValue("additionalequipment", "weapon_ar2")
                        else
                            -- NPC standard: Agressif mais moins que les boss
                            npc:CapabilitiesAdd(CAP_MOVE_GROUND)
                            npc:CapabilitiesAdd(CAP_MOVE_JUMP)
                            npc:CapabilitiesAdd(CAP_WEAPON_RANGE_ATTACK1)
                            npc:CapabilitiesAdd(CAP_WEAPON_MELEE_ATTACK1)
                            npc:CapabilitiesAdd(CAP_ANIMATEDFACE)
                        end
                        
                        -- Forcer l'attaque des joueurs proches
                        npc:AddRelationship("player D_HT 99")
                    end)
                    
                    table.insert(instance.spawned, npc)
                else
                    DCUO.Log("Failed to create NPC: " .. objective.enemyClass, "ERROR")
                end
            end
            DCUO.Log("Total NPCs spawned: " .. #instance.spawned, "SUCCESS")
            
        elseif objective.type == "rescue" then
            -- Spawner des civils à sauver
            DCUO.Log("Spawning " .. objective.count .. " civilians to rescue", "INFO")
            for j = 1, objective.count do
                -- Position aléatoire dans le ciel
                local skyPos = instance.position + Vector(math.random(-400, 400), math.random(-400, 400), 300)
                
                -- TRACER VERS LE SOL
                local trace = util.TraceLine({
                    start = skyPos,
                    endpos = skyPos - Vector(0, 0, 800),
                    mask = MASK_SOLID_BRUSHONLY
                })
                
                local pos = trace.HitPos + Vector(0, 0, 10)
                
                -- MARKER VISUEL (sprite bleu pour les civils)
                local marker = ents.Create("env_sprite")
                if IsValid(marker) then
                    marker:SetPos(pos + Vector(0, 0, 50))
                    marker:SetKeyValue("model", "sprites/glow01.spr")
                    marker:SetKeyValue("scale", "0.5")
                    marker:SetKeyValue("rendercolor", "0 150 255")
                    marker:SetKeyValue("rendermode", "5")
                    marker:Spawn()
                    timer.Simple(60, function() if IsValid(marker) then marker:Remove() end end)
                end
                
                -- Spawner civil (npc_citizen)
                local civilian = ents.Create("npc_citizen")
                if IsValid(civilian) then
                    civilian:SetPos(pos)
                    civilian:Spawn()
                    civilian:Activate()
                    civilian:DropToFloor()
                    civilian.DCUOMissionID = instance.instanceID
                    civilian.DCUOObjectiveIndex = i
                    civilian.DCUOCivilian = true
                    civilian.DCUORescued = false
                    
                    -- Nom du civil
                    civilian:SetName("Civil à sauver")
                    
                    -- Relations amicales
                    civilian:AddRelationship("player D_LI 99")
                    
                    -- Animation de peur
                    timer.Simple(0.2, function()
                        if IsValid(civilian) then
                            civilian:SetSchedule(SCHED_COWER)
                        end
                    end)
                    
                    table.insert(instance.spawned, civilian)
                    DCUO.Log("[V] Spawned civilian #" .. j .. " at " .. tostring(pos), "SUCCESS")
                end
            end
            DCUO.Log("Total civilians spawned: " .. objective.count, "SUCCESS")
            
        elseif objective.type == "collect" and objective.itemClass then
            -- Spawner des objets à collecter
            for j = 1, objective.count do
                local pos = instance.position + Vector(math.random(-500, 500), math.random(-500, 500), 10)
                local item = ents.Create("prop_physics")
                if IsValid(item) then
                    item:SetPos(pos)
                    item:SetModel("models/props_junk/PopCan01a.mdl")  -- Model par défaut
                    item:Spawn()
                    item.DCUOMissionID = instance.instanceID
                    item.DCUOObjectiveIndex = i
                    item.DCUOCollectable = true
                    table.insert(instance.spawned, item)
                end
            end
        end
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    HOOKS                                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Quand un NPC est tué
hook.Add("OnNPCKilled", "DCUO:MissionNPCKilled", function(npc, attacker, inflictor)
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if not npc.DCUOMissionID then return end
    
    local instanceID = npc.DCUOMissionID
    local instance = DCUO.Missions.Active[instanceID]
    
    if instance and table.HasValue(instance.participants, attacker) then
        -- Dialogue de progression
        if npc.DCUIsBoss then
            DCUO.Missions.SendDialogue(instance, "mission_progress", "Coordinateur", "Boss éliminé ! Excellent travail !")
        else
            local remaining = 0
            if instance.data.objectives[npc.DCUOObjectiveIndex] then
                remaining = (instance.data.objectives[npc.DCUOObjectiveIndex].count or 0) - (instance.data.objectives[npc.DCUOObjectiveIndex].current or 0) - 1
            end
            
            if remaining > 0 and remaining % 3 == 0 then  -- Message tous les 3 ennemis
                DCUO.Missions.SendDialogue(instance, "mission_progress", "Coordinateur", "Bon travail ! Il en reste " .. remaining .. ".")
            elseif remaining == 1 then
                DCUO.Missions.SendDialogue(instance, "mission_progress", "Coordinateur", "Plus qu'un seul ennemi !")
            end
        end
        
        DCUO.Missions.UpdateObjective(instanceID, npc.DCUOObjectiveIndex, 1)
    end
end)

-- Quand un joueur touche une entité
hook.Add("PlayerUse", "DCUO:MissionCollect", function(ply, ent)
    if not IsValid(ent) then return end
    
    -- ═══ COLLECTER UN OBJET ═══
    if ent.DCUOCollectable and ent.DCUOMissionID then
        local instanceID = ent.DCUOMissionID
        local instance = DCUO.Missions.Active[instanceID]
        
        if instance and table.HasValue(instance.participants, ply) then
            DCUO.Missions.UpdateObjective(instanceID, ent.DCUOObjectiveIndex, 1)
            ent:Remove()
            return false
        end
    end
    
    -- ═══ SAUVER UN CIVIL ═══
    if ent.DCUOCivilian and ent.DCUOMissionID and not ent.DCUORescued then
        local instanceID = ent.DCUOMissionID
        local instance = DCUO.Missions.Active[instanceID]
        
        if instance and table.HasValue(instance.participants, ply) then
            ent.DCUORescued = true
            
            -- Animation de joie
            ent:SetSchedule(SCHED_IDLE_STAND)
            
            -- Faire disparaître le civil
            timer.Simple(1, function()
                if IsValid(ent) then
                    local effectData = EffectData()
                    effectData:SetOrigin(ent:GetPos())
                    util.Effect("selection_ring", effectData)
                    ent:Remove()
                end
            end)
            
            DCUO.Missions.UpdateObjective(instanceID, ent.DCUOObjectiveIndex, 1)
            DCUO.Notify(ply, "[V] Civil sauvé !", Color(0, 255, 0))
            return false
        end
    end
end)

-- Vérifier le temps des missions
timer.Create("DCUO:MissionTimer", 1, 0, function()
    for instanceID, instance in pairs(DCUO.Missions.Active) do
        if CurTime() >= instance.endTime and not instance.completed then
            DCUO.Missions.Fail(instanceID, "Temps écoulé")
        end
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    ÉVÉNEMENTS ALÉATOIRES                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Missions.SpawnRandomEvent()
    -- Récupérer toutes les missions
    local missions = {}
    for id, mission in pairs(DCUO.Missions.List) do
        table.insert(missions, id)
    end
    
    if #missions == 0 then return end
    
    -- Choisir une mission aléatoire
    local missionID = table.Random(missions)
    
    -- Position aléatoire sur la map
    local spawnPos = Vector(0, 0, 100)  -- À adapter selon votre map
    
    -- Lancer la mission
    local instanceID = DCUO.Missions.Start(missionID, nil, spawnPos)
    
    if instanceID then
        DCUO.Log("Random event spawned: " .. missionID, "INFO")
    end
end

-- Timer pour les événements aléatoires
timer.Create("DCUO:RandomEvents", DCUO.Config.Missions.EventSpawnInterval or 300, 0, function()
    -- Vérifier le nombre d'événements actifs
    local activeCount = table.Count(DCUO.Missions.Active)
    local maxActive = DCUO.Config.Missions.MaxActiveEvents or 3
    
    if activeCount < maxActive then
        DCUO.Missions.SpawnRandomEvent()
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    HANDLER RÉSEAU                                 ║
-- ╚═══════════════════════════════════════════════════════════════════╝

net.Receive("DCUO:MissionUpdate", function(len, ply)
    local action = net.ReadString()
    
    if action == "accept" then
        local missionID = net.ReadString()
        local mission = DCUO.Missions.List[missionID]
        
        if not mission then
            DCUO.Notify(ply, "Cette mission n'existe pas", DCUO.Colors.Error)
            return
        end
        
        -- Vérifier le niveau
        local requiredLevel = mission.levelRequired or 1
        if ply.DCUOData and ply.DCUOData.level < requiredLevel then
            DCUO.Notify(ply, "Niveau insuffisant pour cette mission", DCUO.Colors.Error)
            return
        end
        
        -- Vérifier si le joueur est déjà dans une mission
        if DCUO.Missions.Players[ply] then
            DCUO.Notify(ply, "Vous êtes déjà dans une mission", DCUO.Colors.Error)
            return
        end
        
        -- Position de spawn de la mission (près du joueur)
        local spawnPos = ply:GetPos() + ply:GetForward() * 500
        spawnPos.z = spawnPos.z + 50
        
        -- Démarrer la mission
        local instanceID = DCUO.Missions.Start(missionID, ply, spawnPos)
        
        if instanceID then
            DCUO.Notify(ply, "Mission démarrée: " .. mission.name, DCUO.Colors.Success)
        else
            DCUO.Notify(ply, "Impossible de démarrer la mission", DCUO.Colors.Error)
        end
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    COMMANDE /CANCEL                               ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("PlayerSay", "DCUO:MissionCancel", function(ply, text)
    if string.lower(text) == "/cancel" then
        local instanceID = DCUO.Missions.Players[ply]
        
        if not instanceID then
            DCUO.Notify(ply, "Vous n'êtes pas dans une mission", DCUO.Colors.Error)
            return ""
        end
        
        local instance = DCUO.Missions.Active[instanceID]
        if not instance then
            DCUO.Missions.Players[ply] = nil
            DCUO.Notify(ply, "Mission introuvable", DCUO.Colors.Error)
            return ""
        end
        
        -- Retirer le joueur de la mission
        for i, participant in ipairs(instance.participants) do
            if participant == ply then
                table.remove(instance.participants, i)
                break
            end
        end
        
        DCUO.Missions.Players[ply] = nil
        
        -- Notifier
        DCUO.Notify(ply, "Mission annulée", DCUO.Colors.Warning)
        
        -- Notifier le client pour cacher le HUD
        net.Start("DCUO:MissionUpdate")
            net.WriteString("failed")
        net.Send(ply)
        
        -- Si plus de participants, annuler la mission
        if #instance.participants == 0 then
            DCUO.Missions.Fail(instanceID, "Tous les joueurs ont quitté")
        else
            -- Notifier les autres participants
            for _, p in ipairs(instance.participants) do
                if IsValid(p) then
                    DCUO.Notify(p, ply:Nick() .. " a quitté la mission", DCUO.Colors.Warning)
                end
            end
        end
        
        return ""
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    COMMANDES DEBUG                                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Commande pour tester le spawn d'une mission
concommand.Add("dcuo_test_mission_spawn", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    
    local missionID = args[1] or "hero_stop_robbery"
    
    if not DCUO.Missions.List[missionID] then
        DCUO.Notify(ply, "Mission introuvable: " .. missionID, DCUO.Colors.Error)
        return
    end
    
    -- Démarrer la mission au point où le joueur regarde
    local trace = ply:GetEyeTrace()
    local spawnPos = trace.HitPos
    
    DCUO.Missions.Start(missionID, {ply}, spawnPos)
    DCUO.Notify(ply, "Mission de test lancée: " .. missionID, DCUO.Colors.Success)
    
    print("[DCUO TEST] Mission spawn forcé à: " .. tostring(spawnPos))
end)

-- Commande pour lister les missions actives
concommand.Add("dcuo_list_active_missions", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    
    print("═══════════════════════════════════════")
    print("MISSIONS ACTIVES:")
    print("═══════════════════════════════════════")
    
    local count = 0
    for instanceID, instance in pairs(DCUO.Missions.Active) do
        count = count + 1
        print(string.format("[%s] Mission: %s", instanceID, instance.data.name))
        print("  Position: " .. tostring(instance.position))
        print("  Participants: " .. #instance.participants)
        print("  Entités spawnées: " .. #instance.spawned)
        print("  Temps restant: " .. math.Round(instance.endTime - CurTime()) .. "s")
    end
    
    if count == 0 then
        print("Aucune mission active")
    end
    
    print("═══════════════════════════════════════")
end)

DCUO.Log("Missions system (server) loaded", "SUCCESS")

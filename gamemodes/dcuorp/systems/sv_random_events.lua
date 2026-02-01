--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Événements NPCs Aléatoires
    NPCs avec actions scriptées (agressions, vols, etc.)
═══════════════════════════════════════════════════════════════════════
--]]

if CLIENT then return end

DCUO.RandomEvents = DCUO.RandomEvents or {}
DCUO.RandomEvents.Active = {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    TYPES D'ÉVÉNEMENTS                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.RandomEvents.Types = {
    -- Agression
    ["mugging"] = {
        name = "Agression",
        description = "Un criminel agresse un civil",
        xpReward = 100,
        duration = 120,
        
        spawn = function(pos)
            -- Victime
            local victim = ents.Create("npc_citizen")
            victim:SetPos(pos)
            victim:Spawn()
            victim:SetMaxHealth(50)
            victim:SetHealth(50)
            victim.IsEventVictim = true
            
            -- Agresseur
            local attacker = ents.Create("npc_citizen")
            attacker:SetPos(pos + Vector(50, 0, 0))
            attacker:Spawn()
            attacker:Give("weapon_crowbar")
            attacker:SetMaxHealth(100)
            attacker:SetHealth(100)
            attacker.IsEventAttacker = true
            
            -- Le faire attaquer la victime
            timer.Simple(1, function()
                if IsValid(attacker) and IsValid(victim) then
                    attacker:AddEntityRelationship(victim, D_HT, 99)
                    attacker:SetEnemy(victim)
                end
            end)
            
            return {victim = victim, attacker = attacker}
        end,
        
        check = function(eventData)
            -- Vérifier si l'agresseur est mort
            if not IsValid(eventData.attacker) or not eventData.attacker:Alive() then
                return true, "Agresseur neutralisé"
            end
            return false
        end
    },
    
    -- Vol de voiture
    ["carjacking"] = {
        name = "Vol de Véhicule",
        description = "Un voleur tente de voler un véhicule",
        xpReward = 75,
        duration = 90,
        
        spawn = function(pos)
            -- Propriétaire
            local owner = ents.Create("npc_citizen")
            owner:SetPos(pos)
            owner:Spawn()
            owner.IsEventVictim = true
            
            -- Voleur
            local thief = ents.Create("npc_citizen")
            thief:SetPos(pos + Vector(30, 30, 0))
            thief:Spawn()
            thief:Give("weapon_pistol")
            thief.IsEventAttacker = true
            
            return {victim = owner, attacker = thief}
        end,
        
        check = function(eventData)
            if not IsValid(eventData.attacker) or not eventData.attacker:Alive() then
                return true, "Voleur arrêté"
            end
            return false
        end
    },
    
    -- Incendie
    ["fire"] = {
        name = "Incendie",
        description = "Un bâtiment prend feu, des civils sont en danger",
        xpReward = 150,
        duration = 150,
        
        spawn = function(pos)
            -- Plusieurs victimes
            local victims = {}
            for i = 1, 3 do
                local victim = ents.Create("npc_citizen")
                victim:SetPos(pos + Vector(math.random(-50, 50), math.random(-50, 50), 0))
                victim:Spawn()
                victim:Ignite(30)
                victim.IsEventVictim = true
                table.insert(victims, victim)
            end
            
            -- Effet de feu
            local fire = ents.Create("env_fire")
            fire:SetPos(pos)
            fire:SetKeyValue("health", "999")
            fire:SetKeyValue("firesize", "128")
            fire:Spawn()
            
            return {victims = victims, fire = fire}
        end,
        
        check = function(eventData)
            -- Vérifier si toutes les victimes sont sauvées (éteintes)
            local allSaved = true
            for _, victim in ipairs(eventData.victims) do
                if IsValid(victim) and victim:IsOnFire() then
                    allSaved = false
                    break
                end
            end
            return allSaved, "Incendie maîtrisé"
        end
    },
    
    -- Otages
    ["hostage"] = {
        name = "Prise d'Otage",
        description = "Des criminels retiennent des otages",
        xpReward = 200,
        duration = 180,
        
        spawn = function(pos)
            -- Otages
            local hostages = {}
            for i = 1, 2 do
                local hostage = ents.Create("npc_citizen")
                hostage:SetPos(pos + Vector(0, i * 30, 0))
                hostage:Spawn()
                hostage.IsEventVictim = true
                table.insert(hostages, hostage)
            end
            
            -- Criminels
            local criminals = {}
            for i = 1, 3 do
                local criminal = ents.Create("npc_metropolice")
                criminal:SetPos(pos + Vector(50 + i * 30, 0, 0))
                criminal:Spawn()
                criminal:Give("weapon_smg1")
                criminal.IsEventAttacker = true
                table.insert(criminals, criminal)
            end
            
            return {victims = hostages, attackers = criminals}
        end,
        
        check = function(eventData)
            -- Vérifier si tous les criminels sont neutralisés
            local allDown = true
            for _, criminal in ipairs(eventData.attackers) do
                if IsValid(criminal) and criminal:Alive() then
                    allDown = false
                    break
                end
            end
            return allDown, "Otages libérés"
        end
    },
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    SPAWN ÉVÉNEMENT ALÉATOIRE                      ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.RandomEvents.Spawn()
    -- Vérifier limite d'événements actifs
    if #DCUO.RandomEvents.Active >= 3 then
        return
    end
    
    -- Choisir un type aléatoire
    local eventType = table.Random(table.GetKeys(DCUO.RandomEvents.Types))
    local eventData = DCUO.RandomEvents.Types[eventType]
    
    -- Choisir une position
    local spawnPoints = DCUO.Config.EventSpawnPoints or {}
    if #spawnPoints == 0 then
        DCUO.Log("Aucun point de spawn d'événement configuré", "WARNING")
        return
    end
    
    local spawnPos = table.Random(spawnPoints)
    
    -- Spawn l'événement
    local entities = eventData.spawn(spawnPos)
    
    -- Créer l'événement actif
    local event = {
        type = eventType,
        data = eventData,
        entities = entities,
        startTime = CurTime(),
        position = spawnPos,
        completed = false,
    }
    
    table.insert(DCUO.RandomEvents.Active, event)
    
    -- Notifier les joueurs proches
    for _, ply in ipairs(player.GetAll()) do
        if ply:GetPos():Distance(spawnPos) <= 1000 then
            DCUO.Notify(ply, "[!] " .. eventData.name .. " en cours !", Color(255, 150, 0))
            ply:EmitSound("npc/overwatch/radiovoice/on3.wav")
        end
    end
    
    DCUO.Log("Random event spawned: " .. eventType, "SUCCESS")
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    VÉRIFIER ÉVÉNEMENTS ACTIFS                     ║
-- ╚═══════════════════════════════════════════════════════════════════╝

timer.Create("DCUO_CheckEvents", 2, 0, function()
    for i = #DCUO.RandomEvents.Active, 1, -1 do
        local event = DCUO.RandomEvents.Active[i]
        
        -- Vérifier timeout
        if CurTime() - event.startTime > event.data.duration then
            -- Timeout - échec
            DCUO.RandomEvents.CleanupEvent(event, false)
            table.remove(DCUO.RandomEvents.Active, i)
            continue
        end
        
        -- Vérifier si complété
        local completed, message = event.data.check(event.entities)
        if completed then
            -- Succès !
            DCUO.RandomEvents.CompleteEvent(event, message)
            table.remove(DCUO.RandomEvents.Active, i)
        end
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    COMPLÉTER ÉVÉNEMENT                            ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.RandomEvents.CompleteEvent(event, message)
    event.completed = true
    
    -- Trouver les joueurs qui ont participé (à proximité)
    local participants = {}
    for _, ply in ipairs(player.GetAll()) do
        if ply:GetPos():Distance(event.position) <= 500 then
            table.insert(participants, ply)
        end
    end
    
    -- Récompenser
    for _, ply in ipairs(participants) do
        DCUO.XP.Give(ply, event.data.xpReward, event.data.name .. " résolu")
        DCUO.Notify(ply, "[V] " .. (message or "Événement résolu") .. " ! +" .. event.data.xpReward .. " XP", Color(0, 255, 0))
    end
    
    -- Cleanup
    DCUO.RandomEvents.CleanupEvent(event, true)
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    NETTOYER ÉVÉNEMENT                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.RandomEvents.CleanupEvent(event, success)
    -- Supprimer toutes les entités
    if event.entities.victim and IsValid(event.entities.victim) then
        event.entities.victim:Remove()
    end
    
    if event.entities.attacker and IsValid(event.entities.attacker) then
        event.entities.attacker:Remove()
    end
    
    if event.entities.victims then
        for _, v in ipairs(event.entities.victims) do
            if IsValid(v) then v:Remove() end
        end
    end
    
    if event.entities.attackers then
        for _, a in ipairs(event.entities.attackers) do
            if IsValid(a) then a:Remove() end
        end
    end
    
    if event.entities.fire and IsValid(event.entities.fire) then
        event.entities.fire:Remove()
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    TIMER SPAWN AUTOMATIQUE                        ║
-- ╚═══════════════════════════════════════════════════════════════════╝

timer.Create("DCUO_RandomEventSpawner", 300, 0, function() -- Tous les 5 minutes
    if #player.GetAll() > 0 then
        DCUO.RandomEvents.Spawn()
    end
end)

DCUO.Log("Random events system loaded", "SUCCESS")

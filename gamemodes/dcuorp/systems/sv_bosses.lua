--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Boss (Serveur)
    Gestion spawn et combat des boss
═══════════════════════════════════════════════════════════════════════
--]]

if CLIENT then return end

DCUO.Bosses = DCUO.Bosses or {}
DCUO.Bosses.Active = {}

-- NetworkStrings pour Boss (les principales sont déjà dans shared.lua)
util.AddNetworkString("DCUO:BossHealth")
util.AddNetworkString("DCUO:BossWaypoint")

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    SPAWN UN BOSS                                  ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Bosses.Spawn(bossId, position)
    local bossData = DCUO.Bosses.List[bossId]
    if not bossData then
        DCUO.Log("Boss ID invalide: " .. tostring(bossId), "ERROR")
        return
    end
    
    -- Créer le NPC boss
    local boss = ents.Create(bossData.class)
    if not IsValid(boss) then
        DCUO.Log("Impossible de créer le boss", "ERROR")
        return
    end
    
    boss:SetPos(position)
    boss:SetAngles(Angle(0, math.random(0, 360), 0))
    boss:Spawn()
    boss:Activate()
    
    -- Configuration boss
    boss:SetModel(bossData.model)
    boss:SetHealth(bossData.health)
    boss:SetMaxHealth(bossData.health)
    boss:SetColor(bossData.color)
    boss:SetModelScale(bossData.scale or 1.5)
    
    -- Arme
    if bossData.weapon then
        boss:Give(bossData.weapon)
    end
    
    -- Marquer comme boss
    boss.IsDCUOBoss = true
    boss.BossID = bossId
    boss.BossData = bossData
    boss.SpawnTime = CurTime()
    boss.SpawnPos = position
    boss.PatrolRadius = 800  -- Zone de patrouille
    boss.NextPatrolTime = CurTime()
    boss.CurrentTarget = nil
    
    -- Niveau du boss (pour affichage)
    boss.DCUOLevel = bossData.level or 30
    boss.DCUOName = bossData.name or "Boss"
    
    -- ═══ SYNCHRONISATION RÉSEAU IMMÉDIATE ═══
    boss:SetNWInt("DCUO_BossHealth", boss:Health())
    boss:SetNWInt("DCUO_BossMaxHealth", boss:GetMaxHealth())
    boss:SetNWString("DCUO_BossName", bossData.name)
    boss:SetNWBool("DCUO_IsBoss", true)
    
    -- ═══ CONFIGURATION IA AGRESSIVE ═══
    timer.Simple(0.5, function()
        if not IsValid(boss) then return end
        
        -- Capacités complètes
        boss:CapabilitiesAdd(CAP_MOVE_GROUND)
        boss:CapabilitiesAdd(CAP_MOVE_JUMP)
        boss:CapabilitiesAdd(CAP_MOVE_CLIMB)
        boss:CapabilitiesAdd(CAP_OPEN_DOORS)
        boss:CapabilitiesAdd(CAP_USE)
        boss:CapabilitiesAdd(CAP_WEAPON_RANGE_ATTACK1)
        boss:CapabilitiesAdd(CAP_WEAPON_MELEE_ATTACK1)
        boss:CapabilitiesAdd(CAP_ANIMATEDFACE)
        boss:CapabilitiesAdd(CAP_TURN_HEAD)
        boss:CapabilitiesAdd(CAP_DUCK)
        boss:CapabilitiesAdd(CAP_AIM_GUN)
        
        -- Précision de tir parfaite
        boss:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
        
        -- Relations hostiles
        boss:AddRelationship("player D_HT 99")
        boss:AddRelationship("npc_citizen D_LI 99")
        
        -- Paramètres d'agressivité
        boss:SetSchedule(SCHED_COMBAT_FACE)
        
        DCUO.Log("Boss IA configured: " .. bossData.name, "SUCCESS")
    end)
    
    -- Ajouter aux boss actifs
    table.insert(DCUO.Bosses.Active, boss)
    
    -- Notifier tous les joueurs
    DCUO.Bosses.NotifySpawn(boss, bossData)
    
    -- Envoyer données réseau
    net.Start("DCUO:BossSpawned")
        net.WriteEntity(boss)
        net.WriteString(bossData.name)
        net.WriteVector(position)
    net.Broadcast()
    
    DCUO.Log("Boss spawned: " .. bossData.name .. " at " .. tostring(position), "SUCCESS")
    
    return boss
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    NOTIFIER SPAWN BOSS                            ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Bosses.NotifySpawn(boss, bossData)
    local pos = boss:GetPos()
    
    -- Notification globale avec option d'accepter
    for _, ply in ipairs(player.GetAll()) do
        -- Stocker l'info du boss pour accept
        ply.PendingBossEvent = {
            boss = boss,
            bossId = boss.BossID,
            position = pos,
            name = bossData.name,
            time = CurTime()
        }
        
        DCUO.Notify(ply, "[!] BOSS APPARU : " .. bossData.name .. " ! Tapez /accept pour partir en chasse !", Color(255, 50, 50))
        ply:EmitSound("ambient/alarms/warningbell1.wav", 75, 100)
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    MORT DU BOSS                                   ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("OnNPCKilled", "DCUO:BossKilled", function(npc, attacker, inflictor)
    if not npc.IsDCUOBoss then return end
    
    local bossData = npc.BossData
    local pos = npc:GetPos()
    
    -- Trouver tous les joueurs à proximité
    local nearbyPlayers = {}
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:GetPos():Distance(pos) <= DCUO.Bosses.Config.RewardRadius then
            table.insert(nearbyPlayers, ply)
        end
    end
    
    -- Récompenser les joueurs
    local xpPerPlayer = bossData.xpReward
    if #nearbyPlayers > 1 then
        -- Bonus pour travail d'équipe
        xpPerPlayer = math.floor(xpPerPlayer * 1.2)
    end
    
    for _, ply in ipairs(nearbyPlayers) do
        DCUO.XP.Give(ply, xpPerPlayer, "Boss vaincu: " .. bossData.name)
        DCUO.Notify(ply, "[+] Boss vaincu ! +" .. xpPerPlayer .. " XP", Color(255, 215, 0))
    end
    
    -- Notification globale
    local killerName = IsValid(attacker) and attacker:IsPlayer() and attacker:Nick() or "Les héros"
    DCUO.NotifyAll("[V] " .. bossData.name .. " a été vaincu par " .. killerName .. " !", Color(0, 255, 0))
    
    -- Effet visuel
    local effectData = EffectData()
    effectData:SetOrigin(pos)
    effectData:SetScale(3)
    util.Effect("Explosion", effectData)
    
    -- Retirer des boss actifs
    table.RemoveByValue(DCUO.Bosses.Active, npc)
    
    -- Network
    net.Start("DCUO:BossKilled")
        net.WriteString(bossData.name)
    net.Broadcast()
    
    DCUO.Log("Boss killed: " .. bossData.name, "SUCCESS")
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    COMMANDE /ACCEPT BOSS                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("PlayerSay", "DCUO:AcceptBossEvent", function(ply, text)
    local cmd = string.lower(string.Trim(text))
    
    if cmd == "/accept" then
        if not ply.PendingBossEvent then
            DCUO.Notify(ply, "Aucun événement de boss en attente", Color(255, 100, 100))
            return ""
        end
        
        local event = ply.PendingBossEvent
        
        -- Vérifier que le boss existe toujours
        if not IsValid(event.boss) then
            DCUO.Notify(ply, "Le boss n'est plus disponible", Color(255, 100, 100))
            ply.PendingBossEvent = nil
            return ""
        end
        
        -- Annuler mission actuelle si en cours
        if ply.DCUOData and ply.DCUOData.currentMission then
            local oldMission = ply.DCUOData.currentMission
            ply.DCUOData.currentMission = nil
            DCUO.Notify(ply, "Mission '" .. (oldMission.title or "Mission") .. "' annulée pour l'événement boss", Color(255, 165, 0))
            
            -- Nettoyer waypoints mission (le nouveau waypoint boss sera ajouté)
            if DCUO.Missions and DCUO.Missions.End then
                -- Utiliser fonction existante si disponible
                DCUO.Missions.End(ply, false, "Annulée pour événement boss")
            end
        end
        
        -- Envoyer waypoint au client
        net.Start("DCUO:BossWaypoint")
            net.WriteVector(event.position)
            net.WriteString(event.name)
        net.Send(ply)
        
        DCUO.Notify(ply, "[GPS] Waypoint activé vers " .. event.name, Color(0, 255, 0))
        ply.PendingBossEvent = nil
        
        return ""
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    SPAWN ALÉATOIRE DE BOSS                        ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Bosses.SpawnRandom()
    -- Vérifier qu'il n'y a pas trop de boss actifs
    if #DCUO.Bosses.Active >= 2 then
        DCUO.Log("Trop de boss actifs, skip spawn", "INFO")
        return
    end
    
    -- Choisir un boss aléatoire
    local bossId = table.Random(table.GetKeys(DCUO.Bosses.List))
    
    -- Choisir une position aléatoire
    local spawnPoints = DCUO.Config.BossSpawnPoints or {}
    if #spawnPoints == 0 then
        DCUO.Log("Aucun point de spawn de boss configuré", "WARNING")
        return
    end
    
    local spawnPos = table.Random(spawnPoints)
    
    -- Spawn
    DCUO.Bosses.Spawn(bossId, spawnPos)
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    TIMER SPAWN AUTOMATIQUE                        ║
-- ╚═══════════════════════════════════════════════════════════════════╝

timer.Create("DCUO_BossSpawner", DCUO.Bosses.Config.SpawnInterval, 0, function()
    -- Vérifier qu'il y a des joueurs
    if #player.GetAll() == 0 then return end
    
    DCUO.Bosses.SpawnRandom()
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    UPDATE SANTÉ & IA BOSS                         ║
-- ╚═══════════════════════════════════════════════════════════════════╝

timer.Create("DCUO_BossHealthUpdate", 0.2, 0, function()
    for _, boss in ipairs(DCUO.Bosses.Active) do
        if IsValid(boss) then
            local health = boss:Health()
            local maxHealth = boss:GetMaxHealth()
            
            -- Synchronisation réseau rapide
            boss:SetNWInt("DCUO_BossHealth", health)
            boss:SetNWInt("DCUO_BossMaxHealth", maxHealth)
            boss:SetNWString("DCUO_BossName", boss.BossData.name or "Boss")
        else
            -- Nettoyer
            table.RemoveByValue(DCUO.Bosses.Active, boss)
        end
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    IA DYNAMIQUE DU BOSS                           ║
-- ╚═══════════════════════════════════════════════════════════════════╝

timer.Create("DCUO_BossAI", 1, 0, function()
    for _, boss in ipairs(DCUO.Bosses.Active) do
        if not IsValid(boss) then continue end
        
        local currentPos = boss:GetPos()
        local spawnPos = boss.SpawnPos or currentPos
        local distanceFromSpawn = currentPos:Distance(spawnPos)
        
        -- ═══ CHERCHER DES JOUEURS À ATTAQUER ═══
        local nearestPlayer = nil
        local nearestDist = 2000
        
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:Alive() then
                local dist = currentPos:Distance(ply:GetPos())
                if dist < nearestDist then
                    nearestPlayer = ply
                    nearestDist = dist
                end
            end
        end
        
        -- ═══ COMPORTEMENT SELON LA SITUATION ═══
        if nearestPlayer and nearestDist < 1500 then
            -- JOUEUR PROCHE : ATTAQUER
            if boss:GetEnemy() ~= nearestPlayer then
                boss:SetEnemy(nearestPlayer)
                boss:SetSchedule(SCHED_CHASE_ENEMY)
            end
            
            -- Forcer l'engagement si immobile
            if boss:IsCurrentSchedule(SCHED_IDLE_STAND) or boss:IsCurrentSchedule(SCHED_ALERT_STAND) then
                boss:SetSchedule(SCHED_COMBAT_FACE)
            end
            
            boss.CurrentTarget = nearestPlayer
            boss.NextPatrolTime = CurTime() + 10  -- Retarder patrouille
            
        elseif distanceFromSpawn > (boss.PatrolRadius or 800) then
            -- TROP LOIN DU SPAWN : REVENIR
            boss:SetLastPosition(spawnPos)
            boss:SetSchedule(SCHED_FORCED_GO_RUN)
            boss:SetEnemy(NULL)
            boss.CurrentTarget = nil
            
        elseif CurTime() >= boss.NextPatrolTime then
            -- PATROUILLE DANS LA ZONE
            local randomOffset = Vector(
                math.random(-400, 400),
                math.random(-400, 400),
                0
            )
            local patrolPoint = spawnPos + randomOffset
            
            -- Trace vers le sol
            local trace = util.TraceLine({
                start = patrolPoint + Vector(0, 0, 100),
                endpos = patrolPoint - Vector(0, 0, 500),
                mask = MASK_SOLID_BRUSHONLY
            })
            
            if trace.Hit then
                patrolPoint = trace.HitPos + Vector(0, 0, 10)
                boss:SetLastPosition(patrolPoint)
                boss:SetSchedule(SCHED_FORCED_GO_RUN)
            end
            
            boss.NextPatrolTime = CurTime() + math.random(8, 15)
            boss:SetEnemy(NULL)
        end
        
        -- ═══ FORCER L'ANIMATION DE COMBAT ═══
        if boss.CurrentTarget and IsValid(boss.CurrentTarget) then
            local target = boss.CurrentTarget
            local dist = currentPos:Distance(target:GetPos())
            
            -- Tirer si à portée
            if dist < 800 and dist > 100 then
                if not boss:IsCurrentSchedule(SCHED_RANGE_ATTACK1) then
                    boss:SetSchedule(SCHED_RANGE_ATTACK1)
                end
            elseif dist <= 100 then
                -- Combat rapproché
                if not boss:IsCurrentSchedule(SCHED_MELEE_ATTACK1) then
                    boss:SetSchedule(SCHED_MELEE_ATTACK1)
                end
            end
        end
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    COMMANDES ADMIN                                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

if ULib then
    function ulx.spawnboss(calling_ply, bossId)
        local pos = calling_ply:GetEyeTrace().HitPos
        DCUO.Bosses.Spawn(bossId, pos)
        ulx.fancyLogAdmin(calling_ply, "#A a fait spawn le boss #s", bossId)
    end
    
    local bossNames = {}
    for id, _ in pairs(DCUO.Bosses.List) do
        table.insert(bossNames, id)
    end
    
    local spawnboss = ulx.command("DCUO", "ulx spawnboss", ulx.spawnboss, "!spawnboss")
    spawnboss:addParam{type=ULib.cmds.StringArg, completes=bossNames, hint="boss ID"}
    spawnboss:defaultAccess(ULib.ACCESS_ADMIN)
    spawnboss:help("Spawn un boss")
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    COMMANDES DEBUG                                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Commande pour tester le spawn d'un boss
concommand.Add("dcuo_test_boss_spawn", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    
    local bossId = args[1] or table.Random(table.GetKeys(DCUO.Bosses.List))
    
    if not DCUO.Bosses.List[bossId] then
        DCUO.Notify(ply, "Boss ID invalide: " .. bossId, DCUO.Colors.Error)
        return
    end
    
    local trace = ply:GetEyeTrace()
    local spawnPos = trace.HitPos
    
    local boss = DCUO.Bosses.Spawn(bossId, spawnPos)
    DCUO.Notify(ply, "Boss spawné: " .. bossId, DCUO.Colors.Success)
    
    print("[DCUO TEST] Boss " .. bossId .. " spawné à: " .. tostring(spawnPos))
end)

-- Commande pour afficher l'info des boss actifs
concommand.Add("dcuo_boss_info", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    
    print("═══════════════════════════════════════")
    print("BOSS ACTIFS:")
    print("═══════════════════════════════════════")
    
    if #DCUO.Bosses.Active == 0 then
        print("Aucun boss actif")
    else
        for i, boss in ipairs(DCUO.Bosses.Active) do
            if IsValid(boss) then
                print(string.format("[%d] %s", i, boss.BossData.name))
                print("  Position: " .. tostring(boss:GetPos()))
                print("  Spawn: " .. tostring(boss.SpawnPos))
                print("  Santé: " .. boss:Health() .. "/" .. boss:GetMaxHealth())
                print("  Distance spawn: " .. math.Round(boss:GetPos():Distance(boss.SpawnPos)) .. "u")
                
                local enemy = boss:GetEnemy()
                if IsValid(enemy) then
                    print("  Cible: " .. enemy:Nick())
                else
                    print("  Cible: Aucune")
                end
                
                print("  Prochaine patrouille: " .. math.Round(boss.NextPatrolTime - CurTime()) .. "s")
            end
        end
    end
    
    print("═══════════════════════════════════════")
end)

-- Commande pour téléporter vers un boss
concommand.Add("dcuo_goto_boss", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    
    if #DCUO.Bosses.Active == 0 then
        DCUO.Notify(ply, "Aucun boss actif", DCUO.Colors.Error)
        return
    end
    
    local boss = DCUO.Bosses.Active[1]
    if IsValid(boss) then
        ply:SetPos(boss:GetPos() + Vector(0, 0, 100))
        DCUO.Notify(ply, "Téléporté vers " .. boss.BossData.name, DCUO.Colors.Success)
    end
end)

DCUO.Log("Boss server system loaded", "SUCCESS")

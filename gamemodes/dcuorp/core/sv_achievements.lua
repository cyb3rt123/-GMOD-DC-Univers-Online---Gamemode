--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Succès (Server)
    Gestion et vérification des succès
═══════════════════════════════════════════════════════════════════════
--]]

if CLIENT then return end

util.AddNetworkString("DCUO:Achievement:Unlock")
util.AddNetworkString("DCUO:Achievement:Progress")
util.AddNetworkString("DCUO:Achievement:Sync")

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    VÉRIFICATION DES SUCCÈS                        ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Achievements.Check(ply, achievementID)
    if not IsValid(ply) then return false end
    if not ply.DCUOData then return false end
    
    local achievement = DCUO.Achievements.Get(achievementID)
    if not achievement then return false end
    
    -- Déjà débloqué?
    if ply.DCUOData.achievements[achievementID] then
        return false
    end
    
    local req = achievement.requirement
    local stats = ply.DCUOData
    
    local unlocked = false
    
    if req.type == "level" then
        unlocked = stats.level >= req.value
    elseif req.type == "kills" then
        unlocked = (stats.kills or 0) >= req.value
    elseif req.type == "boss_kills" then
        unlocked = (stats.boss_kills or 0) >= req.value
    elseif req.type == "deaths" then
        unlocked = (stats.deaths or 0) >= req.value
    elseif req.type == "fall_deaths" then
        unlocked = (stats.fall_deaths or 0) >= req.value
    elseif req.type == "missions" then
        unlocked = (stats.missions_completed or 0) >= req.value
    elseif req.type == "playtime" then
        unlocked = (stats.playtime or 0) >= req.value
    elseif req.type == "friends" then
        unlocked = table.Count(stats.friends or {}) >= req.value
    elseif req.type == "auras" then
        unlocked = table.Count(stats.auras or {}) >= req.value
    elseif req.type == "create_guild" or req.type == "join_guild" then
        -- Vérifié manuellement lors de l'action
        return false
    end
    
    if unlocked then
        DCUO.Achievements.Unlock(ply, achievementID)
        return true
    end
    
    return false
end

function DCUO.Achievements.CheckAll(ply)
    if not IsValid(ply) then return end
    
    for _, achievement in ipairs(DCUO.Achievements.List) do
        DCUO.Achievements.Check(ply, achievement.id)
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    DÉBLOCAGE DE SUCCÈS                            ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Achievements.Unlock(ply, achievementID, manual)
    if not IsValid(ply) then return end
    if not ply.DCUOData then return end
    
    local achievement = DCUO.Achievements.Get(achievementID)
    if not achievement then return end
    
    -- Déjà débloqué?
    if ply.DCUOData.achievements[achievementID] then return end
    
    -- Débloquer
    ply.DCUOData.achievements[achievementID] = {
        unlocked_at = os.time(),
        manual = manual or false
    }
    
    ply.DCUOData.achievement_points = (ply.DCUOData.achievement_points or 0) + achievement.points
    
    -- Récompenses
    if achievement.reward then
        if achievement.reward.xp and DCUO.XP and DCUO.XP.Add then
            DCUO.XP.Add(ply, achievement.reward.xp)
        end
        if achievement.reward.money then
            ply.DCUOData.money = (ply.DCUOData.money or 0) + achievement.reward.money
        end
    end
    
    -- Sauvegarder
    DCUO.Database.SavePlayer(ply)
    DCUO.Database.SaveAchievement(ply, achievementID)
    
    -- Notifier le client
    net.Start("DCUO:Achievement:Unlock")
        net.WriteString(achievementID)
        net.WriteTable(achievement)
    net.Send(ply)
    
    -- Message global pour succès importants (50+ points)
    if achievement.points >= 50 then
        for _, p in ipairs(player.GetAll()) do
            p:ChatPrint("[SUCCÈS] " .. ply:Nick() .. " a débloqué: " .. achievement.name .. " (" .. achievement.points .. " pts)")
        end
    else
        ply:ChatPrint("[SUCCÈS] Débloqué: " .. achievement.name .. " (+" .. achievement.points .. " pts)")
    end
    
    DCUO.Log("[ACHIEVEMENT] " .. ply:Nick() .. " unlocked: " .. achievementID, "SUCCESS")
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    PROGRESSION DES SUCCÈS                         ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Achievements.GetProgress(ply, achievementID)
    if not IsValid(ply) then return 0, 0 end
    if not ply.DCUOData then return 0, 0 end
    
    local achievement = DCUO.Achievements.Get(achievementID)
    if not achievement then return 0, 0 end
    
    -- Déjà débloqué?
    if ply.DCUOData.achievements[achievementID] then
        return achievement.requirement.value, achievement.requirement.value
    end
    
    local req = achievement.requirement
    local stats = ply.DCUOData
    local current = 0
    
    if req.type == "level" then
        current = stats.level
    elseif req.type == "kills" then
        current = stats.kills or 0
    elseif req.type == "boss_kills" then
        current = stats.boss_kills or 0
    elseif req.type == "deaths" then
        current = stats.deaths or 0
    elseif req.type == "fall_deaths" then
        current = stats.fall_deaths or 0
    elseif req.type == "missions" then
        current = stats.missions_completed or 0
    elseif req.type == "playtime" then
        current = stats.playtime or 0
    elseif req.type == "friends" then
        current = table.Count(stats.friends or {})
    elseif req.type == "auras" then
        current = table.Count(stats.auras or {})
    end
    
    return current, req.value
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    SYNCHRONISATION                                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Achievements.Sync(ply)
    if not IsValid(ply) then return end
    if not ply.DCUOData then return end
    
    net.Start("DCUO:Achievement:Sync")
        net.WriteTable(ply.DCUOData.achievements or {})
        net.WriteUInt(ply.DCUOData.achievement_points or 0, 16)
    net.Send(ply)
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    HOOKS                                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Vérifier les succès lors du spawn
hook.Add("PlayerSpawn", "DCUO:CheckAchievements", function(ply)
    timer.Simple(1, function()
        if IsValid(ply) then
            DCUO.Achievements.CheckAll(ply)
        end
    end)
end)

-- Vérifier lors du changement de niveau
hook.Add("DCUO:PlayerLevelUp", "DCUO:CheckLevelAchievements", function(ply, newLevel)
    DCUO.Achievements.CheckAll(ply)
end)

-- Vérifier lors d'un kill
hook.Add("PlayerDeath", "DCUO:CheckKillAchievements", function(victim, inflictor, attacker)
    if IsValid(attacker) and attacker:IsPlayer() and attacker ~= victim then
        -- Incrémenter les kills
        attacker.DCUOData.kills = (attacker.DCUOData.kills or 0) + 1
        DCUO.Database.SavePlayer(attacker)
        
        -- Vérifier les succès de kills
        DCUO.Achievements.CheckAll(attacker)
    end
    
    if IsValid(victim) and victim:IsPlayer() then
        -- Incrémenter les morts
        victim.DCUOData.deaths = (victim.DCUOData.deaths or 0) + 1
        
        -- Vérifier si c'est une mort de chute
        if victim:GetLastDamageType() == DMG_FALL then
            victim.DCUOData.fall_deaths = (victim.DCUOData.fall_deaths or 0) + 1
        end
        
        DCUO.Database.SavePlayer(victim)
        DCUO.Achievements.CheckAll(victim)
    end
end)

-- Vérifier lors de la complétion d'une mission
hook.Add("DCUO:MissionCompleted", "DCUO:CheckMissionAchievements", function(ply, mission)
    ply.DCUOData.missions_completed = (ply.DCUOData.missions_completed or 0) + 1
    DCUO.Database.SavePlayer(ply)
    DCUO.Achievements.CheckAll(ply)
end)

-- Vérifier lors de l'achat d'une aura
hook.Add("DCUO:AuraPurchased", "DCUO:CheckAuraAchievements", function(ply, auraID)
    timer.Simple(0.1, function()
        if IsValid(ply) then
            DCUO.Achievements.CheckAll(ply)
        end
    end)
end)

-- Vérifier lors de la création/rejoindre une guilde
hook.Add("DCUO:GuildCreated", "DCUO:CheckGuildAchievements", function(ply)
    DCUO.Achievements.Unlock(ply, "create_guild", true)
end)

hook.Add("DCUO:GuildJoined", "DCUO:CheckGuildAchievements", function(ply)
    DCUO.Achievements.Unlock(ply, "join_guild", true)
end)

-- Playtime tracker
timer.Create("DCUO:PlaytimeTracker", 60, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        if ply.DCUOData then
            ply.DCUOData.playtime = (ply.DCUOData.playtime or 0) + 60
            
            -- Vérifier les succès de playtime toutes les 10 minutes
            if (ply.DCUOData.playtime % 600) == 0 then
                DCUO.Achievements.CheckAll(ply)
            end
        end
    end
end)

DCUO.Log("Achievements System (Server) Loaded", "SUCCESS")

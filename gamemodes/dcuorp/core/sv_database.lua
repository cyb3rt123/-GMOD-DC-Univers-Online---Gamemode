--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Base de Données SQL
    Gestion de la persistance des données joueurs
═══════════════════════════════════════════════════════════════════════
--]]

if CLIENT then return end

DCUO.Database = DCUO.Database or {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    INITIALISATION BDD                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Database.Initialize()
    DCUO.Log("Initializing database...", "INFO")
    
    -- Créer la table des joueurs
    local query = [[
        CREATE TABLE IF NOT EXISTS dcuo_players (
            steam_id VARCHAR(255) PRIMARY KEY,
            rpname VARCHAR(255) NOT NULL,
            firstname VARCHAR(255),
            lastname VARCHAR(255),
            age INT DEFAULT 25,
            origin TEXT,
            faction VARCHAR(50) DEFAULT 'Neutral',
            job VARCHAR(100) DEFAULT 'Recrue',
            level INT DEFAULT 1,
            xp INT DEFAULT 0,
            total_playtime INT DEFAULT 0,
            model VARCHAR(255),
            equipped_aura VARCHAR(100) DEFAULT 'none',
            owned_auras TEXT DEFAULT '[]',
            last_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]]
    
    sql.Query(query)
    
    local lastError = sql.LastError()
    if lastError and lastError ~= "" then
        if DCUO and DCUO.Log then
            DCUO.Log("Database Error: " .. tostring(lastError), "ERROR")
        else
            print("[DCUO-RP] [ERROR] Database Error: " .. tostring(lastError))
        end
        return false
    end
    
    DCUO.Log("Table dcuo_players created/verified", "SUCCESS")
    
    -- Créer la table des missions complétées
    query = [[
        CREATE TABLE IF NOT EXISTS dcuo_missions_completed (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            steam_id VARCHAR(255),
            mission_id VARCHAR(100),
            completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (steam_id) REFERENCES dcuo_players(steam_id)
        )
    ]]
    
    sql.Query(query)
    
    local lastError = sql.LastError()
    if lastError and lastError ~= "" then
        DCUO.Log("Database Error: " .. tostring(lastError), "ERROR")
        return false
    end
    
    DCUO.Log("Table dcuo_missions_completed created/verified", "SUCCESS")
    
    -- Créer la table des achats (shop)
    query = [[
        CREATE TABLE IF NOT EXISTS dcuo_purchases (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            steam_id VARCHAR(255),
            item_id VARCHAR(100),
            purchased_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (steam_id) REFERENCES dcuo_players(steam_id)
        )
    ]]
    
    sql.Query(query)
    
    local lastError = sql.LastError()
    if lastError and lastError ~= "" then
        DCUO.Log("Database Error: " .. tostring(lastError), "ERROR")
        return false
    end
    
    DCUO.Log("Table dcuo_shop_purchases created/verified", "SUCCESS")
    
    -- Créer la table des logs admin
    query = [[
        CREATE TABLE IF NOT EXISTS dcuo_admin_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            admin_steam_id VARCHAR(255),
            admin_name VARCHAR(255),
            action VARCHAR(255),
            target_steam_id VARCHAR(255),
            target_name VARCHAR(255),
            details TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]]
    
    sql.Query(query)
    
    local lastError = sql.LastError()
    if lastError and lastError ~= "" then
        DCUO.Log("Database Error: " .. tostring(lastError), "ERROR")
        return false
    end
    
    DCUO.Log("Table dcuo_admin_logs created/verified", "SUCCESS")
    
    -- Créer la table des succès
    query = [[
        CREATE TABLE IF NOT EXISTS dcuo_achievements (
            steam_id VARCHAR(255),
            achievement_id VARCHAR(100),
            unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (steam_id, achievement_id),
            FOREIGN KEY (steam_id) REFERENCES dcuo_players(steam_id)
        )
    ]]
    
    sql.Query(query)
    
    local lastError = sql.LastError()
    if lastError and lastError ~= "" then
        DCUO.Log("Database Error: " .. tostring(lastError), "ERROR")
        return false
    end
    
    DCUO.Log("Table dcuo_achievements created/verified", "SUCCESS")
    DCUO.Log("Database initialized successfully!", "SUCCESS")
    return true
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONCTIONS JOUEUR                               ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Charger les données d'un joueur
function DCUO.Database.LoadPlayer(ply, callback)
    if not IsValid(ply) then return end
    
    local steamID = ply:SteamID64()
    
    local query = string.format([[
        SELECT * FROM dcuo_players WHERE steam_id = %s
    ]], sql.SQLStr(steamID))
    
    local result = sql.Query(query)
    
    local lastError = sql.LastError()
    if lastError and lastError ~= "" then
        DCUO.Log("Database Error: " .. tostring(lastError), "ERROR")
        if callback then callback(false) end
        return
    end
    
    if not result then
        -- Nouveau joueur
        -- Calculer maxXP avec vérification
        local maxXP = 100  -- Valeur par défaut
        if DCUO.XP and DCUO.XP.CalculateXPNeeded then
            maxXP = DCUO.XP.CalculateXPNeeded(1)
        end
        
        ply.DCUOData = {
            steamID = steamID,
            rpname = "",
            firstname = "",
            lastname = "",
            age = 25,
            origin = "",
            faction = "Neutral",
            job = "Recrue",
            level = 1,
            xp = 0,
            maxXP = maxXP,
            totalPlaytime = 0,
            model = "",
            missions = {},
            purchases = {},
        }
        
        DCUO.Log(ply:Nick() .. " is a new player", "INFO")
        
        if callback then callback(false) end
        return
    end
    
    -- Charger les données existantes
    local data = result[1]
    
    -- Charger les auras possédées (JSON)
    local ownedAuras = {}
    if data.owned_auras and data.owned_auras ~= "" then
        ownedAuras = util.JSONToTable(data.owned_auras) or {}
    end
    
    -- Calculer maxXP avec vérification
    local maxXP = 100  -- Valeur par défaut
    if DCUO.XP and DCUO.XP.CalculateXPNeeded then
        maxXP = DCUO.XP.CalculateXPNeeded(tonumber(data.level) or 1)
    end
    
    ply.DCUOData = {
        steamID = steamID,
        rpname = data.rpname,
        firstname = data.firstname or "",
        lastname = data.lastname or "",
        age = tonumber(data.age) or 25,
        origin = data.origin or "",
        faction = data.faction or "Neutral",
        job = data.job or "Recrue",
        level = tonumber(data.level) or 1,
        xp = tonumber(data.xp) or 0,
        maxXP = maxXP,
        totalPlaytime = tonumber(data.total_playtime) or 0,
        model = "",
        equippedAura = data.equipped_aura or "none",
        auras = ownedAuras,
        missions = {},
        purchases = {},
        achievements = {},
        achievement_points = 0,
        kills = 0,
        boss_kills = 0,
        deaths = 0,
        fall_deaths = 0,
        missions_completed = 0,
        playtime = 0,
        friends = {},
    }
    
    -- Charger les missions complétées
    DCUO.Database.LoadPlayerMissions(ply)
    
    -- Charger les achats
    DCUO.Database.LoadPlayerPurchases(ply)
    
    -- Charger les succès
    DCUO.Database.LoadPlayerAchievements(ply)
    
    -- Synchroniser le niveau via NetworkedVars pour le scaling
    ply:SetNWInt("DCUO_Level", ply.DCUOData.level or 1)
    
    -- Envoyer les données au client
    timer.Simple(0.5, function()
        if IsValid(ply) then
            net.Start("DCUO:PlayerData")
                net.WriteTable(ply.DCUOData)
            net.Send(ply)
        end
    end)
    
    DCUO.Log(ply:Nick() .. "'s data loaded", "SUCCESS")
    
    if callback then callback(true) end
end

-- Sauvegarder les données d'un joueur
function DCUO.Database.SavePlayer(ply)
    if not IsValid(ply) or not ply.DCUOData then return end
    
    local data = ply.DCUOData
    local steamID = ply:SteamID64()
    
    -- Vérifier si le joueur existe
    local checkQuery = string.format([[
        SELECT steam_id FROM dcuo_players WHERE steam_id = %s
    ]], sql.SQLStr(steamID))
    
    local exists = sql.Query(checkQuery)
    
    if exists then
        -- UPDATE
        -- Convertir auras en JSON
        local aurasJSON = util.TableToJSON(data.auras or {})
        
        local query = string.format([[
            UPDATE dcuo_players SET
                rpname = %s,
                firstname = %s,
                lastname = %s,
                age = %d,
                origin = %s,
                faction = %s,
                job = %s,
                level = %d,
                xp = %d,
                total_playtime = %d,
                model = %s,
                equipped_aura = %s,
                owned_auras = %s,
                last_login = CURRENT_TIMESTAMP
            WHERE steam_id = %s
        ]],
            sql.SQLStr(data.rpname or ""),
            sql.SQLStr(data.firstname or ""),
            sql.SQLStr(data.lastname or ""),
            data.age or 25,
            sql.SQLStr(data.origin or ""),
            sql.SQLStr(data.faction or "Neutral"),
            sql.SQLStr(data.job or "Recrue"),
            data.level or 1,
            data.xp or 0,
            data.totalPlaytime or 0,
            sql.SQLStr(data.model or ""),
            sql.SQLStr(data.equippedAura or "none"),
            sql.SQLStr(aurasJSON),
            sql.SQLStr(steamID)
        )
        
        sql.Query(query)
    else
        -- INSERT
        local query = string.format([[
            INSERT INTO dcuo_players (
                steam_id, rpname, firstname, lastname, age, origin,
                faction, job, level, xp, total_playtime, model
            ) VALUES (
                '%s', '%s', '%s', '%s', %d, '%s',
                '%s', '%s', %d, %d, %d, '%s'
            )
        ]],
            sql.SQLStr(steamID, true),
            sql.SQLStr(data.rpname or "", true),
            sql.SQLStr(data.firstname or "", true),
            sql.SQLStr(data.lastname or "", true),
            data.age or 25,
            sql.SQLStr(data.origin or "", true),
            sql.SQLStr(data.faction or "Neutral", true),
            sql.SQLStr(data.job or "Recrue", true),
            data.level or 1,
            data.xp or 0,
            data.totalPlaytime or 0,
            sql.SQLStr(data.model or "", true)
        )
        
        sql.Query(query)
    end
    
    local lastError = sql.LastError()
    if lastError and lastError ~= "" then
        DCUO.Log("Database Save Error: " .. tostring(lastError), "ERROR")
        return false
    end
    
    DCUO.Log(ply:Nick() .. "'s data saved", "SUCCESS")
    return true
end

-- Charger les missions complétées d'un joueur
function DCUO.Database.LoadPlayerMissions(ply)
    if not IsValid(ply) then return end
    
    local steamID = ply:SteamID64()
    
    local query = string.format([[
        SELECT mission_id FROM dcuo_missions_completed
        WHERE steam_id = '%s'
    ]], sql.SQLStr(steamID, true))
    
    local result = sql.Query(query)
    
    if result then
        ply.DCUOData.missions = {}
        for _, row in ipairs(result) do
            table.insert(ply.DCUOData.missions, row.mission_id)
        end
    end
end

-- Sauvegarder une mission complétée
function DCUO.Database.SaveMissionCompleted(ply, missionID)
    if not IsValid(ply) then return end
    
    local steamID = ply:SteamID64()
    
    local query = string.format([[
        INSERT INTO dcuo_missions_completed (steam_id, mission_id)
        VALUES ('%s', '%s')
    ]], sql.SQLStr(steamID, true), sql.SQLStr(missionID, true))
    
    sql.Query(query)
    
    local lastError = sql.LastError()
    if lastError and lastError ~= "" then
        DCUO.Log("Database Error: " .. tostring(lastError), "ERROR")
        return false
    end
    
    return true
end

-- Charger les achats d'un joueur
function DCUO.Database.LoadPlayerPurchases(ply)
    if not IsValid(ply) then return end
    
    local steamID = ply:SteamID64()
    
    local query = string.format([[
        SELECT item_id FROM dcuo_purchases
        WHERE steam_id = '%s'
    ]], sql.SQLStr(steamID, true))
    
    local result = sql.Query(query)
    
    if result then
        ply.DCUOData.purchases = {}
        for _, row in ipairs(result) do
            table.insert(ply.DCUOData.purchases, row.item_id)
        end
    end
end

-- Sauvegarder un achat
function DCUO.Database.SavePurchase(ply, itemID)
    if not IsValid(ply) then return end
    
    local steamID = ply:SteamID64()
    
    local query = string.format([[
        INSERT INTO dcuo_purchases (steam_id, item_id)
        VALUES ('%s', '%s')
    ]], sql.SQLStr(steamID, true), sql.SQLStr(itemID, true))
    
    sql.Query(query)
    
    local lastError = sql.LastError()
    if lastError and lastError ~= "" then
        DCUO.Log("Database Error: " .. tostring(lastError), "ERROR")
        return false
    end
    
    return true
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    ACHIEVEMENTS                                   ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Charger les succès d'un joueur
function DCUO.Database.LoadPlayerAchievements(ply)
    if not IsValid(ply) then return end
    
    local steamID = ply:SteamID64()
    
    local query = string.format([[
        SELECT * FROM dcuo_achievements WHERE steam_id = '%s'
    ]], sql.SQLStr(steamID, true))
    
    local result = sql.Query(query)
    
    if result then
        ply.DCUOData.achievements = {}
        ply.DCUOData.achievement_points = 0
        
        for _, row in ipairs(result) do
            ply.DCUOData.achievements[row.achievement_id] = {
                unlocked_at = row.unlocked_at
            }
            
            -- Calculer les points
            local achievement = DCUO.Achievements.Get(row.achievement_id)
            if achievement then
                ply.DCUOData.achievement_points = ply.DCUOData.achievement_points + achievement.points
            end
        end
    else
        ply.DCUOData.achievements = {}
        ply.DCUOData.achievement_points = 0
    end
end

-- Sauvegarder un succès
function DCUO.Database.SaveAchievement(ply, achievementID)
    if not IsValid(ply) then return end
    
    local steamID = ply:SteamID64()
    
    local query = string.format([[
        INSERT OR IGNORE INTO dcuo_achievements (steam_id, achievement_id)
        VALUES ('%s', '%s')
    ]], sql.SQLStr(steamID, true), sql.SQLStr(achievementID, true))
    
    sql.Query(query)
    
    local lastError = sql.LastError()
    if lastError and lastError ~= "" then
        DCUO.Log("Database Error: " .. tostring(lastError), "ERROR")
        return false
    end
    
    return true
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    LOGS ADMIN                                     ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Database.LogAdminAction(admin, action, target, details)
    local query = string.format([[
        INSERT INTO dcuo_admin_logs (
            admin_steam_id, admin_name, action,
            target_steam_id, target_name, details
        ) VALUES (
            '%s', '%s', '%s', '%s', '%s', '%s'
        )
    ]],
        sql.SQLStr(IsValid(admin) and admin:SteamID64() or "CONSOLE", true),
        sql.SQLStr(IsValid(admin) and admin:Nick() or "CONSOLE", true),
        sql.SQLStr(action, true),
        sql.SQLStr(IsValid(target) and target:SteamID64() or "", true),
        sql.SQLStr(IsValid(target) and target:Nick() or "", true),
        sql.SQLStr(details or "", true)
    )
    
    sql.Query(query)
    
    local lastError = sql.LastError()
    if lastError and lastError ~= "" then
        DCUO.Log("Database Log Error: " .. tostring(lastError), "ERROR")
        return false
    end
    
    return true
end

-- Récupérer les logs admin
function DCUO.Database.GetAdminLogs(limit)
    limit = limit or 100
    
    local query = string.format([[
        SELECT * FROM dcuo_admin_logs
        ORDER BY created_at DESC
        LIMIT %d
    ]], limit)
    
    return sql.Query(query) or {}
end

DCUO.Log("Database module loaded", "SUCCESS")

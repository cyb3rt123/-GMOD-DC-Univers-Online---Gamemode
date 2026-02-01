--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Gestion Admin (Server)
    Handlers pour les actions admin
═══════════════════════════════════════════════════════════════════════
--]]

if CLIENT then return end

-- Réseau
util.AddNetworkString("DCUO:ServerAnnounce")

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    VÉRIFIER LES PERMISSIONS                       ║
-- ╚═══════════════════════════════════════════════════════════════════╝

local function IsAdmin(ply)
    if not IsValid(ply) then return false end
    
    -- Vérifier ULX
    if ULib then
        local allowedGroups = DCUO.Config.Admin.AllowedGroups or {"superadmin", "admin"}
        return table.HasValue(allowedGroups, ply:GetUserGroup())
    end
    
    -- Fallback sur superadmin par défaut
    return ply:IsSuperAdmin()
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    HANDLERS D'ACTIONS                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

net.Receive("DCUO:AdminAction", function(len, ply)
    if not IsAdmin(ply) then
        DCUO.Notify(ply, "Vous n'avez pas la permission", DCUO.Colors.Error)
        return
    end
    
    local action = net.ReadString()
    
    if action == "givexp" then
        local target = net.ReadEntity()
        local amount = net.ReadInt(32)
        
        if IsValid(target) then
            DCUO.XP.Give(target, amount, "Admin")
            DCUO.Notify(ply, "XP donnée à " .. target:Nick(), DCUO.Colors.Success)
            
            DCUO.Database.LogAdminAction(ply, "GIVE_XP", target, "Amount: " .. amount)
        end
        
    elseif action == "setlevel" then
        local target = net.ReadEntity()
        local level = net.ReadInt(16)
        
        if IsValid(target) and target.DCUOData then
            target.DCUOData.level = math.Clamp(level, 1, DCUO.Config.MaxLevel)
            target.DCUOData.xp = 0
            target.DCUOData.maxXP = DCUO.XP.CalculateXPNeeded(target.DCUOData.level)
            
            DCUO.Database.SavePlayer(target)
            
            net.Start("DCUO:UpdateLevel")
                net.WriteInt(target.DCUOData.level, 16)
                net.WriteBool(false)
            net.Send(target)
            
            net.Start("DCUO:UpdateXP")
                net.WriteInt(0, 32)
                net.WriteInt(target.DCUOData.maxXP, 32)
            net.Send(target)
            
            DCUO.Notify(ply, "Niveau de " .. target:Nick() .. " défini à " .. level, DCUO.Colors.Success)
            
            DCUO.Database.LogAdminAction(ply, "SET_LEVEL", target, "Level: " .. level)
        end
        
    elseif action == "bring" then
        local target = net.ReadEntity()
        
        if IsValid(target) then
            target:SetPos(ply:GetPos() + ply:GetForward() * 100)
            DCUO.Notify(ply, target:Nick() .. " téléporté", DCUO.Colors.Success)
            DCUO.Notify(target, "Vous avez été téléporté par " .. ply:Nick(), DCUO.Colors.Warning)
            
            DCUO.Database.LogAdminAction(ply, "BRING", target, "")
        end
        
    elseif action == "goto" then
        local target = net.ReadEntity()
        
        if IsValid(target) then
            ply:SetPos(target:GetPos() + target:GetForward() * 100)
            DCUO.Notify(ply, "Téléporté vers " .. target:Nick(), DCUO.Colors.Success)
            
            DCUO.Database.LogAdminAction(ply, "GOTO", target, "")
        end
        
    elseif action == "notify" then
        local message = tostring(net.ReadString() or "")

        if message == "" then return end

        if DCUO.NotifyAll then
            DCUO.NotifyAll("[ADMIN] " .. message, DCUO.Colors.Hero)
        else
            -- Fallback (ne devrait pas arriver), éviter un crash silencieux
            for _, p in ipairs(player.GetAll()) do
                p:ChatPrint("[ADMIN] " .. message)
            end
        end

        if DCUO.Log then
            DCUO.Log("Admin notification: " .. message, "INFO")
        end

        if DCUO.Database and DCUO.Database.LogAdminAction then
            DCUO.Database.LogAdminAction(ply, "NOTIFY", nil, message)
        end

    elseif action == "setjob" then
        local target = net.ReadEntity()
        local jobID = tostring(net.ReadString() or "")

        if not IsValid(target) or not target:IsPlayer() then
            DCUO.Notify(ply, "Joueur invalide", DCUO.Colors.Error)
            return
        end

        if jobID == "" then
            DCUO.Notify(ply, "Job invalide", DCUO.Colors.Error)
            return
        end

        if not (DCUO.Jobs and DCUO.Jobs.SetJob) then
            DCUO.Notify(ply, "Système de jobs non initialisé", DCUO.Colors.Error)
            return
        end

        local ok = DCUO.Jobs.SetJob(target, jobID)
        if ok then
            DCUO.Notify(ply, "Job de " .. target:Nick() .. " défini à " .. jobID, DCUO.Colors.Success)
        else
            DCUO.Notify(ply, "Impossible de définir ce job", DCUO.Colors.Error)
        end

        if DCUO.Database and DCUO.Database.LogAdminAction then
            DCUO.Database.LogAdminAction(ply, "SET_JOB", target, "Job: " .. jobID)
        end
        
    elseif action == "spawnevent" then
        if DCUO.Missions.SpawnRandomEvent then
            DCUO.Missions.SpawnRandomEvent()
            DCUO.Notify(ply, "Événement aléatoire lancé", DCUO.Colors.Success)
            
            DCUO.Database.LogAdminAction(ply, "SPAWN_EVENT", nil, "")
        else
            DCUO.Notify(ply, "Système d'événements non initialisé", DCUO.Colors.Error)
        end
        
    elseif action == "spawnmission" then
        local missionID = net.ReadString()
        
        if DCUO.Missions.Start then
            -- Obtenir un spawn point aléatoire
            local spawn = nil
            if DCUO.Config and DCUO.Config.GetRandomSpawn then
                spawn = DCUO.Config.GetRandomSpawn("combat")
            end
            local position = spawn and spawn.pos or ply:GetPos() + ply:GetForward() * 500
            
            local instanceID = DCUO.Missions.Start(missionID, ply, position)
            
            if instanceID then
                DCUO.Notify(ply, "Mission '" .. missionID .. "' spawnée", DCUO.Colors.Success)
                DCUO.Database.LogAdminAction(ply, "SPAWN_MISSION", nil, missionID)
            else
                DCUO.Notify(ply, "Erreur lors du spawn de la mission", DCUO.Colors.Error)
            end
        else
            DCUO.Notify(ply, "Système de missions non initialisé", DCUO.Colors.Error)
        end
        
    elseif action == "spawnboss" then
        local bossID = net.ReadString()
        
        if DCUO.Bosses and DCUO.Bosses.Spawn then
            local position = ply:GetPos() + ply:GetForward() * 200
            DCUO.Bosses.Spawn(bossID, position)
            DCUO.Notify(ply, "Boss '" .. bossID .. "' spawné", DCUO.Colors.Success)
            DCUO.Database.LogAdminAction(ply, "SPAWN_BOSS", nil, bossID)
        else
            DCUO.Notify(ply, "Système de boss non initialisé", DCUO.Colors.Error)
        end
        
    elseif action == "getposition" then
        -- Envoyer la position au client pour copie
        local pos = ply:GetPos()
        local ang = ply:GetAngles()
        
        net.Start("DCUO:AdminPosition")
            net.WriteVector(pos)
            net.WriteAngle(ang)
        net.Send(ply)
        
    elseif action == "announce" then
        local message = net.ReadString()
        
        if message and message ~= "" then
            print("[DCUO ADMIN] Sending announce: " .. message .. " from " .. ply:Nick())
            
            -- Envoyer l'annonce à tous les joueurs
            net.Start("DCUO:ServerAnnounce")
                net.WriteString(message)
                net.WriteString(ply:Nick()) -- Nom de l'admin
            net.Broadcast()
            
            print("[DCUO ADMIN] Announce broadcast sent to all players")
            
            -- Log
            if DCUO.Database and DCUO.Database.LogAdminAction then
                DCUO.Database.LogAdminAction(ply, "ANNOUNCE", nil, "Message: " .. message)
            end
            
            if DCUO.Log then
                DCUO.Log("[ANNOUNCE] " .. ply:Nick() .. ": " .. message, "INFO")
            end
            
            -- Notification à l'admin
            DCUO.Notify(ply, "Annonce envoyée à tous les joueurs", DCUO.Colors.Success)
        else
            DCUO.Notify(ply, "Message vide, annonce non envoyée", DCUO.Colors.Error)
        end
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    COMMANDE POUR OUVRIR LE PANEL                  ║
-- ╚═══════════════════════════════════════════════════════════════════╝

if ULib then
    function ulx.dcuoadmin(calling_ply)
        if not IsAdmin(calling_ply) then
            ULib.tsayError(calling_ply, "Vous n'avez pas la permission", true)
            return
        end
        
        net.Start("DCUO:AdminPanel")
        net.Send(calling_ply)
    end
    
    local dcuoadmin = ulx.command("DCUO", "ulx dcuoadmin", ulx.dcuoadmin, "!dcuoadmin")
    dcuoadmin:defaultAccess(ULib.ACCESS_ADMIN)
    dcuoadmin:help("Ouvrir le panel admin DCUO")
end

DCUO.Log("Admin system (server) loaded", "SUCCESS")

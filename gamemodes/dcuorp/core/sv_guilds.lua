--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Guildes (Server)
    Gestion serveur des guildes
═══════════════════════════════════════════════════════════════════════
--]]

if CLIENT then return end

util.AddNetworkString("DCUO:Guild:Create")
util.AddNetworkString("DCUO:Guild:Invite")
util.AddNetworkString("DCUO:Guild:AcceptInvite")
util.AddNetworkString("DCUO:Guild:Kick")
util.AddNetworkString("DCUO:Guild:Leave")
util.AddNetworkString("DCUO:Guild:Promote")
util.AddNetworkString("DCUO:Guild:Demote")
util.AddNetworkString("DCUO:Guild:Disband")
util.AddNetworkString("DCUO:Guild:UpdateInfo")
util.AddNetworkString("DCUO:Guild:Sync")
util.AddNetworkString("DCUO:Guild:Chat")
util.AddNetworkString("DCUO:Guild:OpenMenu")

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CRÉATION DE GUILDE                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Guilds.Create(ply, name, tag, description)
    local steamID = ply:SteamID()
    
    -- Vérifications
    if DCUO.Guilds.GetPlayerGuild(steamID) then
        return false, "Vous êtes déjà dans une guilde"
    end
    
    if ply.DCUOData.level < DCUO.Guilds.Config.LevelRequirement then
        return false, "Niveau " .. DCUO.Guilds.Config.LevelRequirement .. " requis"
    end
    
    if #name < DCUO.Guilds.Config.MinNameLength or #name > DCUO.Guilds.Config.MaxNameLength then
        return false, "Nom invalide (3-30 caractères)"
    end
    
    -- Vérifier si le nom existe déjà
    for id, guild in pairs(DCUO.Guilds.List) do
        if string.lower(guild.name) == string.lower(name) then
            return false, "Ce nom est déjà pris"
        end
    end
    
    -- Créer la guilde
    local guildID = "guild_" .. steamID .. "_" .. os.time()
    
    DCUO.Guilds.List[guildID] = {
        id = guildID,
        name = name,
        tag = tag or "",
        description = description or "",
        leader = steamID,
        faction = ply.DCUOData.faction or "Neutral",
        created = os.time(),
        
        members = {
            [steamID] = {
                steamID = steamID,
                name = ply:Nick(),
                rank = 1,  -- Leader
                joined = os.time(),
                level = ply.DCUOData.level or 1,
                contribution = 0,
            }
        },
        
        stats = {
            totalXP = 0,
            totalKills = 0,
            totalMissions = 0,
        },
        
        bank = {
            money = 0,
            items = {},
        },
        
        settings = {
            color = Color(255, 255, 255),
            logo = "",
            public = true,
            recruitmentMessage = "",
        }
    }
    
    DCUO.Guilds.Save()
    DCUO.Guilds.SyncAll()
    
    DCUO.Log("[GUILDES] " .. ply:Nick() .. " a créé la guilde: " .. name, "SUCCESS")
    return true, "Guilde créée avec succès!"
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    INVITATION                                     ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Guilds.Invite(ply, targetPly)
    local steamID = ply:SteamID()
    local targetSteamID = targetPly:SteamID()
    local guildID, guild = DCUO.Guilds.GetPlayerGuild(steamID)
    
    if not guild then
        return false, "Vous n'êtes pas dans une guilde"
    end
    
    if not DCUO.Guilds.HasPermission(guildID, steamID, "invite") then
        return false, "Vous n'avez pas la permission d'inviter"
    end
    
    if DCUO.Guilds.GetPlayerGuild(targetSteamID) then
        return false, targetPly:Nick() .. " est déjà dans une guilde"
    end
    
    if DCUO.Guilds.GetMemberCount(guildID) >= DCUO.Guilds.Config.MaxMembers then
        return false, "La guilde est pleine"
    end
    
    -- Stocker l'invitation
    targetPly.GuildInvite = {
        guildID = guildID,
        inviter = ply:Nick(),
        time = CurTime()
    }
    
    targetPly:ChatPrint("[GUILDE] Vous avez été invité dans " .. guild.name .. " par " .. ply:Nick())
    targetPly:ChatPrint("[GUILDE] Tapez !accepterguilde pour accepter (expire dans 60s)")
    
    return true, "Invitation envoyée à " .. targetPly:Nick()
end

function DCUO.Guilds.AcceptInvite(ply)
    if not ply.GuildInvite then
        return false, "Aucune invitation en attente"
    end
    
    if CurTime() - ply.GuildInvite.time > 60 then
        ply.GuildInvite = nil
        return false, "Invitation expirée"
    end
    
    local guildID = ply.GuildInvite.guildID
    local guild = DCUO.Guilds.GetGuild(guildID)
    
    if not guild then
        ply.GuildInvite = nil
        return false, "Cette guilde n'existe plus"
    end
    
    local steamID = ply:SteamID()
    
    guild.members[steamID] = {
        steamID = steamID,
        name = ply:Nick(),
        rank = 3,  -- Member
        joined = os.time(),
        level = ply.DCUOData.level or 1,
        contribution = 0,
    }
    
    ply.GuildInvite = nil
    DCUO.Guilds.Save()
    DCUO.Guilds.SyncAll()
    DCUO.Guilds.BroadcastToGuild(guildID, ply:Nick() .. " a rejoint la guilde!")
    
    return true, "Vous avez rejoint " .. guild.name
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    GESTION DES MEMBRES                            ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Guilds.Kick(ply, targetSteamID)
    local steamID = ply:SteamID()
    local guildID, guild = DCUO.Guilds.GetPlayerGuild(steamID)
    
    if not guild then return false, "Vous n'êtes pas dans une guilde" end
    if not DCUO.Guilds.HasPermission(guildID, steamID, "kick") then
        return false, "Vous n'avez pas la permission d'expulser"
    end
    
    if not guild.members[targetSteamID] then
        return false, "Ce joueur n'est pas dans votre guilde"
    end
    
    if targetSteamID == guild.leader then
        return false, "Impossible d'expulser le leader"
    end
    
    local targetName = guild.members[targetSteamID].name
    guild.members[targetSteamID] = nil
    
    DCUO.Guilds.Save()
    DCUO.Guilds.SyncAll()
    DCUO.Guilds.BroadcastToGuild(guildID, targetName .. " a été expulsé de la guilde")
    
    return true, targetName .. " a été expulsé"
end

function DCUO.Guilds.Leave(ply)
    local steamID = ply:SteamID()
    local guildID, guild = DCUO.Guilds.GetPlayerGuild(steamID)
    
    if not guild then return false, "Vous n'êtes pas dans une guilde" end
    
    if steamID == guild.leader then
        return false, "Le leader ne peut pas quitter (utilisez !dissoudre)"
    end
    
    local name = guild.members[steamID].name
    guild.members[steamID] = nil
    
    DCUO.Guilds.Save()
    DCUO.Guilds.SyncAll()
    DCUO.Guilds.BroadcastToGuild(guildID, name .. " a quitté la guilde")
    
    return true, "Vous avez quitté la guilde"
end

function DCUO.Guilds.Promote(ply, targetSteamID)
    local steamID = ply:SteamID()
    local guildID, guild = DCUO.Guilds.GetPlayerGuild(steamID)
    
    if not guild then return false, "Vous n'êtes pas dans une guilde" end
    if not DCUO.Guilds.HasPermission(guildID, steamID, "promote") then
        return false, "Vous n'avez pas la permission de promouvoir"
    end
    
    local member = guild.members[targetSteamID]
    if not member then return false, "Membre introuvable" end
    if member.rank <= 1 then return false, "Rang maximum atteint" end
    
    member.rank = member.rank - 1
    
    DCUO.Guilds.Save()
    DCUO.Guilds.SyncAll()
    
    local rank = DCUO.Guilds.GetRank(member.rank)
    DCUO.Guilds.BroadcastToGuild(guildID, member.name .. " a été promu " .. rank.name)
    
    return true, member.name .. " promu " .. rank.name
end

function DCUO.Guilds.Demote(ply, targetSteamID)
    local steamID = ply:SteamID()
    local guildID, guild = DCUO.Guilds.GetPlayerGuild(steamID)
    
    if not guild then return false, "Vous n'êtes pas dans une guilde" end
    if not DCUO.Guilds.HasPermission(guildID, steamID, "demote") then
        return false, "Vous n'avez pas la permission de rétrograder"
    end
    
    local member = guild.members[targetSteamID]
    if not member then return false, "Membre introuvable" end
    if member.rank >= 3 then return false, "Rang minimum atteint" end
    if targetSteamID == guild.leader then return false, "Impossible de rétrograder le leader" end
    
    member.rank = member.rank + 1
    
    DCUO.Guilds.Save()
    DCUO.Guilds.SyncAll()
    
    local rank = DCUO.Guilds.GetRank(member.rank)
    DCUO.Guilds.BroadcastToGuild(guildID, member.name .. " a été rétrogradé " .. rank.name)
    
    return true, member.name .. " rétrogradé " .. rank.name
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    DISSOLUTION                                    ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Guilds.Disband(ply)
    local steamID = ply:SteamID()
    local guildID, guild = DCUO.Guilds.GetPlayerGuild(steamID)
    
    if not guild then return false, "Vous n'êtes pas dans une guilde" end
    if not DCUO.Guilds.HasPermission(guildID, steamID, "disband") then
        return false, "Seul le leader peut dissoudre la guilde"
    end
    
    local guildName = guild.name
    DCUO.Guilds.List[guildID] = nil
    
    DCUO.Guilds.Save()
    DCUO.Guilds.SyncAll()
    
    DCUO.Log("[GUILDES] " .. ply:Nick() .. " a dissous la guilde: " .. guildName, "WARNING")
    return true, "Guilde dissoute"
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CHAT DE GUILDE                                 ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Guilds.BroadcastToGuild(guildID, message)
    local guild = DCUO.Guilds.GetGuild(guildID)
    if not guild then return end
    
    for steamID, member in pairs(guild.members) do
        local ply = player.GetBySteamID(steamID)
        if IsValid(ply) then
            ply:ChatPrint("[GUILDE] " .. message)
        end
    end
end

function DCUO.Guilds.SendGuildChat(ply, message)
    local steamID = ply:SteamID()
    local guildID, guild = DCUO.Guilds.GetPlayerGuild(steamID)
    
    if not guild then return false end
    
    local member = guild.members[steamID]
    local rank = DCUO.Guilds.GetRank(member.rank)
    
    for sid, mem in pairs(guild.members) do
        local p = player.GetBySteamID(sid)
        if IsValid(p) then
            p:ChatPrint("[" .. guild.tag .. "] " .. rank.name .. " " .. ply:Nick() .. ": " .. message)
        end
    end
    
    return true
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    SAUVEGARDE & SYNCHRONISATION                   ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Guilds.Save()
    file.Write("dcuo/guilds.txt", util.TableToJSON(DCUO.Guilds.List, true))
    DCUO.Log("[GUILDES] Données sauvegardées", "SUCCESS")
end

function DCUO.Guilds.Load()
    if not file.Exists("dcuo/guilds.txt", "DATA") then
        DCUO.Log("[GUILDES] Aucune donnée à charger", "INFO")
        return
    end
    
    local data = file.Read("dcuo/guilds.txt", "DATA")
    DCUO.Guilds.List = util.JSONToTable(data) or {}
    
    DCUO.Log("[GUILDES] " .. table.Count(DCUO.Guilds.List) .. " guildes chargées", "SUCCESS")
end

function DCUO.Guilds.SyncAll()
    net.Start("DCUO:Guild:Sync")
        net.WriteTable(DCUO.Guilds.List)
    net.Broadcast()
end

function DCUO.Guilds.SyncPlayer(ply)
    net.Start("DCUO:Guild:Sync")
        net.WriteTable(DCUO.Guilds.List)
    net.Send(ply)
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    NETWORK RECEIVERS                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

net.Receive("DCUO:Guild:Create", function(len, ply)
    local name = net.ReadString()
    local tag = net.ReadString()
    local desc = net.ReadString()
    
    local success, msg = DCUO.Guilds.Create(ply, name, tag, desc)
    ply:ChatPrint("[GUILDE] " .. msg)
end)

net.Receive("DCUO:Guild:Invite", function(len, ply)
    local targetPly = net.ReadEntity()
    if not IsValid(targetPly) then return end
    
    local success, msg = DCUO.Guilds.Invite(ply, targetPly)
    ply:ChatPrint("[GUILDE] " .. msg)
end)

net.Receive("DCUO:Guild:Kick", function(len, ply)
    local targetSteamID = net.ReadString()
    
    local success, msg = DCUO.Guilds.Kick(ply, targetSteamID)
    ply:ChatPrint("[GUILDE] " .. msg)
end)

net.Receive("DCUO:Guild:Promote", function(len, ply)
    local targetSteamID = net.ReadString()
    
    local success, msg = DCUO.Guilds.Promote(ply, targetSteamID)
    ply:ChatPrint("[GUILDE] " .. msg)
end)

net.Receive("DCUO:Guild:Demote", function(len, ply)
    local targetSteamID = net.ReadString()
    
    local success, msg = DCUO.Guilds.Demote(ply, targetSteamID)
    ply:ChatPrint("[GUILDE] " .. msg)
end)

net.Receive("DCUO:Guild:Chat", function(len, ply)
    local message = net.ReadString()
    DCUO.Guilds.SendGuildChat(ply, message)
end)

-- Charger les guildes au démarrage
hook.Add("Initialize", "DCUO:LoadGuilds", function()
    DCUO.Guilds.Load()
end)

-- Sync joueur à la connexion
hook.Add("PlayerInitialSpawn", "DCUO:SyncGuilds", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) then
            DCUO.Guilds.SyncPlayer(ply)
        end
    end)
end)

-- Sauvegarder périodiquement
timer.Create("DCUO:SaveGuilds", 300, 0, function()
    DCUO.Guilds.Save()
end)

DCUO.Log("Guilds System (Server) Loaded", "SUCCESS")

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FRIENDS SYSTEM (SERVER)                        ║
-- ║         Système d'amis avec stockage en base de données          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

if CLIENT then return end

DCUO.Friends = DCUO.Friends or {}

-- Network strings
util.AddNetworkString("DCUO_SendFriendRequest")
util.AddNetworkString("DCUO_FriendRequest")
util.AddNetworkString("DCUO_FriendAdded")
util.AddNetworkString("DCUO_RemoveFriend")
util.AddNetworkString("DCUO_FriendRemoved")
util.AddNetworkString("DCUO_SyncFriends")

local pendingFriendRequests = {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     BASE DE DONNÉES                               ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Créer la table des amis
function DCUO.Friends.CreateTable()
    if not sql.TableExists("dcuo_friends") then
        sql.Query([[
            CREATE TABLE dcuo_friends (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                player_steamid TEXT NOT NULL,
                friend_steamid TEXT NOT NULL,
                friend_name TEXT NOT NULL,
                added_date INTEGER NOT NULL,
                UNIQUE(player_steamid, friend_steamid)
            )
        ]])
        
        DCUO.Log("Table dcuo_friends created", "SUCCESS")
    end
end

-- Charger les amis d'un joueur
function DCUO.Friends.Load(ply)
    if not IsValid(ply) then return {} end
    
    local steamID = ply:SteamID64()
    local query = sql.Query("SELECT * FROM dcuo_friends WHERE player_steamid = " .. sql.SQLStr(steamID))
    
    return query or {}
end

-- Ajouter un ami
function DCUO.Friends.Add(ply, friendSteamID, friendName)
    if not IsValid(ply) then return false end
    
    local steamID = ply:SteamID64()
    local timestamp = os.time()
    
    -- Ajouter dans les deux sens (relation bidirectionnelle)
    local query1 = sql.Query(string.format(
        "INSERT OR IGNORE INTO dcuo_friends (player_steamid, friend_steamid, friend_name, added_date) VALUES (%s, %s, %s, %d)",
        sql.SQLStr(steamID),
        sql.SQLStr(friendSteamID),
        sql.SQLStr(friendName),
        timestamp
    ))
    
    local query2 = sql.Query(string.format(
        "INSERT OR IGNORE INTO dcuo_friends (player_steamid, friend_steamid, friend_name, added_date) VALUES (%s, %s, %s, %d)",
        sql.SQLStr(friendSteamID),
        sql.SQLStr(steamID),
        sql.SQLStr(ply:Nick()),
        timestamp
    ))
    
    if query1 == false or query2 == false then
        DCUO.Log("Failed to add friend: " .. sql.LastError(), "ERROR")
        return false
    end
    
    DCUO.Log(ply:Nick() .. " added " .. friendName .. " as friend", "INFO")
    return true
end

-- Retirer un ami
function DCUO.Friends.Remove(ply, friendSteamID)
    if not IsValid(ply) then return false end
    
    local steamID = ply:SteamID64()
    
    -- Supprimer dans les deux sens
    sql.Query(string.format(
        "DELETE FROM dcuo_friends WHERE player_steamid = %s AND friend_steamid = %s",
        sql.SQLStr(steamID),
        sql.SQLStr(friendSteamID)
    ))
    
    sql.Query(string.format(
        "DELETE FROM dcuo_friends WHERE player_steamid = %s AND friend_steamid = %s",
        sql.SQLStr(friendSteamID),
        sql.SQLStr(steamID)
    ))
    
    DCUO.Log(ply:Nick() .. " removed friend " .. friendSteamID, "INFO")
    return true
end

-- Vérifier si deux joueurs sont amis
function DCUO.Friends.AreFriends(steamID1, steamID2)
    local query = sql.Query(string.format(
        "SELECT * FROM dcuo_friends WHERE player_steamid = %s AND friend_steamid = %s",
        sql.SQLStr(steamID1),
        sql.SQLStr(steamID2)
    ))
    
    return query and #query > 0
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     DEMANDES D'AMITIÉ                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

net.Receive("DCUO_SendFriendRequest", function(len, requester)
    local target = net.ReadEntity()
    
    if not IsValid(requester) or not IsValid(target) then return end
    if requester == target then return end
    if not target:IsPlayer() then return end
    
    -- Vérifier s'ils sont déjà amis
    if DCUO.Friends.AreFriends(requester:SteamID64(), target:SteamID64()) then
        DCUO.Notify(requester, "Vous êtes déjà amis avec " .. target:Nick(), DCUO.Colors.Warning)
        return
    end
    
    -- Créer la demande
    local requestID = requester:SteamID64() .. "_" .. target:SteamID64()
    pendingFriendRequests[requestID] = {
        requester = requester,
        target = target,
        time = CurTime()
    }
    
    -- Envoyer au target
    net.Start("DCUO_FriendRequest")
    net.WriteEntity(requester)
    net.WriteString(requestID)
    net.Send(target)
    
    DCUO.Notify(requester, "Demande d'ami envoyée à " .. target:Nick(), DCUO.Colors.Info)
    DCUO.Log(requester:Nick() .. " sent friend request to " .. target:Nick(), "INFO")
end)

-- Accepter une demande d'ami
concommand.Add("dcuo_accept_friend", function(ply, cmd, args)
    if #args < 1 then return end
    
    local requestID = args[1]
    local request = pendingFriendRequests[requestID]
    
    if not request then return end
    
    local requester = request.requester
    local target = request.target
    
    if not IsValid(requester) or not IsValid(target) then
        pendingFriendRequests[requestID] = nil
        return
    end
    
    -- Ajouter l'amitié
    if DCUO.Friends.Add(requester, target:SteamID64(), target:Nick()) then
        -- Notifier les deux joueurs
        DCUO.Notify(requester, target:Nick() .. " a accepté votre demande d'ami !", DCUO.Colors.Success)
        DCUO.Notify(target, "Vous êtes maintenant ami avec " .. requester:Nick(), DCUO.Colors.Success)
        
        -- Envoyer la mise à jour
        net.Start("DCUO_FriendAdded")
        net.WriteString(target:SteamID64())
        net.WriteString(target:Nick())
        net.Send(requester)
        
        net.Start("DCUO_FriendAdded")
        net.WriteString(requester:SteamID64())
        net.WriteString(requester:Nick())
        net.Send(target)
    end
    
    pendingFriendRequests[requestID] = nil
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     RETIRER UN AMI                                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

net.Receive("DCUO_RemoveFriend", function(len, ply)
    local friendSteamID = net.ReadString()
    
    if DCUO.Friends.Remove(ply, friendSteamID) then
        DCUO.Notify(ply, "Ami retiré de votre liste", DCUO.Colors.Info)
        
        -- Notifier le client
        net.Start("DCUO_FriendRemoved")
        net.WriteString(friendSteamID)
        net.Send(ply)
        
        -- Notifier l'autre joueur s'il est connecté
        for _, p in ipairs(player.GetAll()) do
            if p:SteamID64() == friendSteamID then
                DCUO.Notify(p, ply:Nick() .. " vous a retiré de sa liste d'amis", DCUO.Colors.Warning)
                
                net.Start("DCUO_FriendRemoved")
                net.WriteString(ply:SteamID64())
                net.Send(p)
                break
            end
        end
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     SYNCHRONISATION                               ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Envoyer la liste d'amis au joueur
function DCUO.Friends.SyncToClient(ply)
    if not IsValid(ply) then return end
    
    local friends = DCUO.Friends.Load(ply)
    
    net.Start("DCUO_SyncFriends")
    net.WriteUInt(#friends, 16)
    
    for _, friend in ipairs(friends) do
        net.WriteString(friend.friend_steamid)
        net.WriteString(friend.friend_name)
        net.WriteUInt(friend.added_date, 32)
    end
    
    net.Send(ply)
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                          HOOKS                                    ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Créer la table au démarrage
hook.Add("Initialize", "DCUO_Friends_CreateTable", function()
    DCUO.Friends.CreateTable()
end)

-- Sync au spawn
hook.Add("PlayerInitialSpawn", "DCUO_Friends_Sync", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) then
            DCUO.Friends.SyncToClient(ply)
        end
    end)
end)

-- Nettoyer les demandes expirées (toutes les minutes)
timer.Create("DCUO_Friends_CleanupRequests", 60, 0, function()
    for id, request in pairs(pendingFriendRequests) do
        if CurTime() - request.time > 300 then -- 5 minutes
            pendingFriendRequests[id] = nil
        end
    end
end)

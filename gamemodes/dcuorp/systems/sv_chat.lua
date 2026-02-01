--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Chat Avancé (Server)
    Gestion serveur des messages
═══════════════════════════════════════════════════════════════════════
--]]

if CLIENT then return end

util.AddNetworkString("DCUO:Chat:Message")
util.AddNetworkString("DCUO:Chat:PM")

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    ANTI-SPAM                                      ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Chat.LastMessage = {}

function DCUO.Chat.CheckSpam(ply)
    local steamID = ply:SteamID()
    local lastTime = DCUO.Chat.LastMessage[steamID] or 0
    
    if CurTime() - lastTime < DCUO.Chat.Config.AntiSpamDelay then
        return false
    end
    
    DCUO.Chat.LastMessage[steamID] = CurTime()
    return true
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    ENVOI DE MESSAGES                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Chat.SendMessage(ply, channelID, message)
    if not IsValid(ply) then return false end
    
    local channel = DCUO.Chat.GetChannel(channelID)
    if not channel or not channel.enabled then
        ply:ChatPrint("[CHAT] Ce canal n'est pas disponible.")
        return false
    end
    
    -- Vérifier les permissions
    if channel.permission then
        if channel.permission == "admin" and not ply:IsAdmin() then
            ply:ChatPrint("[CHAT] Vous n'avez pas accès à ce canal.")
            return false
        elseif channel.permission == "faction" then
            if not ply.DCUOData or not ply.DCUOData.faction or ply.DCUOData.faction == "Neutral" then
                ply:ChatPrint("[CHAT] Vous devez être dans une faction.")
                return false
            end
        elseif channel.permission == "guild" then
            local guildID = DCUO.Guilds.GetPlayerGuild(ply:SteamID())
            if not guildID then
                ply:ChatPrint("[CHAT] Vous devez être dans une guilde.")
                return false
            end
        end
    end
    
    -- Anti-spam
    if not DCUO.Chat.CheckSpam(ply) then
        ply:ChatPrint("[CHAT] Veuillez patienter avant d'envoyer un nouveau message.")
        return false
    end
    
    -- Filtrer le message
    message = string.Trim(message)
    if #message == 0 then return false end
    if #message > DCUO.Chat.Config.MaxMessageLength then
        message = string.sub(message, 1, DCUO.Chat.Config.MaxMessageLength)
    end
    
    message = DCUO.Chat.FilterBadWords(message)
    
    -- Déterminer les destinataires
    local recipients = {}
    
    if channel.range == 0 then
        -- Chat global ou spécial
        if channelID == "admin" then
            -- Seulement les admins
            for _, p in ipairs(player.GetAll()) do
                if p:IsAdmin() then
                    table.insert(recipients, p)
                end
            end
        elseif channelID == "faction" then
            -- Seulement la même faction
            local faction = ply.DCUOData.faction
            for _, p in ipairs(player.GetAll()) do
                if p.DCUOData and p.DCUOData.faction == faction then
                    table.insert(recipients, p)
                end
            end
        elseif channelID == "guild" then
            -- Seulement la même guilde
            local guildID = DCUO.Guilds.GetPlayerGuild(ply:SteamID())
            local guild = DCUO.Guilds.GetGuild(guildID)
            if guild then
                for steamID, _ in pairs(guild.members) do
                    local p = player.GetBySteamID(steamID)
                    if IsValid(p) then
                        table.insert(recipients, p)
                    end
                end
            end
        else
            -- Tous les joueurs
            recipients = player.GetAll()
        end
    else
        -- Chat de proximité
        for _, p in ipairs(player.GetAll()) do
            if p:GetPos():Distance(ply:GetPos()) <= channel.range then
                table.insert(recipients, p)
            end
        end
    end
    
    -- Envoyer le message
    if #recipients > 0 then
        net.Start("DCUO:Chat:Message")
            net.WriteString(channelID)
            net.WriteEntity(ply)
            net.WriteString(message)
            net.WriteBool(false) -- Pas un MP
        net.Send(recipients)
        
        -- Log serveur
        DCUO.Log("[CHAT/" .. channelID:upper() .. "] " .. ply:Nick() .. ": " .. message, "INFO")
    end
    
    return true
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    MESSAGES PRIVÉS                                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Chat.SendPM(sender, targetName, message)
    if not IsValid(sender) then return false end
    
    -- Trouver le joueur cible
    local target = nil
    for _, ply in ipairs(player.GetAll()) do
        if string.lower(ply:Nick()) == string.lower(targetName) or 
           (ply.DCUOData and string.lower(ply.DCUOData.rpname or "") == string.lower(targetName)) then
            target = ply
            break
        end
    end
    
    if not IsValid(target) then
        sender:ChatPrint("[MP] Joueur introuvable: " .. targetName)
        return false
    end
    
    if target == sender then
        sender:ChatPrint("[MP] Vous ne pouvez pas vous envoyer de message à vous-même.")
        return false
    end
    
    -- Anti-spam
    if not DCUO.Chat.CheckSpam(sender) then
        sender:ChatPrint("[CHAT] Veuillez patienter avant d'envoyer un nouveau message.")
        return false
    end
    
    -- Filtrer
    message = string.Trim(message)
    if #message == 0 then return false end
    if #message > DCUO.Chat.Config.MaxMessageLength then
        message = string.sub(message, 1, DCUO.Chat.Config.MaxMessageLength)
    end
    
    message = DCUO.Chat.FilterBadWords(message)
    
    -- Envoyer au destinataire
    net.Start("DCUO:Chat:PM")
        net.WriteEntity(sender)
        net.WriteString(message)
        net.WriteBool(false) -- Reçu
    net.Send(target)
    
    -- Confirmation à l'envoyeur
    net.Start("DCUO:Chat:PM")
        net.WriteEntity(target)
        net.WriteString(message)
        net.WriteBool(true) -- Envoyé
    net.Send(sender)
    
    -- Log
    DCUO.Log("[PM] " .. sender:Nick() .. " → " .. target:Nick() .. ": " .. message, "INFO")
    
    return true
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    INTERCEPTION DU CHAT                           ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("PlayerSay", "DCUO:Chat:PlayerSay", function(ply, text, teamChat)
    text = string.Trim(text)
    
    -- Commandes de chat
    if string.StartWith(text, "/") then
        local args = string.Explode(" ", text)
        local cmd = args[1]:lower()
        
        -- Message privé
        if cmd == "/pm" or cmd == "/mp" or cmd == "/msg" then
            if #args < 3 then
                ply:ChatPrint("[MP] Usage: /pm <joueur> <message>")
                return ""
            end
            
            local targetName = args[2]
            local message = string.Trim(string.sub(text, #args[1] + #args[2] + 3))
            
            DCUO.Chat.SendPM(ply, targetName, message)
            return ""
        end
        
        -- Vérifier si c'est une commande de canal
        local channel = DCUO.Chat.GetChannelByCommand(cmd)
        if channel then
            local message = string.Trim(string.sub(text, #cmd + 2))
            if #message > 0 then
                DCUO.Chat.SendMessage(ply, channel.id, message)
            else
                ply:ChatPrint("[CHAT] Usage: " .. cmd .. " <message>")
            end
            return ""
        end
        
        -- Commande help
        if cmd == "/help" or cmd == "/aide" then
            ply:ChatPrint("═══ COMMANDES DE CHAT ═══")
            for _, ch in ipairs(DCUO.Chat.Channels) do
                if not ch.permission or ch.permission == "faction" or ch.permission == "guild" or (ch.permission == "admin" and ply:IsAdmin()) then
                    ply:ChatPrint(ch.icon .. " " .. ch.command .. " - " .. ch.description)
                end
            end
            ply:ChatPrint("💌 /pm <joueur> <message> - Message privé")
            return ""
        end
    end
    
    -- Message normal (local par défaut)
    DCUO.Chat.SendMessage(ply, DCUO.Chat.Config.DefaultChannel, text)
    
    return ""
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    COMMANDES ADMIN                                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

concommand.Add("dcuo_chat_mute", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    if #args < 1 then
        ply:ChatPrint("Usage: dcuo_chat_mute <joueur>")
        return
    end
    
    local target = nil
    for _, p in ipairs(player.GetAll()) do
        if string.lower(p:Nick()):find(string.lower(args[1])) then
            target = p
            break
        end
    end
    
    if not IsValid(target) then
        ply:ChatPrint("Joueur introuvable")
        return
    end
    
    target.ChatMuted = not target.ChatMuted
    
    if target.ChatMuted then
        ply:ChatPrint("[V] " .. target:Nick() .. " a été mute")
        target:ChatPrint("[ADMIN] Vous avez été mute par " .. ply:Nick())
    else
        ply:ChatPrint("[V] " .. target:Nick() .. " a été unmute")
        target:ChatPrint("[ADMIN] Vous avez été unmute par " .. ply:Nick())
    end
end)

-- Bloquer les messages des joueurs mute
hook.Add("PlayerSay", "DCUO:Chat:CheckMute", function(ply, text)
    if ply.ChatMuted then
        ply:ChatPrint("[CHAT] Vous êtes actuellement mute.")
        return ""
    end
end)

DCUO.Log("Chat System (Server) Loaded", "SUCCESS")

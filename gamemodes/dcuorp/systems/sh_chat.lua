--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Chat Avancé (Shared)
    Configuration et canaux de chat
═══════════════════════════════════════════════════════════════════════
--]]

DCUO.Chat = DCUO.Chat or {}
DCUO.Chat.Config = {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CANAUX DE CHAT                                 ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Chat.Channels = {
    {
        id = "global",
        name = "Global",
        prefix = "[GLOBAL]",
        color = Color(100, 150, 255),
        icon = "🌍",
        command = "/g",
        description = "Chat visible par tous les joueurs",
        range = 0, -- 0 = illimité
        enabled = true,
    },
    {
        id = "local",
        name = "Local",
        prefix = "[LOCAL]",
        color = Color(200, 200, 200),
        icon = "💬",
        command = "/l",
        description = "Chat de proximité (300 unités)",
        range = 300,
        enabled = true,
    },
    {
        id = "yell",
        name = "Crier",
        prefix = "[CRIE]",
        color = Color(255, 100, 100),
        icon = "📢",
        command = "/y",
        description = "Crier (600 unités)",
        range = 600,
        enabled = true,
    },
    {
        id = "whisper",
        name = "Chuchoter",
        prefix = "[CHUCHOTE]",
        color = Color(150, 150, 150),
        icon = "🤫",
        command = "/w",
        description = "Chuchoter (100 unités)",
        range = 100,
        enabled = true,
    },
    {
        id = "faction",
        name = "Faction",
        prefix = "[FACTION]",
        color = Color(255, 165, 0),
        icon = "⚔",
        command = "/f",
        description = "Chat de votre faction uniquement",
        range = 0,
        enabled = true,
        permission = "faction", -- Doit être dans une faction
    },
    {
        id = "guild",
        name = "Guilde",
        prefix = "[GUILDE]",
        color = Color(100, 255, 100),
        icon = "🏛",
        command = "/gu",
        description = "Chat de votre guilde",
        range = 0,
        enabled = true,
        permission = "guild", -- Doit être dans une guilde
    },
    {
        id = "ooc",
        name = "Hors RP",
        prefix = "[HRP]",
        color = Color(180, 180, 180),
        icon = "💭",
        command = "/ooc",
        description = "Chat hors roleplay",
        range = 0,
        enabled = true,
    },
    {
        id = "admin",
        name = "Admin",
        prefix = "[ADMIN]",
        color = Color(255, 50, 50),
        icon = "👑",
        command = "/a",
        description = "Chat des administrateurs",
        range = 0,
        enabled = true,
        permission = "admin", -- Admin uniquement
    },
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CONFIGURATION                                  ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Chat.Config.MaxMessageLength = 200
DCUO.Chat.Config.AntiSpamDelay = 1 -- Secondes entre messages
DCUO.Chat.Config.MaxHistoryLines = 100
DCUO.Chat.Config.DefaultChannel = "local"
DCUO.Chat.Config.ShowTimestamp = true
DCUO.Chat.Config.ShowPlayerTag = true -- Afficher [Niveau X] etc
DCUO.Chat.Config.EnableSounds = true
DCUO.Chat.Config.FadeTime = 10 -- Temps avant disparition du message (HUD)

-- Liste de mots interdits (à personnaliser)
DCUO.Chat.Config.BadWords = {
    -- Ajoutez vos mots interdits ici
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONCTIONS UTILITAIRES                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Chat.GetChannel(channelID)
    for _, channel in ipairs(DCUO.Chat.Channels) do
        if channel.id == channelID then
            return channel
        end
    end
    return nil
end

function DCUO.Chat.GetChannelByCommand(command)
    for _, channel in ipairs(DCUO.Chat.Channels) do
        if channel.command == command then
            return channel
        end
    end
    return nil
end

function DCUO.Chat.IsChannelEnabled(channelID)
    local channel = DCUO.Chat.GetChannel(channelID)
    return channel and channel.enabled or false
end

function DCUO.Chat.FilterBadWords(text)
    local filtered = text
    
    for _, word in ipairs(DCUO.Chat.Config.BadWords) do
        local pattern = word:lower()
        filtered = string.gsub(filtered:lower(), pattern, string.rep("*", #word))
    end
    
    return filtered
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FORMATAGE DES MESSAGES                         ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Chat.FormatPlayerName(ply)
    if not IsValid(ply) then return "Unknown" end
    
    local name = ply.DCUOData and ply.DCUOData.rpname or ply:Nick()
    
    if DCUO.Chat.Config.ShowPlayerTag then
        local level = ply.DCUOData and ply.DCUOData.level or 1
        local job = ply.DCUOData and ply.DCUOData.job or "Recrue"
        return "[Niv." .. level .. "] " .. name
    end
    
    return name
end

function DCUO.Chat.GetPlayerColor(ply)
    if not IsValid(ply) then return Color(255, 255, 255) end
    
    -- Couleur selon la faction
    if ply.DCUOData and ply.DCUOData.faction then
        local faction = DCUO.Factions.Get(ply.DCUOData.faction)
        if faction then
            return faction.color
        end
    end
    
    return Color(255, 255, 255)
end

DCUO.Log("Chat System (Shared) Loaded", "SUCCESS")

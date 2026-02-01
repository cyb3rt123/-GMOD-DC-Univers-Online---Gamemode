--[[
═══════════════════════════════════════════════════════════════════════
    DC UNIVERSE ONLINE ROLEPLAY (DCUO-RP)
    Gamemode par [Votre Nom]
    Version 1.0.0
    
    Un gamemode Garry's Mod immersif inspiré de DC Universe Online
═══════════════════════════════════════════════════════════════════════
--]]

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     DÉFINITION DU GAMEMODE                        ║
-- ╚═══════════════════════════════════════════════════════════════════╝

GM.Name = "DC Universe Online Roleplay"
GM.Author = "DCUO-RP Team"
GM.Email = "N/A"
GM.Website = "N/A"
GM.TeamBased = false

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     TABLE GLOBALE PRINCIPALE                      ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO = DCUO or {}
DCUO.Config = DCUO.Config or {}
DCUO.Players = DCUO.Players or {}
DCUO.Jobs = DCUO.Jobs or {}
DCUO.Factions = DCUO.Factions or {}
DCUO.Missions = DCUO.Missions or {}
DCUO.Powers = DCUO.Powers or {}
DCUO.Events = DCUO.Events or {}
DCUO.UI = DCUO.UI or {}
DCUO.Guilds = DCUO.Guilds or {}  -- Système de guildes

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                          VERSION INFO                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Version = "1.0.0"
DCUO.BuildDate = "31/01/2026"

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     PALETTE DE COULEURS                           ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Colors = {
    Electric = Color(30, 144, 255),      -- Bleu électrique
    Hero = Color(192, 57, 43),           -- Rouge héroïque
    Villain = Color(142, 68, 173),       -- Violet néon
    Neutral = Color(149, 165, 166),      -- Gris neutre
    Dark = Color(10, 10, 10),            -- Noir profond
    Light = Color(236, 240, 241),        -- Blanc lumineux
    Success = Color(46, 204, 113),       -- Vert succès
    Warning = Color(243, 156, 18),       -- Orange avertissement
    Error = Color(231, 76, 60),          -- Rouge erreur
    XP = Color(155, 89, 182),            -- Violet XP
    Transparent = Color(0, 0, 0, 200)    -- Noir transparent
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONCTIONS UTILITAIRES                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Fonction de log personnalisée
function DCUO.Log(message, type)
    type = type or "INFO"
    local color = Color(255, 255, 255)
    
    if type == "ERROR" then
        color = DCUO.Colors.Error
    elseif type == "SUCCESS" then
        color = DCUO.Colors.Success
    elseif type == "WARNING" then
        color = DCUO.Colors.Warning
    end
    
    MsgC(DCUO.Colors.Electric, "[DCUO-RP] ", color, "[" .. type .. "] ", Color(255, 255, 255), message .. "\n")
end

-- Fonction pour charger les fichiers
function DCUO.IncludeFile(filePath, realm)
    realm = realm or "shared"
    
    if realm == "shared" then
        if SERVER then AddCSLuaFile(filePath) end
        include(filePath)
        DCUO.Log("Loaded " .. filePath .. " (Shared)", "SUCCESS")
    elseif realm == "server" then
        if SERVER then
            include(filePath)
            DCUO.Log("Loaded " .. filePath .. " (Server)", "SUCCESS")
        end
    elseif realm == "client" then
        if SERVER then
            AddCSLuaFile(filePath)
        else
            include(filePath)
            DCUO.Log("Loaded " .. filePath .. " (Client)", "SUCCESS")
        end
    end
end

-- Fonction pour charger un dossier entier
function DCUO.IncludeFolder(folderPath, realm)
    local files, folders = file.Find(folderPath .. "/*", "LUA")
    
    -- Charger les fichiers
    for _, fileName in ipairs(files) do
        -- Exclure les fichiers markdown et autres non-lua
        if string.EndsWith(fileName, ".lua") and not string.EndsWith(fileName, ".md") then
            local fileRealm = realm
            
            -- Détection automatique du realm selon le préfixe
            if string.StartWith(fileName, "sh_") then
                fileRealm = "shared"
            elseif string.StartWith(fileName, "cl_") then
                fileRealm = "client"
            elseif string.StartWith(fileName, "sv_") then
                fileRealm = "server"
            end
            
            DCUO.IncludeFile(folderPath .. "/" .. fileName, fileRealm)
        end
    end
    
    -- Charger les sous-dossiers récursivement
    for _, folderName in ipairs(folders) do
        DCUO.IncludeFolder(folderPath .. "/" .. folderName, realm)
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    MESSAGES RÉSEAU                                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

if SERVER then
    -- Messages serveur vers client
    util.AddNetworkString("DCUO:PlayerData")
    util.AddNetworkString("DCUO:UpdateXP")
    util.AddNetworkString("DCUO:UpdateLevel")
    util.AddNetworkString("DCUO:Notification")
    util.AddNetworkString("DCUO:OpenCharacterCreator")
    util.AddNetworkString("DCUO:CreateCharacter")
    util.AddNetworkString("DCUO:StartCinematic")
    util.AddNetworkString("DCUO:EndCinematic")
    util.AddNetworkString("DCUO:OpenMenu")
    util.AddNetworkString("DCUO:JobChange")
    util.AddNetworkString("DCUO:AdminPosition")
    util.AddNetworkString("DCUO:MissionUpdate")
    util.AddNetworkString("DCUO:PowerActivate")
    util.AddNetworkString("DCUO:EventStart")
    util.AddNetworkString("DCUO:AdminPanel")
    util.AddNetworkString("DCUO:AdminAction")
    util.AddNetworkString("DCUO:MissionDialogue")
    util.AddNetworkString("DCUO:ChangeMusicMode")
    
    -- Ajout des NetworkStrings manquants (CRITIQUE)
    util.AddNetworkString("DCUO:PowerEquip")
    util.AddNetworkString("DCUO:PowerUnequip")
    util.AddNetworkString("DCUO_SendDuelRequest")
    util.AddNetworkString("DCUO_RemoveFriend")
    util.AddNetworkString("DCUO_SendFriendRequest")
    util.AddNetworkString("DCUO:Guilds:Create")
    util.AddNetworkString("DCUO:ServerAnnounce")
    util.AddNetworkString("DCUO:BossSpawned")
    util.AddNetworkString("DCUO:BossKilled")
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CONFIGURATION WORKSHOP                         ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Charger la configuration Workshop en premier
DCUO.IncludeFile("dcuorp/config/sh_workshop.lua", "shared")

-- Spawns de missions (utilisé par le panel admin / missions)
DCUO.IncludeFile("dcuorp/config/sh_mission_spawns.lua", "shared")

DCUO.Log("=== DCUO-RP Gamemode v" .. DCUO.Version .. " Loaded ===", "SUCCESS")

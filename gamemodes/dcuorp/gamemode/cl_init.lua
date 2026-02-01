--[[
═══════════════════════════════════════════════════════════════════════
    DC UNIVERSE ONLINE ROLEPLAY (DCUO-RP)
    Client-Side Initialization
═══════════════════════════════════════════════════════════════════════
--]]

print("[DCUO-RP] [DEBUG] cl_init.lua starting to load...")

include("shared.lua")

print("[DCUO-RP] [DEBUG] shared.lua included, DCUO table exists: " .. tostring(DCUO ~= nil))

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CHARGEMENT MODULES CLIENT                      ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Log("=== Loading Client Modules ===", "INFO")

-- Charger les configurations (shared)
include("dcuorp/core/sh_config.lua")
include("dcuorp/config/colors.lua")
include("dcuorp/config/playermodels.lua")
include("dcuorp/config/weapons.lua")

-- Charger les systèmes shared
include("dcuorp/core/sh_factions.lua")
include("dcuorp/core/sh_jobs.lua")
include("dcuorp/core/sh_xp.lua")
include("dcuorp/core/sh_missions.lua")
include("dcuorp/systems/sh_powers.lua")
include("dcuorp/systems/sh_auras.lua")
include("dcuorp/systems/sh_scaling.lua")
include("dcuorp/systems/sh_stamina.lua")
include("dcuorp/systems/sh_bosses.lua")
include("dcuorp/systems/sh_duel.lua")

DCUO.Log("Shared modules loaded", "SUCCESS")

-- Charger les systèmes client
include("dcuorp/systems/cl_arms.lua")
include("dcuorp/systems/cl_duel.lua")
include("dcuorp/systems/cl_friends.lua")

-- Charger l'UI (client)
include("dcuorp/ui/cl_hud.lua")
include("dcuorp/ui/cl_menus.lua")
include("dcuorp/ui/cl_character_creator.lua")
include("dcuorp/ui/cl_auras.lua")
include("dcuorp/ui/cl_overhead.lua")
include("dcuorp/ui/cl_aura_shop.lua")
include("dcuorp/ui/cl_admin_panel.lua")
include("dcuorp/ui/cl_notifications.lua")
include("dcuorp/ui/cl_cinematics.lua")
include("dcuorp/ui/cl_healthbars.lua")
include("dcuorp/ui/cl_boss_hud.lua")
include("dcuorp/ui/cl_stamina_hud.lua")
include("dcuorp/ui/cl_player_interaction.lua")
-- include("dcuorp/ui/cl_ambient_music_server.lua") -- Fichier supprimé
include("dcuorp/ui/cl_mission_hud.lua")

-- Charger les menus F1/F2 depuis autorun
include("dcuorp/lua/autorun/client/cl_f1_simple.lua")
include("dcuorp/lua/autorun/client/cl_f2_simple.lua")

DCUO.Log("=== All Client Modules Loaded ===", "SUCCESS")

print("[DCUO-RP] [DEBUG] DCUO.Cinematics exists: " .. tostring(DCUO and DCUO.Cinematics ~= nil))
print("[DCUO-RP] [DEBUG] DCUO.UI exists: " .. tostring(DCUO and DCUO.UI ~= nil))

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    VARIABLES LOCALES                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Client = DCUO.Client or {}
DCUO.Client.CharacterCreated = false
DCUO.Client.InCinematic = false
DCUO.Client.ThirdPerson = true  -- 3ème personne par défaut
DCUO.Client.CameraDistance = 120  -- Distance de la caméra

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CRÉATION DES POLICES                           ║
-- ╚═══════════════════════════════════════════════════════════════════╝

surface.CreateFont("DCUO_Font_Large", {
    font = "Roboto",
    size = 32,
    weight = 700,
    antialias = true,
    shadow = true,
})

surface.CreateFont("DCUO_Font_Medium", {
    font = "Roboto",
    size = 24,
    weight = 600,
    antialias = true,
    shadow = true,
})

surface.CreateFont("DCUO_Font_Small", {
    font = "Roboto",
    size = 18,
    weight = 500,
    antialias = true,
    shadow = true,
})

surface.CreateFont("DCUO_Font_Tiny", {
    font = "Roboto",
    size = 14,
    weight = 500,
    antialias = true,
})

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CHARGEMENT CLIENT                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Log("=== Client Initialization ===", "INFO")

-- Désactiver certains éléments de l'HUD par défaut
local hideHUDElements = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
    ["CHudTargetID"] = true,  -- Désactiver l'affichage du nom au ciblage
}

hook.Add("HUDShouldDraw", "DCUO:HideDefaultHUD", function(name)
    if hideHUDElements[name] then
        return false
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    RÉCEPTION RÉSEAU                               ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Recevoir les données du joueur
net.Receive("DCUO:PlayerData", function()
    local data = net.ReadTable()
    LocalPlayer().DCUOData = data
    
    DCUO.Log("Player data received", "SUCCESS")
end)

-- Mise à jour XP
net.Receive("DCUO:UpdateXP", function()
    local xp = net.ReadInt(32)
    local maxXP = net.ReadInt(32)
    
    if LocalPlayer().DCUOData then
        LocalPlayer().DCUOData.xp = xp
        LocalPlayer().DCUOData.maxXP = maxXP
    end
end)

-- Mise à jour niveau
net.Receive("DCUO:UpdateLevel", function()
    local level = net.ReadInt(16)
    local newLevel = net.ReadBool()
    
    if LocalPlayer().DCUOData then
        local oldLevel = LocalPlayer().DCUOData.level
        LocalPlayer().DCUOData.level = level
        
        if newLevel then
            -- Animation de level up
            DCUO.UI.ShowLevelUp(oldLevel, level)
        end
    end
end)

-- Recevoir une notification
net.Receive("DCUO:Notification", function()
    local message = net.ReadString()
    local color = net.ReadColor()
    
    if DCUO.UI and DCUO.UI.AddNotification then
        DCUO.UI.AddNotification(message, color)
    else
        chat.AddText(color, "[DCUO] ", Color(255, 255, 255), message)
    end
end)

-- Lancer la cinématique d'introduction
net.Receive("DCUO:StartCinematic", function()
    DCUO.Log("Received start cinematic message", "INFO")
    
    if DCUO.Cinematics and DCUO.Cinematics.PlayIntro then
        DCUO.Log("Starting intro cinematic", "INFO")
        DCUO.Cinematics.PlayIntro(function()
            -- Après la cinématique, ouvrir le créateur de personnage
            DCUO.Log("Cinematic callback triggered!", "SUCCESS")
            DCUO.Log("Sending DCUO:OpenCharacterCreator to server...", "INFO")
            timer.Simple(0.5, function()
                net.Start("DCUO:OpenCharacterCreator")
                net.SendToServer()
                DCUO.Log("DCUO:OpenCharacterCreator sent!", "SUCCESS")
            end)
        end)
    else
        DCUO.Log("ERROR: DCUO.Cinematics.PlayIntro not found!", "ERROR")
        -- Ouvrir directement le créateur si la cinématique ne marche pas
        timer.Simple(1, function()
            net.Start("DCUO:OpenCharacterCreator")
            net.SendToServer()
        end)
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    HOOKS CLIENT                                   ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Initialisation du client
hook.Add("Initialize", "DCUO:ClientInit", function()
    DCUO.Log("Client initialized", "SUCCESS")
end)

-- Calcul de la vue (pour les cinématiques et 3ème personne)
hook.Add("CalcView", "DCUO:CustomView", function(ply, pos, angles, fov)
    -- Priorité 1: Cinématique
    if DCUO.Client.InCinematic and DCUO.Cinematics and DCUO.Cinematics.GetView then
        return DCUO.Cinematics.GetView()
    end
    
    -- Priorité 2: 3ème personne
    if DCUO.Client.ThirdPerson and IsValid(ply) then
        local view = {}
        view.origin = pos
        view.angles = angles
        view.fov = fov
        
        -- Calculer la position de la caméra derrière le joueur
        local distance = DCUO.Client.CameraDistance
        local traceLine = util.TraceLine({
            start = pos,
            endpos = pos - angles:Forward() * distance + Vector(0, 0, 30),
            filter = ply
        })
        
        view.origin = traceLine.HitPos
        view.drawviewer = true
        
        return view
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    COMMANDES CONSOLE                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

concommand.Add("dcuo_menu", function()
    if DCUO.UI and DCUO.UI.OpenMainMenu then
        DCUO.UI.OpenMainMenu()
    end
end)

concommand.Add("dcuo_character", function()
    net.Start("DCUO:OpenCharacterCreator")
    net.SendToServer()
end)

concommand.Add("dcuo_test_cinematic", function()
    DCUO.Log("Testing cinematic...", "INFO")
    if DCUO.Cinematics and DCUO.Cinematics.PlayIntro then
        DCUO.Cinematics.PlayIntro(function()
            DCUO.Log("Cinematic test finished!", "SUCCESS")
        end)
    else
        DCUO.Log("ERROR: Cinematics not loaded!", "ERROR")
    end
end)

concommand.Add("dcuo_skip_cinematic", function()
    if DCUO.Cinematics and DCUO.Cinematics.Stop then
        DCUO.Cinematics.Stop()
        DCUO.Log("Cinematic skipped", "INFO")
    end
end)

concommand.Add("dcuo_toggle_camera", function()
    DCUO.Client.ThirdPerson = not DCUO.Client.ThirdPerson
    local mode = DCUO.Client.ThirdPerson and "3ème personne" or "1ère personne"
    DCUO.Log("Vue changée: " .. mode, "SUCCESS")
    if DCUO.UI and DCUO.UI.AddNotification then
        DCUO.UI.AddNotification("Vue: " .. mode, DCUO.Colors.Success, 2)
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    TOUCHES F1-F4 (MENUS)                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Note: F1 et F2 sont gérés par les hooks ShowHelp/ShowTeam dans les fichiers autorun
-- F3 et F4 sont gérés ici via PlayerButtonDown

-- Cooldown pour éviter les ouvertures multiples
local menuCooldown = 0

hook.Add("PlayerButtonDown", "DCUO:MenuKeys", function(ply, button)
    if ply ~= LocalPlayer() then return end
    if CurTime() < menuCooldown then return end
    
    local menuOpened = false
    
    -- F1 et F2 sont gérés par ShowHelp/ShowTeam (voir lua/autorun/client/)
    
    -- F3 - Menu pouvoirs
    if button == KEY_F3 then
        print("[DCUO DEBUG] F3 pressed - UI exists:", DCUO.UI ~= nil, "OpenPowersMenu exists:", DCUO.UI and DCUO.UI.OpenPowersMenu ~= nil)
        if DCUO.UI and DCUO.UI.OpenPowersMenu then
            DCUO.UI.OpenPowersMenu()
            menuOpened = true
        else
            print("[DCUO ERROR] Powers menu not loaded!")
        end
    end
    
    -- F4 - Menu missions
    if button == KEY_F4 then
        print("[DCUO DEBUG] F4 pressed - UI exists:", DCUO.UI ~= nil, "OpenMissionsMenu exists:", DCUO.UI and DCUO.UI.OpenMissionsMenu ~= nil)
        if DCUO.UI and DCUO.UI.OpenMissionsMenu then
            DCUO.UI.OpenMissionsMenu()
            menuOpened = true
        else
            print("[DCUO ERROR] Missions menu not loaded!")
        end
    end
    
    -- F5 - Menu admin (seulement pour les admins)
    if button == KEY_F5 then
        if DCUO.Admin and DCUO.Admin.OpenPanel then
            if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
                DCUO.Admin.OpenPanel()
                menuOpened = true
            else
                chat.AddText(Color(231, 76, 60), "[DCUO] Vous devez être administrateur pour accéder à ce menu.")
            end
        end
    end
    
    -- Appliquer cooldown si un menu a été ouvert
    if menuOpened then
        menuCooldown = CurTime() + 0.3
    end
end)

DCUO.Log("=== Client Ready ===", "SUCCESS")

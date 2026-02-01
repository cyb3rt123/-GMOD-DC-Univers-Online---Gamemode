--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - HUD Cinématique
    Interface utilisateur futuriste et immersive
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

DCUO.HUD = DCUO.HUD or {}
DCUO.HUD.Enabled = true

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    VARIABLES LOCALES                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

local scrW, scrH = ScrW(), ScrH()
local xpBarAlpha = 0
local healthAlpha = 0
local levelUpTime = 0

-- Smooth values pour les animations
local smoothHealth = 100
local smoothArmor = 0
local smoothXP = 0

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONCTIONS UTILITAIRES                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Dessiner un rectangle arrondi
local function DrawRoundedBox(x, y, w, h, radius, color)
    draw.RoundedBox(radius, x, y, w, h, color)
end

-- Dessiner un rectangle avec bordure néon
local function DrawNeonBox(x, y, w, h, color, glowColor)
    -- Ombre/glow
    surface.SetDrawColor(glowColor.r, glowColor.g, glowColor.b, 50)
    DrawRoundedBox(x - 2, y - 2, w + 4, h + 4, 8, glowColor)
    
    -- Box principale
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    DrawRoundedBox(x, y, w, h, 6, color)
end

-- Texte avec ombre
local function DrawShadowText(text, font, x, y, color, xalign, yalign)
    draw.SimpleText(text, font, x + 2, y + 2, Color(0, 0, 0, 150), xalign, yalign)
    draw.SimpleText(text, font, x, y, color, xalign, yalign)
end

-- Interpolation smooth
local function Lerp(a, b, t)
    return a + (b - a) * t
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONTS                                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

surface.CreateFont("DCUO_HUD_Large", {
    font = "Roboto",
    size = 48,
    weight = 700,
    antialias = true,
})

surface.CreateFont("DCUO_HUD_Medium", {
    font = "Roboto",
    size = 28,
    weight = 600,
    antialias = true,
})

surface.CreateFont("DCUO_HUD_Small", {
    font = "Roboto",
    size = 20,
    weight = 500,
    antialias = true,
})

surface.CreateFont("DCUO_HUD_Tiny", {
    font = "Roboto",
    size = 16,
    weight = 400,
    antialias = true,
})

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    DRAW FUNCTIONS                                 ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Dessiner les informations du joueur
local function DrawPlayerInfo()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply.DCUOData then return end
    
    local data = ply.DCUOData
    local x = scrW * 0.02
    local y = scrH * 0.02
    
    -- Background
    local bgColor = ColorAlpha(DCUO.Colors.Dark, 200)
    DrawNeonBox(x, y, 300, 150, bgColor, DCUO.Colors.Electric)
    
    -- Nom RP
    DrawShadowText(data.rpname or "Unknown", "DCUO_HUD_Medium", x + 10, y + 10, DCUO.Colors.Light, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    
    -- Job
    local job = DCUO.Jobs.Get(data.job)
    if job then
        local jobColor = job.color or DCUO.Colors.Neutral
        DrawShadowText(job.name, "DCUO_HUD_Small", x + 10, y + 45, jobColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    
    -- Niveau
    local levelText = "NIVEAU " .. data.level
    DrawShadowText(levelText, "DCUO_HUD_Medium", x + 10, y + 75, DCUO.Colors.XP, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    
    -- Faction
    local faction = DCUO.Factions.Get(data.faction)
    if faction then
        DrawShadowText(faction.name, "DCUO_HUD_Small", x + 10, y + 115, faction.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
end

-- Dessiner la santé et l'armure
local function DrawHealthArmor()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local health = ply:Health()
    local maxHealth = ply:GetMaxHealth()
    local armor = ply:Armor()
    
    -- Smooth transition
    smoothHealth = Lerp(smoothHealth, health, FrameTime() * 5)
    smoothArmor = Lerp(smoothArmor, armor, FrameTime() * 5)
    
    local x = scrW * 0.02
    local y = scrH * 0.2
    local w = 250
    local h = 25
    
    -- SANTÉ
    -- Background
    DrawNeonBox(x, y, w, h, ColorAlpha(DCUO.Colors.Dark, 200), ColorAlpha(DCUO.Colors.Hero, 100))
    
    -- Barre de santé
    local healthPercent = math.Clamp(smoothHealth / maxHealth, 0, 1)
    local healthColor = DCUO.Colors.Hero
    if healthPercent < 0.3 then
        healthColor = DCUO.Colors.Error
    elseif healthPercent < 0.6 then
        healthColor = DCUO.Colors.Warning
    end
    
    surface.SetDrawColor(healthColor.r, healthColor.g, healthColor.b, 220)
    DrawRoundedBox(x + 2, y + 2, (w - 4) * healthPercent, h - 4, 4, healthColor)
    
    -- Texte
    local healthText = math.floor(smoothHealth) .. " / " .. maxHealth
    DrawShadowText(healthText, "DCUO_HUD_Tiny", x + w / 2, y + h / 2, DCUO.Colors.Light, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- ARMURE (si > 0)
    if armor > 0 then
        y = y + h + 5
        
        -- Background
        DrawNeonBox(x, y, w, h, ColorAlpha(DCUO.Colors.Dark, 200), ColorAlpha(DCUO.Colors.Electric, 100))
        
        -- Barre d'armure
        local armorPercent = math.Clamp(smoothArmor / 100, 0, 1)
        surface.SetDrawColor(DCUO.Colors.Electric.r, DCUO.Colors.Electric.g, DCUO.Colors.Electric.b, 220)
        DrawRoundedBox(x + 2, y + 2, (w - 4) * armorPercent, h - 4, 4, DCUO.Colors.Electric)
        
        -- Texte
        local armorText = math.floor(smoothArmor) .. " ARMOR"
        DrawShadowText(armorText, "DCUO_HUD_Tiny", x + w / 2, y + h / 2, DCUO.Colors.Light, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

-- Dessiner la barre d'XP
local function DrawXPBar()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply.DCUOData then return end
    
    local data = ply.DCUOData
    
    -- Position centrée en bas
    local w = 600
    local h = 35
    local x = scrW / 2 - w / 2
    local y = scrH * 0.95
    
    -- Smooth XP
    smoothXP = Lerp(smoothXP, data.xp or 0, FrameTime() * 3)
    
    -- Alpha animation
    xpBarAlpha = Lerp(xpBarAlpha, 255, FrameTime() * 2)
    
    -- Background
    local bgColor = ColorAlpha(DCUO.Colors.Dark, 200)
    DrawNeonBox(x, y, w, h, bgColor, ColorAlpha(DCUO.Colors.XP, 100))
    
    -- Barre de progression
    local maxXP = data.maxXP or 100
    local percent = math.Clamp(smoothXP / maxXP, 0, 1)
    
    -- Gradient XP bar
    surface.SetDrawColor(DCUO.Colors.XP.r, DCUO.Colors.XP.g, DCUO.Colors.XP.b, xpBarAlpha)
    DrawRoundedBox(x + 2, y + 2, (w - 4) * percent, h - 4, 4, DCUO.Colors.XP)
    
    -- Effet de brillance
    local glowAlpha = math.abs(math.sin(CurTime() * 2)) * 100
    surface.SetDrawColor(255, 255, 255, glowAlpha)
    DrawRoundedBox(x + 2, y + 2, (w - 4) * percent, h / 2 - 2, 4, Color(255, 255, 255, glowAlpha))
    
    -- Texte XP
    local xpText = math.floor(smoothXP) .. " / " .. maxXP .. " XP"
    DrawShadowText(xpText, "DCUO_HUD_Small", x + w / 2, y + h / 2, DCUO.Colors.Light, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Pourcentage
    local percentText = math.floor(percent * 100) .. "%"
    DrawShadowText(percentText, "DCUO_HUD_Tiny", x + w - 10, y + h / 2, DCUO.Colors.XP, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    
    -- Niveau à gauche
    local levelText = "LVL " .. (data.level or 1)
    DrawShadowText(levelText, "DCUO_HUD_Small", x + 10, y + h / 2, DCUO.Colors.Electric, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

-- Dessiner les cooldowns de pouvoirs
local function DrawPowerCooldowns()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply.DCUOCooldowns then return end
    
    local x = scrW - 220
    local y = scrH - 150
    local index = 0
    
    for powerID, endTime in pairs(ply.DCUOCooldowns) do
        local remaining = math.max(0, endTime - CurTime())
        
        if remaining > 0 then
            local power = DCUO.Powers.Get(powerID)
            if power then
                local boxY = y + (index * 45)
                
                -- Background
                DrawNeonBox(x, boxY, 200, 40, ColorAlpha(DCUO.Colors.Dark, 200), ColorAlpha(DCUO.Colors.Electric, 100))
                
                -- Nom du pouvoir
                DrawShadowText(power.name, "DCUO_HUD_Tiny", x + 10, boxY + 5, DCUO.Colors.Light, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                
                -- Cooldown
                local cdText = string.format("%.1fs", remaining)
                DrawShadowText(cdText, "DCUO_HUD_Tiny", x + 190, boxY + 5, DCUO.Colors.Warning, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                
                -- Barre de progression
                local cdPercent = 1 - (remaining / power.cooldown)
                surface.SetDrawColor(DCUO.Colors.Electric.r, DCUO.Colors.Electric.g, DCUO.Colors.Electric.b, 150)
                DrawRoundedBox(x + 2, boxY + 25, 196 * cdPercent, 4, 2, DCUO.Colors.Electric)
                
                index = index + 1
            end
        end
    end
end

-- Dessiner la minimap (placeholder)
local function DrawMinimap()
    if not DCUO.Config or not DCUO.Config.HUD or not DCUO.Config.HUD.ShowMinimap then return end
    
    local size = DCUO.Config.HUD.MinimapSize or 200
    local x = scrW * 0.9 - size / 2
    local y = scrH * 0.1 - size / 2
    
    -- Background
    DrawNeonBox(x, y, size, size, ColorAlpha(DCUO.Colors.Dark, 150), ColorAlpha(DCUO.Colors.Electric, 100))
    
    -- Titre
    DrawShadowText("CARTE", "DCUO_HUD_Tiny", x + size / 2, y + 10, DCUO.Colors.Light, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    
    -- TODO: Implémenter une vraie minimap
    -- Pour l'instant juste un placeholder
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    ANIMATION LEVEL UP                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.UI.ShowLevelUp(oldLevel, newLevel)
    levelUpTime = CurTime() + 5
    
    -- Son
    surface.PlaySound("buttons/bell1.wav")
end

local function DrawLevelUpAnimation()
    if CurTime() > levelUpTime then return end
    
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply.DCUOData then return end
    
    local alpha = math.Clamp((levelUpTime - CurTime()) / 5, 0, 1) * 255
    local scale = 1 + math.sin(CurTime() * 5) * 0.1
    
    -- Texte LEVEL UP
    local text = "NIVEAU " .. (ply.DCUOData.level or 1) .. " !"
    
    draw.SimpleText(text, "DCUO_HUD_Large", scrW / 2 + 3, scrH / 3 + 3, Color(0, 0, 0, alpha * 0.5), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(text, "DCUO_HUD_Large", scrW / 2, scrH / 3, ColorAlpha(DCUO.Colors.Success, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Particules (simulées avec des cercles)
    for i = 1, 10 do
        local angle = (CurTime() * 100 + i * 36) % 360
        local rad = math.rad(angle)
        local distance = 100 + math.sin(CurTime() * 3) * 20
        
        local px = scrW / 2 + math.cos(rad) * distance
        local py = scrH / 3 + math.sin(rad) * distance
        
        surface.SetDrawColor(DCUO.Colors.XP.r, DCUO.Colors.XP.g, DCUO.Colors.XP.b, alpha)
        surface.DrawRect(px - 3, py - 3, 6, 6)
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    HOOK PRINCIPAL                                 ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- HOOK PRINCIPAL UNIQUE - Centralise TOUS les dessins HUD pour performance optimale
hook.Add("HUDPaint", "DCUO:DrawHUD", function()
    -- Mettre à jour la résolution
    scrW, scrH = ScrW(), ScrH()
    
    -- 1. HUD Principal (si activé)
    if DCUO.HUD.Enabled then
        DrawPlayerInfo()
        DrawHealthArmor()
        DrawXPBar()
        DrawPowerCooldowns()
        DrawMinimap()
        DrawLevelUpAnimation()
    end
    
    -- 2. Mission HUD (si fonction existe)
    if DCUO.MissionHUD and DCUO.MissionHUD.Draw then
        DCUO.MissionHUD.Draw()
    end
    
    -- 3. Stamina HUD (si fonction existe)
    if DCUO.StaminaHUD and DCUO.StaminaHUD.Draw then
        DCUO.StaminaHUD.Draw()
    end
    
    -- 4. Boss HUD (si fonction existe)
    if DCUO.BossHUD and DCUO.BossHUD.Draw then
        DCUO.BossHUD.Draw()
    end
    
    -- 5. Chat HUD (si fonction existe)
    if DCUO.Chat and DCUO.Chat.DrawHUD then
        DCUO.Chat.DrawHUD()
    end
    
    -- 6. Duel HUD (si fonction existe)
    if DCUO.Duel and DCUO.Duel.DrawHUD then
        DCUO.Duel.DrawHUD()
    end
    
    -- 7. Notifications (si fonction existe)
    if DCUO.Notifications and DCUO.Notifications.Draw then
        DCUO.Notifications.Draw()
    end
    
    -- 8. Cinématiques (si fonction existe - priorité max, dessine par-dessus tout)
    if DCUO.Cinematics and DCUO.Cinematics.Draw then
        DCUO.Cinematics.Draw()
    end
    
    -- 9. Mission Dialogue (si fonction existe)
    if DCUO.MissionDialogue and DCUO.MissionDialogue.Draw then
        DCUO.MissionDialogue.Draw()
    end
    
    -- 10. Logo serveur (si fonction existe)
    if DCUO.ServerLogo and DCUO.ServerLogo.Draw then
        DCUO.ServerLogo.Draw()
    end
end)

-- Désactiver le HUD par défaut de GMod
hook.Add("HUDShouldDraw", "DCUO:HideDefaultHUD", function(name)
    local hideElements = {
        ["CHudHealth"] = true,
        ["CHudBattery"] = true,
        ["CHudAmmo"] = true,
        ["CHudSecondaryAmmo"] = true,
        ["CHudDamageIndicator"] = false,
    }
    
    if hideElements[name] then
        return false
    end
end)

DCUO.Log("HUD system loaded", "SUCCESS")

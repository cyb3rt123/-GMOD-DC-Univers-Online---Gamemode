-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                         STAMINA HUD DISPLAY                       ║
-- ║          Affiche la barre de stamina en bas de l'écran            ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Variables locales pour les couleurs
local colorStaminaBar = Color(100, 200, 255) -- Bleu cyan pour la stamina
local colorStaminaBg = Color(20, 20, 20, 180)
local colorStaminaBorder = Color(255, 255, 255, 100)
local colorStaminaText = Color(255, 255, 255)

-- Fonction pour dessiner la barre de stamina
local function DrawStaminaBar()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    -- Récupérer la stamina actuelle
    local currentStamina = ply:GetNWInt("DCUO_Stamina", DCUO.Stamina.Config.MaxStamina)
    local maxStamina = DCUO.Stamina.Config.MaxStamina
    local staminaPercent = math.Clamp(currentStamina / maxStamina, 0, 1)
    
    -- Position et dimensions de la barre
    local scrW, scrH = ScrW(), ScrH()
    local barWidth = 400
    local barHeight = 30
    local barX = scrW / 2 - barWidth / 2
    local barY = scrH - 150 -- Au-dessus de la barre de santé
    
    -- Arrière-plan
    draw.RoundedBox(6, barX - 2, barY - 2, barWidth + 4, barHeight + 4, colorStaminaBorder)
    draw.RoundedBox(4, barX, barY, barWidth, barHeight, colorStaminaBg)
    
    -- Barre de stamina (remplie selon le pourcentage)
    local filledWidth = barWidth * staminaPercent
    if filledWidth > 0 then
        draw.RoundedBox(4, barX, barY, filledWidth, barHeight, colorStaminaBar)
    end
    
    -- Texte de stamina
    local staminaText = string.format("%d / %d", math.floor(currentStamina), maxStamina)
    draw.SimpleText(staminaText, "DCUO_HUD_Small", barX + barWidth / 2, barY + barHeight / 2, colorStaminaText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Icône "STAMINA" au-dessus
    draw.SimpleText("STAMINA", "DCUO_HUD_Tiny", barX + barWidth / 2, barY - 15, colorStaminaText, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end

-- Hook pour afficher la stamina dans le HUD
hook.Add("HUDPaint", "DCUO_DrawStaminaHUD", function()
    if not DCUO.Config or not DCUO.Config.HUD or not DCUO.Config.HUD.Stamina then return end
    DrawStaminaBar()
end)

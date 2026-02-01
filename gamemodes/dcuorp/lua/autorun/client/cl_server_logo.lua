--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Logo du Serveur (HUD)
    Affiche le logo en bas à droite de l'écran
═══════════════════════════════════════════════════════════════════════
--]]

-- Précacher le material
local logoPath = "dcuo/logos/server_logo.png"
local icon = nil

timer.Simple(1, function()
    icon = Material(logoPath, "smooth")
    if icon:IsError() then
        print("[DCUO LOGO] ERREUR: Material introuvable: " .. logoPath)
        print("[DCUO LOGO] Vérifiez que le fichier existe dans: garrysmod/addons/dcuorp-content/materials/" .. logoPath)
    else
        print("[DCUO LOGO] Logo chargé avec succès !")
    end
end)

hook.Add("HUDPaint", "DCUO:ShowServerLogo", function()
    if not icon then return end
    
    -- Taille du logo (petit)
    local sizex = 120
    local sizey = 120
    
    -- Position en bas à droite avec marge de 10 pixels
    local x = ScrW() - sizex - 10
    local y = ScrH() - sizey - 10
    
    -- Dessiner le logo avec léger effet de transparence
    if not icon:IsError() then
        surface.SetMaterial(icon)
        surface.SetDrawColor(255, 255, 255, 200)
        surface.DrawTexturedRect(x, y, sizex, sizey)
    else
        -- Fallback si logo pas trouvé
        draw.RoundedBox(8, x, y, sizex, sizey, Color(52, 152, 219, 150))
        draw.SimpleText("DCUO-RP", "DermaLarge", x + sizex/2, y + sizey/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)

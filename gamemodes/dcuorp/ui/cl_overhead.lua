--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Affichage au-dessus des joueurs
    Niveau, nom, badge staff avec style selon le niveau
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONTS SELON NIVEAU                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Niveau 1-9 : Petit
surface.CreateFont("DCUO_Overhead_Name_Novice", {
    font = "Roboto",
    size = 18,
    weight = 500,
    antialias = true,
    shadow = true,
})

surface.CreateFont("DCUO_Overhead_Level_Novice", {
    font = "Roboto",
    size = 14,
    weight = 700,
    antialias = true,
    shadow = true,
})

-- Niveau 10-19 : Moyen
surface.CreateFont("DCUO_Overhead_Name_Intermediate", {
    font = "Roboto",
    size = 22,
    weight = 600,
    antialias = true,
    shadow = true,
})

surface.CreateFont("DCUO_Overhead_Level_Intermediate", {
    font = "Roboto",
    size = 16,
    weight = 700,
    antialias = true,
    shadow = true,
})

-- Niveau 20-29 : Grand
surface.CreateFont("DCUO_Overhead_Name_Advanced", {
    font = "Roboto",
    size = 26,
    weight = 700,
    antialias = true,
    shadow = true,
})

surface.CreateFont("DCUO_Overhead_Level_Advanced", {
    font = "Roboto",
    size = 18,
    weight = 800,
    antialias = true,
    shadow = true,
})

-- Niveau 30-39 : Très grand
surface.CreateFont("DCUO_Overhead_Name_Expert", {
    font = "Roboto",
    size = 30,
    weight = 800,
    antialias = true,
    shadow = true,
})

surface.CreateFont("DCUO_Overhead_Level_Expert", {
    font = "Roboto",
    size = 20,
    weight = 900,
    antialias = true,
    shadow = true,
})

-- Niveau 40+ : LÉGENDAIRE
surface.CreateFont("DCUO_Overhead_Name_Legendary", {
    font = "Roboto",
    size = 36,
    weight = 900,
    antialias = true,
    shadow = true,
})

surface.CreateFont("DCUO_Overhead_Level_Legendary", {
    font = "Roboto",
    size = 24,
    weight = 900,
    antialias = true,
    shadow = true,
})

-- Badge staff
surface.CreateFont("DCUO_Overhead_Badge", {
    font = "Roboto",
    size = 14,
    weight = 700,
    antialias = true,
    shadow = true,
})

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    OBTENIR LES FONTS SELON NIVEAU                 ║
-- ╚═══════════════════════════════════════════════════════════════════╝

local function GetFontsForLevel(level)
    if level < 10 then
        return "DCUO_Overhead_Name_Novice", "DCUO_Overhead_Level_Novice"
    elseif level < 20 then
        return "DCUO_Overhead_Name_Intermediate", "DCUO_Overhead_Level_Intermediate"
    elseif level < 30 then
        return "DCUO_Overhead_Name_Advanced", "DCUO_Overhead_Level_Advanced"
    elseif level < 40 then
        return "DCUO_Overhead_Name_Expert", "DCUO_Overhead_Level_Expert"
    else
        return "DCUO_Overhead_Name_Legendary", "DCUO_Overhead_Level_Legendary"
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    COULEUR SELON NIVEAU                           ║
-- ╚═══════════════════════════════════════════════════════════════════╝

local function GetColorForLevel(level)
    if level < 10 then
        return Color(200, 200, 200) -- Gris clair
    elseif level < 20 then
        return Color(100, 200, 255) -- Bleu clair
    elseif level < 30 then
        return Color(150, 100, 255) -- Violet
    elseif level < 40 then
        return Color(255, 150, 0)   -- Orange
    else
        return Color(255, 215, 0)   -- Or (légendaire)
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    AFFICHAGE AU-DESSUS DES JOUEURS                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Affichage au-dessus des NPCs
hook.Add("PostDrawOpaqueRenderables", "DCUO:DrawNPCOverhead", function()
    for _, npc in ipairs(ents.GetAll()) do
        if not IsValid(npc) then continue end
        if not npc:IsNPC() then continue end
        if not npc.DCUOLevel then continue end
        
        local pos = npc:GetPos() + Vector(0, 0, npc:OBBMaxs().z + 10)
        local ang = EyeAngles()
        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), 90)
        
        -- Distance check
        local distance = LocalPlayer():GetPos():Distance(npc:GetPos())
        if distance > 1000 then continue end
        
        -- Fade selon distance
        local alpha = math.Clamp(255 - (distance / 1000 * 255), 50, 255)
        
        -- Données
        local level = npc.DCUOLevel or 1
        local name = npc.DCUOName or "NPC"
        
        -- Couleur selon niveau par rapport au joueur
        local ply = LocalPlayer()
        local levelDiff = level - (ply.DCUOData and ply.DCUOData.level or 1)
        local levelColor = Color(255, 255, 255)
        
        if levelDiff >= 5 then
            levelColor = Color(255, 50, 50)  -- Rouge (très dangereux)
        elseif levelDiff >= 2 then
            levelColor = Color(255, 150, 0)  -- Orange (dangereux)
        elseif levelDiff <= -5 then
            levelColor = Color(150, 150, 150)  -- Gris (facile)
        else
            levelColor = Color(255, 255, 0)  -- Jaune (approprié)
        end
        
        cam.Start3D2D(pos, ang, 0.12)
            -- Barre de santé
            local healthPercent = npc:Health() / npc:GetMaxHealth()
            local barW = 100
            local barH = 8
            
            draw.RoundedBox(4, -barW/2, -50, barW, barH, Color(0, 0, 0, alpha * 0.8))
            draw.RoundedBox(4, -barW/2 + 2, -48, (barW - 4) * healthPercent, barH - 4, Color(255 * (1 - healthPercent), 255 * healthPercent, 0, alpha))
            
            -- Niveau
            local levelText = "NIV. " .. level
            surface.SetFont("DCUO_Overhead_Level_Novice")
            local levelW, levelH = surface.GetTextSize(levelText)
            
            draw.RoundedBox(4, -levelW/2 - 5, -35, levelW + 10, levelH + 4, Color(0, 0, 0, alpha * 0.7))
            
            -- Effet de lueur pour ennemis dangereux
            if levelDiff >= 2 then
                local glowAlpha = math.abs(math.sin(CurTime() * 3)) * 50
                draw.RoundedBox(4, -levelW/2 - 7, -37, levelW + 14, levelH + 8, ColorAlpha(levelColor, glowAlpha))
            end
            
            draw.SimpleText(levelText, "DCUO_Overhead_Level_Novice", 0, -33, ColorAlpha(levelColor, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            
            -- Nom du NPC
            surface.SetFont("DCUO_Overhead_Name_Novice")
            local nameW, nameH = surface.GetTextSize(name)
            
            draw.RoundedBox(6, -nameW/2 - 5, -15, nameW + 10, nameH + 4, Color(0, 0, 0, alpha * 0.8))
            draw.SimpleText(name, "DCUO_Overhead_Name_Novice", 0, -13, ColorAlpha(Color(255, 200, 200), alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            
            -- Icône de danger si niveau élevé
            if levelDiff >= 5 then
                local skullPulse = math.abs(math.sin(CurTime() * 4)) * 0.3 + 0.7
                draw.SimpleText("☠", "DCUO_Overhead_Level_Intermediate", 0, 5, ColorAlpha(Color(255, 50, 50), alpha * skullPulse), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            end
        cam.End3D2D()
    end
end)

hook.Add("PostPlayerDraw", "DCUO:DrawOverhead", function(ply)
    if not IsValid(ply) then return end
    if ply == LocalPlayer() then return end  -- Ne pas afficher pour soi-même
    if not ply.DCUOData then return end
    
    local pos = ply:EyePos() + Vector(0, 0, 15)
    local ang = EyeAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    
    -- Distance check
    local distance = LocalPlayer():GetPos():Distance(ply:GetPos())
    if distance > 1000 then return end
    
    -- Fade selon distance
    local alpha = math.Clamp(255 - (distance / 1000 * 255), 50, 255)
    
    -- Données
    local level = ply.DCUOData.level or 1
    local rpname = ply.DCUOData.rpname or ply:Nick()
    local isStaff = ply:IsAdmin() or ply:IsSuperAdmin()
    
    -- Fonts
    local nameFont, levelFont = GetFontsForLevel(level)
    
    -- Couleurs
    local nameColor = GetColorForLevel(level)
    local levelColor = Color(255, 255, 255)
    
    cam.Start3D2D(pos, ang, 0.1)
        -- Niveau (en haut)
        local levelText = "Niveau " .. level
        surface.SetFont(levelFont)
        local levelW, levelH = surface.GetTextSize(levelText)
        
        -- Background niveau
        draw.RoundedBox(4, -levelW/2 - 5, -40, levelW + 10, levelH + 4, Color(0, 0, 0, alpha * 0.7))
        
        -- Effet de lueur pour niveaux élevés
        if level >= 30 then
            local glowAlpha = math.abs(math.sin(CurTime() * 2)) * 50
            draw.RoundedBox(4, -levelW/2 - 7, -42, levelW + 14, levelH + 8, ColorAlpha(nameColor, glowAlpha))
        end
        
        draw.SimpleText(levelText, levelFont, 0, -38, ColorAlpha(levelColor, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        
        -- Nom RP
        surface.SetFont(nameFont)
        local nameW, nameH = surface.GetTextSize(rpname)
        
        -- Background nom
        draw.RoundedBox(6, -nameW/2 - 8, -10, nameW + 16, nameH + 6, Color(0, 0, 0, alpha * 0.8))
        
        -- Effet de lueur pour niveaux légendaires
        if level >= 40 then
            local glowSize = math.abs(math.sin(CurTime() * 3)) * 5
            draw.RoundedBox(6, -nameW/2 - 8 - glowSize/2, -10 - glowSize/2, nameW + 16 + glowSize, nameH + 6 + glowSize, ColorAlpha(nameColor, 30))
        end
        
        -- Nom avec ombre impressionnante
        for i = 1, (level >= 30 and 2 or 1) do
            draw.SimpleText(rpname, nameFont, i, -8 + i, Color(0, 0, 0, alpha * 0.5), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end
        draw.SimpleText(rpname, nameFont, 0, -8, ColorAlpha(nameColor, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        
        -- Badge staff (en bas)
        if isStaff then
            local badgeText = "★ STAFF ★"
            local badgeColor = Color(255, 50, 50)
            
            if ply:IsSuperAdmin() then
                badgeText = "★ SUPER ADMIN ★"
                badgeColor = Color(255, 0, 0)
            end
            
            surface.SetFont("DCUO_Overhead_Badge")
            local badgeW, badgeH = surface.GetTextSize(badgeText)
            
            -- Background badge avec animation
            local badgePulse = math.abs(math.sin(CurTime() * 4)) * 0.2 + 0.8
            draw.RoundedBox(4, -badgeW/2 - 6, nameH + 2, badgeW + 12, badgeH + 4, Color(0, 0, 0, alpha * 0.9))
            draw.RoundedBox(4, -badgeW/2 - 4, nameH + 4, badgeW + 8, badgeH, ColorAlpha(badgeColor, alpha * badgePulse))
            
            draw.SimpleText(badgeText, "DCUO_Overhead_Badge", 0, nameH + 4, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end
        
        -- Icône de faction (optionnel)
        if ply.DCUOData.faction then
            local factionIcon = ""
            local factionColor = Color(255, 255, 255)
            
            if ply.DCUOData.faction == "Hero" then
                factionIcon = "★"
                factionColor = DCUO.Colors.Hero or Color(0, 150, 255)
            elseif ply.DCUOData.faction == "Villain" then
                factionIcon = "✖"
                factionColor = DCUO.Colors.Villain or Color(255, 50, 50)
            elseif ply.DCUOData.faction == "Neutral" then
                factionIcon = "●"
                factionColor = DCUO.Colors.Neutral or Color(200, 200, 200)
            end
            
            if factionIcon ~= "" then
                draw.SimpleText(factionIcon, levelFont, -nameW/2 - 25, -8, ColorAlpha(factionColor, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                draw.SimpleText(factionIcon, levelFont, nameW/2 + 25, -8, ColorAlpha(factionColor, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            end
        end
        
    cam.End3D2D()
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    HELPER FUNCTION                                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function ColorAlpha(color, alpha)
    return Color(color.r, color.g, color.b, alpha)
end

DCUO.Log("Overhead display system loaded", "SUCCESS")

--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Barres de santé au-dessus des entités
    Affiche la santé quand elle est affectée
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

local healthBars = {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    TRACKER LES DÉGÂTS                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("EntityTakeDamage", "DCUO:TrackHealth", function(ent, dmg)
    if not IsValid(ent) then return end
    if not (ent:IsPlayer() or ent:IsNPC()) then return end
    
    -- Activer la barre de santé
    healthBars[ent] = {
        showUntil = CurTime() + 5, -- Afficher pendant 5 secondes
        lastHealth = ent:Health(),
    }
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    AFFICHER BARRES DE SANTÉ                       ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("PostDrawTranslucentRenderables", "DCUO:DrawHealthBars", function()
    for ent, data in pairs(healthBars) do
        if not IsValid(ent) then
            healthBars[ent] = nil
            continue
        end
        
        -- Vérifier si encore affichée
        if CurTime() > data.showUntil then
            healthBars[ent] = nil
            continue
        end
        
        -- Distance check
        local distance = LocalPlayer():GetPos():Distance(ent:GetPos())
        if distance > 1500 then continue end
        
        -- Position
        local pos = ent:GetPos()
        if ent:IsPlayer() then
            pos = pos + Vector(0, 0, 85)
        else
            pos = pos + Vector(0, 0, ent:OBBMaxs().z + 10)
        end
        
        local ang = EyeAngles()
        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), 90)
        
        -- Santé
        local health = ent:Health()
        local maxHealth = ent:GetMaxHealth()
        if maxHealth <= 0 then maxHealth = 100 end
        
        local healthPercent = math.Clamp(health / maxHealth, 0, 1)
        
        cam.Start3D2D(pos, ang, 0.1)
            -- Largeur barre
            local barWidth = 100
            local barHeight = 8
            
            -- Background
            draw.RoundedBox(4, -barWidth/2, 0, barWidth, barHeight, Color(0, 0, 0, 200))
            
            -- Couleur selon santé
            local healthColor = Color(
                255 * (1 - healthPercent),
                255 * healthPercent,
                0
            )
            
            -- Barre de santé
            draw.RoundedBox(4, -barWidth/2 + 1, 1, (barWidth - 2) * healthPercent, barHeight - 2, healthColor)
            
            -- Texte santé
            draw.SimpleText(
                health .. " / " .. maxHealth,
                "DermaDefault",
                0, barHeight/2,
                Color(255, 255, 255),
                TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
            )
            
            -- Nom (pour NPCs)
            if ent:IsNPC() then
                local name = ent:GetClass()
                draw.SimpleText(
                    name,
                    "DermaDefault",
                    0, -10,
                    Color(255, 200, 200),
                    TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
                )
            end
        cam.End3D2D()
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    NETTOYAGE                                      ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("EntityRemoved", "DCUO:CleanupHealthBars", function(ent)
    healthBars[ent] = nil
end)

DCUO.Log("Health bars system loaded", "SUCCESS")

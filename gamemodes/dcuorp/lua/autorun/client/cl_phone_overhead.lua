--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Phone Overhead Text (Client)
    Affiche "Sur son téléphone" au-dessus des joueurs
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    TEXTE AU-DESSUS DES JOUEURS                    ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("PostPlayerDraw", "DCUO:PhoneOverhead", function(ply)
    if not IsValid(ply) then return end
    if ply == LocalPlayer() then return end  -- Ne pas afficher pour soi-même
    
    -- Vérifier si le joueur est sur son téléphone
    if ply:GetNWBool("DCUO_OnPhone", false) then
        local pos = ply:GetPos() + Vector(0, 0, 85)  -- Au-dessus de la tête
        local ang = LocalPlayer():EyeAngles()
        
        -- Faire face au joueur
        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), 90)
        
        cam.Start3D2D(pos, Angle(0, ang.y, 90), 0.1)
            -- Background
            draw.RoundedBox(8, -150, -25, 300, 50, Color(0, 0, 0, 200))
            
            -- Icône téléphone (texte)
            draw.SimpleText(
                "[PHONE]",
                "DermaDefaultBold",
                0, -10,
                Color(52, 152, 219),
                TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
            )
            
            -- Texte
            draw.SimpleText(
                "Sur son téléphone",
                "DermaDefault",
                0, 10,
                Color(255, 255, 255),
                TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
            )
        cam.End3D2D()
    end
end)

print("[DCUO] Phone overhead text loaded")

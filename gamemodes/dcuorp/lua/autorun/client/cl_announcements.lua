--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système d'Annonces (Client)
    Affichage des annonces serveur
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

-- Recevoir les annonces du serveur
-- Important: on enregistre net.Receive au chargement du fichier.
-- Si on attend InitPostEntity, une annonce envoyée tôt (join/map load) peut être perdue.
net.Receive("DCUO:ServerAnnounce", function()
    local message = tostring(net.ReadString() or "")
    local adminName = tostring(net.ReadString() or "")

    print("[DCUO ANNOUNCE CLIENT] Annonce reçue: '" .. message .. "' de " .. adminName)

    if message == "" then
        print("[DCUO ANNOUNCE CLIENT] Message vide, annonce ignorée")
        return
    end

    if not vgui or not vgui.Create then 
        print("[DCUO ANNOUNCE CLIENT] VGUI non disponible")
        return 
    end

    -- Créer la notification d'annonce
    local announce = vgui.Create("DPanel")
    if not IsValid(announce) then
        print("[DCUO ANNOUNCE CLIENT] Impossible de créer le panel")
        return
    end

    print("[DCUO ANNOUNCE CLIENT] Panel créé, affichage de l'annonce")

    local scrW, scrH = ScrW(), ScrH()
    local x = scrW * 0.2
    announce:SetSize(scrW * 0.6, 150)
    announce:SetPos(x, -160)
    announce:MakePopup()
    announce:SetKeyboardInputEnabled(false)
    announce:SetMouseInputEnabled(false)

    local startTime = CurTime()
    local displayTime = 8 -- Durée d'affichage en secondes

    -- Réutiliser les tables Color pour éviter des allocations à chaque frame.
    local colGold = Color(255, 215, 0, 255)
    local colBg = Color(20, 20, 30, 255)
    local colWhite = Color(255, 255, 255, 255)
    local colAdmin = Color(200, 200, 200, 255)

    announce.Paint = function(self, w, h)
        local alpha = 255
        local timeSince = CurTime() - startTime

        -- Fade in (0.5s)
        if timeSince < 0.5 then
            alpha = math.Clamp(timeSince / 0.5 * 255, 0, 255)
        end

        -- Fade out (dernière seconde)
        if timeSince > displayTime - 1 then
            alpha = math.Clamp((displayTime - timeSince) * 255, 0, 255)
        end

        colGold.a = alpha
        colBg.a = alpha
        colWhite.a = alpha
        colAdmin.a = alpha

        -- Fond avec bordure dorée
        draw.RoundedBox(12, 0, 0, w, h, colGold)
        draw.RoundedBox(12, 4, 4, w - 8, h - 8, colBg)

        -- Icône
        draw.SimpleText("📢", "DermaLarge", 30, h / 2, colGold, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        -- Titre
        draw.SimpleText("ANNONCE SERVEUR", "DermaLarge", w / 2, 30, colGold, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        -- Message
        draw.SimpleText(message, "DermaDefaultBold", w / 2, h / 2, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Admin
        draw.SimpleText("- " .. adminName, "DermaDefault", w - 20, h - 20, colAdmin, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    end

    -- Animation de descente
    announce:MoveTo(x, 50, 0.5, 0, -1)

    -- Supprimer après le temps d'affichage
    timer.Simple(displayTime, function()
        if IsValid(announce) then
            announce:MoveTo(x, -160, 0.5, 0, -1, function()
                if IsValid(announce) then
                    announce:Remove()
                end
            end)
        end
    end)

    -- Son
    if surface and surface.PlaySound then
        surface.PlaySound("buttons/button15.wav")
    end

    -- Aussi dans le chat
    if chat and chat.AddText then
        chat.AddText(Color(255, 215, 0), "[ANNONCE] ", color_white, message, Color(150, 150, 150), " - " .. adminName)
    end
end)

print("[DCUO] Module d'annonces chargé")

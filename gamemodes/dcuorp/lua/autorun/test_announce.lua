--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Test Système d'Annonces
    Diagnostic et test des annonces serveur
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then
    -- Commande de test serveur
    concommand.Add("dcuo_test_announce", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then return end
        
        local message = table.concat(args, " ")
        if message == "" then
            message = "Ceci est un test d'annonce serveur !"
        end
        
        print("\n=== TEST ANNONCE SERVEUR ===")
        print("Admin: " .. ply:Nick())
        print("Message: " .. message)
        print("Joueurs connectés: " .. #player.GetAll())
        
        -- Envoyer directement sans passer par AdminAction
        net.Start("DCUO:ServerAnnounce")
            net.WriteString(message)
            net.WriteString(ply:Nick())
        net.Broadcast()
        
        print("Annonce envoyée via net.Broadcast()")
        print("============================\n")
        
        ply:ChatPrint("[TEST] Annonce envoyée: " .. message)
    end)
    
    print("[DCUO] Commande test annonce chargée: dcuo_test_announce [message]")
end

if CLIENT then
    -- Vérifier que le système est chargé
    timer.Simple(2, function()
        print("\n=== DIAGNOSTIC ANNONCES CLIENT ===")
        
        -- Vérifier les net messages
        print("Vérification du système:")
        print("  - DCUO table:", DCUO ~= nil)
        print("  - vgui disponible:", vgui ~= nil)
        print("  - surface disponible:", surface ~= nil)
        
        print("\nPour tester:")
        print("  1. Console serveur: dcuo_test_announce Ceci est un test")
        print("  2. Ou dans le panel admin, onglet 'Annonces'")
        
        print("==================================\n")
    end)
    
    -- Commande pour simuler une annonce côté client (test visuel)
    concommand.Add("dcuo_fake_announce", function(ply, cmd, args)
        local message = table.concat(args, " ")
        if message == "" then
            message = "Test annonce locale (simulation)"
        end
        
        print("[DCUO] Simulation d'annonce: " .. message)
        
        -- Créer directement l'UI
        local announce = vgui.Create("DPanel")
        if not IsValid(announce) then
            print("[ERREUR] Impossible de créer le panel")
            return
        end
        
        local scrW, scrH = ScrW(), ScrH()
        local x = scrW * 0.2
        announce:SetSize(scrW * 0.6, 150)
        announce:SetPos(x, -160)
        announce:MakePopup()
        announce:SetKeyboardInputEnabled(false)
        announce:SetMouseInputEnabled(false)
        
        local startTime = CurTime()
        local displayTime = 8
        
        announce.Paint = function(self, w, h)
            local alpha = 255
            local timeSince = CurTime() - startTime
            
            if timeSince < 0.5 then
                alpha = math.Clamp(timeSince / 0.5 * 255, 0, 255)
            end
            
            if timeSince > displayTime - 1 then
                alpha = math.Clamp((displayTime - timeSince) * 255, 0, 255)
            end
            
            -- Fond avec bordure dorée
            draw.RoundedBox(12, 0, 0, w, h, Color(255, 215, 0, alpha))
            draw.RoundedBox(12, 4, 4, w - 8, h - 8, Color(20, 20, 30, alpha))
            
            -- Icône
            draw.SimpleText("📢", "DermaLarge", 30, h / 2, Color(255, 215, 0, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            -- Titre
            draw.SimpleText("ANNONCE SERVEUR", "DermaLarge", w / 2, 30, Color(255, 215, 0, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            
            -- Message
            draw.SimpleText(message, "DermaDefaultBold", w / 2, h / 2, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            -- Admin
            draw.SimpleText("- Test Local", "DermaDefault", w - 20, h - 20, Color(200, 200, 200, alpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        end
        
        -- Animation
        announce:MoveTo(x, 50, 0.5, 0, -1)
        
        timer.Simple(displayTime, function()
            if IsValid(announce) then
                announce:MoveTo(x, -160, 0.5, 0, -1, function()
                    if IsValid(announce) then
                        announce:Remove()
                    end
                end)
            end
        end)
        
        surface.PlaySound("buttons/button15.wav")
        
        print("[DCUO] Annonce simulée affichée")
    end)
    
    print("[DCUO] Commande test local chargée: dcuo_fake_announce [message]")
end

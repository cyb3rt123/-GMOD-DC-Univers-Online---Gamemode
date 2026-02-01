--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - DCUO Phone UI
    Interface du téléphone avec accès à tous les menus
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

DCUO.Phone = DCUO.Phone or {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONTS                                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

surface.CreateFont("DCUO_Phone_Title", {
    font = "Roboto",
    size = 32,
    weight = 700,
    antialias = true,
})

surface.CreateFont("DCUO_Phone_AppName", {
    font = "Roboto",
    size = 18,
    weight = 600,
    antialias = true,
})

surface.CreateFont("DCUO_Phone_Time", {
    font = "Roboto",
    size = 20,
    weight = 500,
    antialias = true,
})

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CONFIGURATION DES APPS                         ║
-- ╚═══════════════════════════════════════════════════════════════════╝

local apps = {
    {
        name = "Métiers",
        icon = "[J]",
        color = Color(52, 152, 219),
        func = function()
            if DCUO.UI and DCUO.UI.OpenMainMenu then
                DCUO.UI.OpenMainMenu()
            else
                chat.AddText(Color(255, 100, 100), "[Phone] ", Color(255, 255, 255), "Menu métiers non disponible")
            end
        end,
        desc = "Changer de métier"
    },
    {
        name = "Pouvoirs",
        icon = "[P]",
        color = Color(155, 89, 182),
        func = function()
            chat.AddText(Color(255, 165, 0), "[Phone] ", Color(255, 255, 255), "Menu Pouvoirs en développement")
        end,
        desc = "Gérer vos pouvoirs"
    },
    {
        name = "Missions",
        icon = "[M]",
        color = Color(46, 204, 113),
        func = function()
            chat.AddText(Color(255, 165, 0), "[Phone] ", Color(255, 255, 255), "Menu Missions en développement")
        end,
        desc = "Missions disponibles"
    },
    {
        name = "Auras",
        icon = "[A]",
        color = Color(241, 196, 15),
        func = function()
            if DCUO.AuraShop and DCUO.AuraShop.Open then
                DCUO.AuraShop.Open()
            else
                chat.AddText(Color(255, 100, 100), "[Phone] ", Color(255, 255, 255), "Boutique d'auras non disponible")
            end
        end,
        desc = "Boutique d'auras"
    },
    {
        name = "Guildes",
        icon = "[G]",
        color = Color(230, 126, 34),
        func = function()
            if DCUO.Guilds and DCUO.Guilds.OpenMenu then
                DCUO.Guilds.OpenMenu()
            else
                chat.AddText(Color(255, 100, 100), "[Phone] ", Color(255, 255, 255), "Menu guildes non disponible")
            end
        end,
        desc = "Votre guilde"
    },
    {
        name = "Amis",
        icon = "[F]",
        color = Color(26, 188, 156),
        func = function()
            chat.AddText(Color(255, 165, 0), "[Phone] ", Color(255, 255, 255), "Liste d'amis en développement")
        end,
        desc = "Liste d'amis"
    },
    {
        name = "Admin",
        icon = "[!]",
        color = Color(231, 76, 60),
        func = function()
            if LocalPlayer():IsAdmin() then
                net.Start("DCUO:AdminPanel")
                net.SendToServer()
            else
                chat.AddText(Color(231, 76, 60), "[Phone] ", Color(255, 255, 255), "Accès réservé aux administrateurs")
            end
        end,
        desc = "Panel admin",
        adminOnly = true
    },
    {
        name = "Profil",
        icon = "[i]",
        color = Color(149, 165, 166),
        func = function()
            local ply = LocalPlayer()
            if not ply.DCUOData then 
                chat.AddText(Color(255, 100, 100), "[Phone] ", Color(255, 255, 255), "Données joueur non chargées")
                return 
            end
            
            chat.AddText(
                Color(52, 152, 219), "═══════════════════════════",
                Color(255, 255, 255), "\n[i] Profil de ", Color(255, 215, 0), ply:Nick(),
                Color(255, 255, 255), "\n[LVL] Niveau: ", Color(0, 255, 0), tostring(ply.DCUOData.level or 1),
                Color(255, 255, 255), " | XP: ", Color(100, 200, 255), tostring(ply.DCUOData.xp or 0),
                Color(255, 255, 255), "\n[J] Métier: ", Color(255, 165, 0), ply:getDarkRPVar("job") or "Citoyen",
                Color(52, 152, 219), "\n═══════════════════════════"
            )
        end,
        desc = "Voir votre profil"
    },
    {
        name = "Paramètres",
        icon = "[*]",
        color = Color(127, 140, 141),
        func = function()
            chat.AddText(Color(255, 165, 0), "[Phone] ", Color(255, 255, 255), "Paramètres en développement")
        end,
        desc = "Réglages du téléphone"
    }
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    OUVRIR LE TÉLÉPHONE                            ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Phone.Open()
    if IsValid(DCUO.Phone.Frame) then
        DCUO.Phone.Frame:Remove()
        return
    end
    
    local scrW, scrH = ScrW(), ScrH()
    
    -- Dimensions style smartphone moderne
    local phoneW = 450
    local phoneH = 750
    
    -- Frame principale
    local frame = vgui.Create("DFrame")
    frame:SetSize(phoneW, phoneH)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    DCUO.Phone.Frame = frame
    
    -- Animation d'entrée
    local targetX, targetY = frame.x, frame.y
    frame.y = scrH
    frame:MoveTo(targetX, targetY, 0.4, 0, 0.5)
    
    frame.Paint = function(self, w, h)
        -- Fond moderne
        draw.RoundedBox(12, 0, 0, w, h, Color(20, 20, 30, 250))
        
        -- Bordure élégante
        surface.SetDrawColor(52, 152, 219, 180)
        for i = 1, 2 do
            surface.DrawOutlinedRect(i-1, i-1, w-(i-1)*2, h-(i-1)*2, 1)
        end
        
        -- Header bar
        draw.RoundedBoxEx(12, 0, 0, w, 70, Color(30, 30, 40, 255), true, true, false, false)
        
        -- Titre principal
        draw.SimpleText("DCUO PHONE", "DCUO_Phone_Title", w/2, 20, Color(52, 152, 219), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        
        -- Sous-titre
        local timeStr = os.date("%H:%M")
        draw.SimpleText(timeStr .. " | Menu Principal", "DermaDefault", w/2, 50, Color(150, 150, 160), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        
        -- Ligne séparatrice
        surface.SetDrawColor(52, 152, 219, 100)
        surface.DrawRect(0, 70, w, 1)
        
        -- Footer bar
        draw.RoundedBoxEx(12, 0, h - 35, w, 35, Color(30, 30, 40, 255), false, false, true, true)
        draw.SimpleText("F3 pour ouvrir/fermer", "DermaDefault", w/2, h - 18, Color(100, 100, 110), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Son d'ouverture
    surface.PlaySound("buttons/button14.wav")
    
    -- Bouton fermer amélioré
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetSize(40, 40)
    closeBtn:SetPos(phoneW - 50, 15)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(231, 76, 60) or Color(100, 50, 50)
        draw.RoundedBox(6, 0, 0, w, h, col)
        
        -- X blanc
        surface.SetDrawColor(255, 255, 255)
        surface.DrawLine(12, 12, w-12, h-12)
        surface.DrawLine(w-12, 12, 12, h-12)
        
        if self:IsHovered() then
            surface.SetDrawColor(255, 255, 255, 50)
            surface.DrawRect(0, 0, w, h)
        end
    end
    closeBtn.DoClick = function()
        surface.PlaySound("buttons/button10.wav")
        frame:MoveTo(frame.x, scrH, 0.3, 0, -1, function()
            frame:Remove()
        end)
    end
    
    -- Scroll panel pour les apps
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(15, 85)
    scroll:SetSize(phoneW - 30, phoneH - 135)
    
    -- Barre de scroll personnalisée
    local sbar = scroll:GetVBar()
    sbar:SetWide(8)
    sbar.Paint = function(self, w, h) 
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 50))
    end
    sbar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(52, 152, 219, 200))
    end
    sbar.btnUp.Paint = function() end
    sbar.btnDown.Paint = function() end
    
    -- Grille d'applications
    local appsPerRow = 3
    local appSize = (phoneW - 60) / appsPerRow
    local xPos = 0
    local yPos = 0
    local count = 0
    
    for _, app in ipairs(apps) do
        -- Vérifier si admin only
        if app.adminOnly and not LocalPlayer():IsAdmin() then
            continue
        end
        
        -- Créer l'icône d'app
        local appBtn = vgui.Create("DButton", scroll)
        appBtn:SetSize(appSize - 10, appSize + 20)
        appBtn:SetPos(xPos + 5, yPos)
        appBtn:SetText("")
        
        local hovered = false
        
        appBtn.Paint = function(self, w, h)
            -- Fond de l'app avec effet de profondeur
            local bgColor = hovered and Color(app.color.r * 0.3, app.color.g * 0.3, app.color.b * 0.3, 220) or Color(30, 30, 40, 200)
            draw.RoundedBox(10, 0, 0, w, h, bgColor)
            
            -- Bordure colorée
            if hovered then
                surface.SetDrawColor(app.color.r, app.color.g, app.color.b, 255)
                surface.DrawOutlinedRect(0, 0, w, h, 3)
            else
                surface.SetDrawColor(app.color.r, app.color.g, app.color.b, 100)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
            end
            
            -- Icône carrée colorée en haut
            local iconSize = 50
            draw.RoundedBox(8, w/2 - iconSize/2, 15, iconSize, iconSize, Color(app.color.r, app.color.g, app.color.b, hovered and 200 or 150))
            
            -- Texte de l'icône
            draw.SimpleText(
                app.icon,
                "DCUO_Phone_Title",
                w/2, 40,
                Color(255, 255, 255),
                TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
            )
            
            -- Nom de l'app
            draw.SimpleText(
                app.name,
                "DCUO_Phone_AppName",
                w/2, h - 35,
                Color(255, 255, 255),
                TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
            )
            
            -- Description (au survol)
            if hovered then
                draw.SimpleText(
                    app.desc,
                    "DermaDefault",
                    w/2, h - 15,
                    Color(app.color.r, app.color.g, app.color.b),
                    TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
                )
            end
        end
        
        appBtn.OnCursorEntered = function(self)
            hovered = true
            surface.PlaySound("UI/buttonrollover.wav")
        end
        
        appBtn.OnCursorExited = function(self)
            hovered = false
        end
        
        appBtn.DoClick = function()
            surface.PlaySound("buttons/button14.wav")
            
            if app.func then
                app.func()
            end
            
            -- Fermer le téléphone après ouverture d'une app
            timer.Simple(0.1, function()
                if IsValid(frame) then
                    frame:MoveTo(frame.x, scrH, 0.3, 0, -1, function()
                        frame:Remove()
                    end)
                end
            end)
        end
        
        -- Position suivante
        count = count + 1
        xPos = xPos + appSize
        
        if count % appsPerRow == 0 then
            xPos = 0
            yPos = yPos + appSize + 30
        end
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    BIND CLAVIER (OPTIONNEL)                       ║
-- ╚═══════════════════════════════════════════════════════════════════╝

concommand.Add("dcuo_phone", function()
    DCUO.Phone.Open()
end)

concommand.Add("dcuo_test_phone", function()
    print("[DCUO Phone] Test du téléphone...")
    print("[DCUO Phone] DCUO.Phone existe: " .. tostring(DCUO.Phone ~= nil))
    print("[DCUO Phone] DCUO.Phone.Open existe: " .. tostring(DCUO.Phone.Open ~= nil))
    
    if DCUO.Phone and DCUO.Phone.Open then
        print("[DCUO Phone] Ouverture du menu...")
        DCUO.Phone.Open()
        print("[DCUO Phone] Menu ouvert !")
    else
        print("[DCUO Phone] ERREUR: Fonction Open() non disponible !")
    end
end)

-- Bind F3 pour ouvrir le téléphone
hook.Add("PlayerButtonDown", "DCUO:PhoneHotkey", function(ply, button)
    if button == KEY_F3 then
        DCUO.Phone.Open()
    end
end)

print("[DCUO Phone] UI loaded - Use 'dcuo_phone', 'dcuo_test_phone' or F3 to open")

DCUO.Log("DCUO Phone UI loaded", "SUCCESS")

--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Panel Admin
    Interface d'administration complète
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

DCUO.Admin = DCUO.Admin or {}

local adminPanel = nil

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    OUVRIR LE PANEL ADMIN                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Admin.OpenPanel()
    if IsValid(adminPanel) then
        adminPanel:Remove()
    end
    
    local scrW, scrH = ScrW(), ScrH()
    
    -- Frame principale
    adminPanel = vgui.Create("DFrame")
    adminPanel:SetSize(1200, 800)
    adminPanel:SetPos(scrW / 2 - 600, scrH / 2 - 400)
    adminPanel:SetTitle("")
    adminPanel:SetDraggable(true)
    adminPanel:ShowCloseButton(true)
    adminPanel:MakePopup()
    
    adminPanel.Paint = function(self, w, h)
        -- Background
        Derma_DrawBackgroundBlur(self, CurTime())
        draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(DCUO.Colors.Dark, 240))
        
        -- Bordure
        surface.SetDrawColor(DCUO.Colors.Hero.r, DCUO.Colors.Hero.g, DCUO.Colors.Hero.b, 200)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        -- Header
        draw.RoundedBox(0, 0, 0, w, 60, ColorAlpha(DCUO.Colors.Hero, 200))
        draw.SimpleText("DCUO-RP - PANEL ADMIN", "DCUO_HUD_Large", 20, 30, DCUO.Colors.Light, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        -- Version
        draw.SimpleText("v" .. DCUO.Version, "DCUO_HUD_Tiny", w - 20, 30, DCUO.Colors.Light, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    
    -- Sidebar
    local sidebar = vgui.Create("DPanel", adminPanel)
    sidebar:SetPos(10, 70)
    sidebar:SetSize(200, adminPanel:GetTall() - 80)
    sidebar.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, ColorAlpha(DCUO.Colors.Dark, 200))
        surface.SetDrawColor(DCUO.Colors.Electric.r, DCUO.Colors.Electric.g, DCUO.Colors.Electric.b, 100)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    -- Content panel
    local content = vgui.Create("DPanel", adminPanel)
    content:SetPos(220, 70)
    content:SetSize(adminPanel:GetWide() - 230, adminPanel:GetTall() - 80)
    content.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, ColorAlpha(DCUO.Colors.Dark, 200))
        surface.SetDrawColor(DCUO.Colors.Electric.r, DCUO.Colors.Electric.g, DCUO.Colors.Electric.b, 100)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    -- ═══ BOUTONS SIDEBAR ═══
    local buttons = {
        {name = "Joueurs", icon = "icon16/group.png", func = function() DCUO.Admin.ShowPlayers(content) end},
        {name = "Annonces", icon = "icon16/comments.png", func = function() DCUO.Admin.ShowAnnounce(content) end},
        {name = "Événements", icon = "icon16/star.png", func = function() DCUO.Admin.ShowEvents(content) end},
        {name = "Missions", icon = "icon16/map.png", func = function() DCUO.Admin.ShowMissions(content) end},
        {name = "XP Manager", icon = "icon16/chart_bar.png", func = function() DCUO.Admin.ShowXPManager(content) end},
        {name = "Notifications", icon = "icon16/information.png", func = function() DCUO.Admin.ShowNotifications(content) end},
        {name = "Logs", icon = "icon16/book.png", func = function() DCUO.Admin.ShowLogs(content) end},
    }
    
    for i, btn in ipairs(buttons) do
        local button = vgui.Create("DButton", sidebar)
        button:SetPos(10, 10 + (i - 1) * 50)
        button:SetSize(180, 45)
        button:SetText("")
        
        button.Paint = function(self, w, h)
            local bgColor = ColorAlpha(DCUO.Colors.Dark, 150)
            
            if self:IsHovered() then
                bgColor = ColorAlpha(DCUO.Colors.Electric, 150)
            end
            
            draw.RoundedBox(4, 0, 0, w, h, bgColor)
            
            -- Icon
            surface.SetDrawColor(255, 255, 255, 255)
            if btn.icon then
                surface.SetMaterial(Material(btn.icon))
                surface.DrawTexturedRect(10, 12, 20, 20)
            end
            
            -- Text
            draw.SimpleText(btn.name, "DCUO_HUD_Small", 40, h / 2, DCUO.Colors.Light, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        button.DoClick = btn.func
    end
    
    -- Afficher la page par défaut
    DCUO.Admin.ShowPlayers(content)
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    PAGE: ANNONCES                                 ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Admin.ShowAnnounce(parent)
    parent:Clear()
    
    -- Titre
    local title = vgui.Create("DLabel", parent)
    title:SetPos(20, 20)
    title:SetText("ANNONCES SERVEUR")
    title:SetFont("DCUO_HUD_Medium")
    title:SetTextColor(DCUO.Colors.Electric)
    title:SizeToContents()
    
    -- Description
    local desc = vgui.Create("DLabel", parent)
    desc:SetPos(20, 60)
    desc:SetText("Envoyer un message à tous les joueurs connectés")
    desc:SetFont("DermaDefault")
    desc:SetTextColor(Color(200, 200, 200))
    desc:SizeToContents()
    
    -- Zone de texte
    local textEntry = vgui.Create("DTextEntry", parent)
    textEntry:SetPos(20, 100)
    textEntry:SetSize(parent:GetWide() - 40, 35)
    textEntry:SetPlaceholderText("Entrez votre message d'annonce ici...")
    textEntry:SetFont("DermaDefault")
    
    -- Bouton envoyer
    local btnSend = vgui.Create("DButton", parent)
    btnSend:SetPos(20, 145)
    btnSend:SetSize(200, 40)
    btnSend:SetText("Envoyer l'annonce")
    btnSend:SetFont("DermaDefaultBold")
    
    btnSend.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(46, 204, 113) or Color(52, 152, 219)
        draw.RoundedBox(6, 0, 0, w, h, col)
        draw.SimpleText(self:GetText(), "DermaDefaultBold", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    btnSend.DoClick = function()
        local message = textEntry:GetValue()
        
        if not message or message == "" then
            Derma_Message("Veuillez entrer un message !", "Erreur", "OK")
            return
        end
        
        -- Envoyer au serveur
        net.Start("DCUO:AdminAction")
            net.WriteString("announce")
            net.WriteString(message)
        net.SendToServer()
        
        -- Notification locale
        notification.AddLegacy("Annonce envoyée: " .. message, NOTIFY_GENERIC, 5)
        
        -- Vider le champ
        textEntry:SetValue("")
    end
    
    -- Preview de l'annonce
    local preview = vgui.Create("DPanel", parent)
    preview:SetPos(20, 200)
    preview:SetSize(parent:GetWide() - 40, parent:GetTall() - 220)
    
    preview.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(35, 35, 45))
        draw.SimpleText("Aperçu de l'annonce:", "DermaDefaultBold", 10, 10, Color(200, 200, 200))
        
        local message = textEntry:GetValue()
        if message and message ~= "" then
            -- Simuler l'affichage de l'annonce
            draw.RoundedBox(8, 10, 40, w - 20, 100, Color(255, 215, 0, 230))
            draw.SimpleText("📢 ANNONCE SERVEUR", "DermaLarge", w/2, 60, Color(0, 0, 0), TEXT_ALIGN_CENTER)
            draw.SimpleText(message, "DermaDefaultBold", w/2, 100, Color(0, 0, 0), TEXT_ALIGN_CENTER)
            draw.SimpleText("- " .. LocalPlayer():Nick(), "DermaDefault", w/2, 120, Color(50, 50, 50), TEXT_ALIGN_CENTER)
        end
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    PAGE: JOUEURS                                  ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Admin.ShowPlayers(parent)
    parent:Clear()
    
    -- Titre
    local title = vgui.Create("DLabel", parent)
    title:SetPos(20, 20)
    title:SetText("GESTION DES JOUEURS")
    title:SetFont("DCUO_HUD_Medium")
    title:SetTextColor(DCUO.Colors.Electric)
    title:SizeToContents()
    
    -- Liste des joueurs
    local playerList = vgui.Create("DListView", parent)
    playerList:SetPos(20, 60)
    playerList:SetSize(parent:GetWide() - 40, parent:GetTall() - 80)
    playerList:SetMultiSelect(false)
    playerList:AddColumn("Nom"):SetFixedWidth(200)
    playerList:AddColumn("RP Name"):SetFixedWidth(200)
    playerList:AddColumn("Job"):SetFixedWidth(150)
    playerList:AddColumn("Niveau"):SetFixedWidth(80)
    playerList:AddColumn("Faction"):SetFixedWidth(120)
    playerList:AddColumn("Actions")
    
    -- Remplir la liste
    for _, ply in ipairs(player.GetAll()) do
        local data = ply.DCUOData or {}
        local line = playerList:AddLine(
            ply:Nick(),
            data.rpname or "N/A",
            data.job or "N/A",
            data.level or 1,
            data.faction or "N/A"
        )
        line.Player = ply
    end
    
    -- Menu contextuel
    playerList.OnRowRightClick = function(self, lineID, line)
        local ply = line.Player
        if not IsValid(ply) then return end
        
        local menu = DermaMenu()
        
        menu:AddOption("Donner XP", function()
            Derma_StringRequest(
                "Donner XP",
                "Combien d'XP voulez-vous donner?",
                "100",
                function(text)
                    local amount = tonumber(text)
                    if amount then
                        net.Start("DCUO:AdminAction")
                            net.WriteString("givexp")
                            net.WriteEntity(ply)
                            net.WriteInt(amount, 32)
                        net.SendToServer()
                    end
                end
            )
        end):SetIcon("icon16/add.png")
        
        menu:AddOption("Définir Niveau", function()
            Derma_StringRequest(
                "Définir Niveau",
                "Quel niveau?",
                "10",
                function(text)
                    local level = tonumber(text)
                    if level then
                        net.Start("DCUO:AdminAction")
                            net.WriteString("setlevel")
                            net.WriteEntity(ply)
                            net.WriteInt(level, 16)
                        net.SendToServer()
                    end
                end
            )
        end):SetIcon("icon16/star.png")

        local subMenu, subOption = menu:AddSubMenu("Définir Job")
        if subOption and subOption.SetIcon then
            subOption:SetIcon("icon16/user_edit.png")
        end

        if not (DCUO.Jobs and DCUO.Jobs.GetAll) then
            subMenu:AddOption("(Jobs non initialisés)")
        else
            local jobs = DCUO.Jobs.GetAll()
            if not istable(jobs) then
                subMenu:AddOption("(Liste des jobs invalide)")
            else
                for jobID, job in SortedPairsByMemberValue(jobs, "name") do
                    subMenu:AddOption((job and job.name) or tostring(jobID), function()
                        net.Start("DCUO:AdminAction")
                            net.WriteString("setjob")
                            net.WriteEntity(ply)
                            net.WriteString(tostring(jobID))
                        net.SendToServer()
                    end)
                end
            end
        end
        
        menu:AddOption("TP vers moi", function()
            net.Start("DCUO:AdminAction")
                net.WriteString("bring")
                net.WriteEntity(ply)
            net.SendToServer()
        end):SetIcon("icon16/arrow_refresh.png")
        
        menu:AddOption("Me TP vers", function()
            net.Start("DCUO:AdminAction")
                net.WriteString("goto")
                net.WriteEntity(ply)
            net.SendToServer()
        end):SetIcon("icon16/arrow_right.png")
        
        menu:Open()
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    PAGE: ÉVÉNEMENTS                               ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Admin.ShowEvents(parent)
    parent:Clear()
    
    -- Titre
    local title = vgui.Create("DLabel", parent)
    title:SetPos(20, 20)
    title:SetText("GESTION DES ÉVÉNEMENTS")
    title:SetFont("DCUO_HUD_Medium")
    title:SetTextColor(DCUO.Colors.Electric)
    title:SizeToContents()
    
    -- Description
    local desc = vgui.Create("DLabel", parent)
    desc:SetPos(20, 50)
    desc:SetText("Lancer des événements aléatoires ou spawner des boss de test")
    desc:SetFont("DCUO_HUD_Tiny")
    desc:SetTextColor(Color(200, 200, 200))
    desc:SizeToContents()
    
    -- Section événements aléatoires
    local randomEventPanel = vgui.Create("DPanel", parent)
    randomEventPanel:SetPos(20, 90)
    randomEventPanel:SetSize(parent:GetWide() - 40, 150)
    randomEventPanel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 45, 240))
        surface.SetDrawColor(52, 152, 219, 150)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        draw.SimpleText("ÉVÉNEMENTS ALÉATOIRES", "DCUO_Font_Medium", 15, 15, Color(52, 152, 219))
        draw.SimpleText("Lance un événement surprise pour tous les joueurs", "DCUO_Font_Small", 15, 45, Color(200, 200, 200))
    end
    
    local spawnRandomBtn = vgui.Create("DButton", randomEventPanel)
    spawnRandomBtn:SetPos(15, 80)
    spawnRandomBtn:SetSize(300, 50)
    spawnRandomBtn:SetText("")
    spawnRandomBtn.Paint = function(self, w, h)
        local color = Color(52, 152, 219)
        if self:IsHovered() then
            color = Color(color.r + 30, color.g + 30, color.b + 30)
        end
        draw.RoundedBox(6, 0, 0, w, h, color)
        draw.SimpleText("LANCER ÉVÉNEMENT ALÉATOIRE", "DCUO_Font_Medium", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    spawnRandomBtn.DoClick = function()
        net.Start("DCUO:AdminAction")
            net.WriteString("spawnevent")
        net.SendToServer()
        
        DCUO.UI.AddNotification("Événement aléatoire lancé!", Color(52, 152, 219), 3)
    end
    
    -- Section boss
    local bossPanel = vgui.Create("DPanel", parent)
    bossPanel:SetPos(20, 260)
    bossPanel:SetSize(parent:GetWide() - 40, parent:GetTall() - 280)
    bossPanel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 45, 240))
        surface.SetDrawColor(231, 76, 60, 150)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        draw.SimpleText("SPAWN DE BOSS", "DCUO_Font_Medium", 15, 15, Color(231, 76, 60))
        draw.SimpleText("Créer un boss à votre position pour tester le combat", "DCUO_Font_Small", 15, 45, Color(200, 200, 200))
    end
    
    -- Scroll pour les boss
    local bossScroll = vgui.Create("DScrollPanel", bossPanel)
    bossScroll:SetPos(15, 80)
    bossScroll:SetSize(bossPanel:GetWide() - 30, bossPanel:GetTall() - 95)
    
    local sbar = bossScroll:GetVBar()
    sbar:SetWide(8)
    sbar.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 25, 200))
    end
    sbar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(231, 76, 60, 200))
    end
    sbar.btnUp.Paint = function() end
    sbar.btnDown.Paint = function() end
    
    -- Boutons pour chaque boss
    if DCUO.Bosses and DCUO.Bosses.List then
        local y = 0
        for bossID, boss in SortedPairsByMemberValue(DCUO.Bosses.List, "name") do
            local bossBtn = vgui.Create("DButton", bossScroll)
            bossBtn:SetPos(0, y)
            bossBtn:SetSize(bossScroll:GetWide() - 10, 60)
            bossBtn:SetText("")
            
            bossBtn.Paint = function(self, w, h)
                local col = Color(45, 45, 55)
                if self:IsHovered() then
                    col = Color(231, 76, 60, 100)
                end
                draw.RoundedBox(6, 0, 0, w, h, col)
                surface.SetDrawColor(231, 76, 60, 150)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
                
                draw.SimpleText(boss.name, "DCUO_Font_Medium", 15, 15, Color(255, 100, 100))
                local info = "Niveau: " .. (boss.level or 10) .. " | Santé: " .. (boss.health or 5000)
                draw.SimpleText(info, "DCUO_Font_Small", 15, 40, Color(200, 200, 200))
            end
            
            bossBtn.DoClick = function()
                net.Start("DCUO:AdminAction")
                    net.WriteString("spawnboss")
                    net.WriteString(bossID)
                net.SendToServer()
                
                DCUO.UI.AddNotification("Boss '" .. boss.name .. "' spawné!", Color(231, 76, 60), 3)
            end
            
            y = y + 70
        end
    else
        local noBoss = vgui.Create("DLabel", bossScroll)
        noBoss:SetPos(10, 10)
        noBoss:SetText("Aucun boss disponible")
        noBoss:SetFont("DCUO_Font_Medium")
        noBoss:SetTextColor(Color(150, 150, 150))
        noBoss:SizeToContents()
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    PAGE: NOTIFICATIONS                            ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Admin.ShowNotifications(parent)
    parent:Clear()
    
    -- Titre
    local title = vgui.Create("DLabel", parent)
    title:SetPos(20, 20)
    title:SetText("ENVOYER UNE NOTIFICATION GLOBALE")
    title:SetFont("DCUO_HUD_Medium")
    title:SetTextColor(DCUO.Colors.Electric)
    title:SizeToContents()
    
    -- Zone de texte
    local textEntry = vgui.Create("DTextEntry", parent)
    textEntry:SetPos(20, 70)
    textEntry:SetSize(parent:GetWide() - 40, 100)
    textEntry:SetMultiline(true)
    textEntry:SetPlaceholderText("Message à envoyer à tous les joueurs...")
    
    -- Bouton envoyer
    local sendBtn = vgui.Create("DButton", parent)
    sendBtn:SetPos(20, 180)
    sendBtn:SetSize(200, 50)
    sendBtn:SetText("")
    sendBtn.Paint = function(self, w, h)
        local color = DCUO.Colors.Hero
        if self:IsHovered() then
            color = ColorAlpha(color, 230)
        end
        draw.RoundedBox(6, 0, 0, w, h, color)
        draw.SimpleText("ENVOYER", "DCUO_HUD_Small", w / 2, h / 2, DCUO.Colors.Light, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    sendBtn.DoClick = function()
        local message = textEntry:GetValue()
        if message and message ~= "" then
            net.Start("DCUO:AdminAction")
                net.WriteString("notify")
                net.WriteString(message)
            net.SendToServer()
            
            textEntry:SetValue("")
            DCUO.UI.AddNotification("Notification envoyée!", DCUO.Colors.Success, 3)
        end
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    AUTRES PAGES (PLACEHOLDER)                     ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Admin.ShowMissions(parent)
    parent:Clear()
    
    -- Titre
    local title = vgui.Create("DLabel", parent)
    title:SetPos(20, 20)
    title:SetText("GESTION DES MISSIONS")
    title:SetFont("DCUO_HUD_Medium")
    title:SetTextColor(DCUO.Colors.Electric)
    title:SizeToContents()
    
    -- Description
    local desc = vgui.Create("DLabel", parent)
    desc:SetPos(20, 50)
    desc:SetText("Créer des missions de test pour les joueurs")
    desc:SetFont("DCUO_HUD_Tiny")
    desc:SetTextColor(Color(200, 200, 200))
    desc:SizeToContents()
    
    -- Bouton copier position
    local posBtn = vgui.Create("DButton", parent)
    posBtn:SetPos(parent:GetWide() - 220, 20)
    posBtn:SetSize(200, 40)
    posBtn:SetText("")
    posBtn.Paint = function(self, w, h)
        local col = Color(52, 152, 219)
        if self:IsHovered() then
            col = Color(col.r + 30, col.g + 30, col.b + 30)
        end
        draw.RoundedBox(6, 0, 0, w, h, col)
        draw.SimpleText("COPIER POSITION", "DCUO_Font_Small", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    posBtn.DoClick = function()
        net.Start("DCUO:AdminAction")
            net.WriteString("getposition")
        net.SendToServer()
    end
    
    -- Scroll panel pour les missions disponibles
    local missionScroll = vgui.Create("DScrollPanel", parent)
    missionScroll:SetPos(20, 90)
    missionScroll:SetSize(parent:GetWide() - 40, parent:GetTall() - 110)
    
    -- Style scrollbar
    local sbar = missionScroll:GetVBar()
    sbar:SetWide(8)
    sbar.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 25, 200))
    end
    sbar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(52, 152, 219, 200))
    end
    sbar.btnUp.Paint = function() end
    sbar.btnDown.Paint = function() end
    
    -- Liste des missions
    local y = 0
    for missionID, mission in SortedPairsByMemberValue(DCUO.Missions.List, "name") do
        local missionPanel = vgui.Create("DPanel", missionScroll)
        missionPanel:SetPos(0, y)
        missionPanel:SetSize(missionScroll:GetWide() - 10, 100)
        
        missionPanel.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 45, 240))
            surface.SetDrawColor(230, 126, 34, 150)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
            
            -- Nom
            draw.SimpleText(mission.name, "DCUO_Font_Medium", 15, 15, Color(255, 200, 0))
            
            -- Description
            local desc = mission.description or "Aucune description"
            draw.SimpleText(desc, "DCUO_Font_Small", 15, 40, Color(200, 200, 200))
            
            -- Niveau et récompense
            draw.SimpleText("Niveau: " .. (mission.levelRequired or 1), "DCUO_Font_Small", 15, 65, Color(100, 200, 255))
            draw.SimpleText("XP: " .. (mission.xpReward or 0), "DCUO_Font_Small", 200, 65, Color(155, 89, 182))
        end
        
        -- Bouton spawn
        local spawnBtn = vgui.Create("DButton", missionPanel)
        spawnBtn:SetPos(missionPanel:GetWide() - 220, 30)
        spawnBtn:SetSize(200, 40)
        spawnBtn:SetText("")
        spawnBtn.Paint = function(self, w, h)
            local col = Color(46, 204, 113)
            if self:IsHovered() then
                col = Color(col.r + 20, col.g + 20, col.b + 20)
            end
            draw.RoundedBox(6, 0, 0, w, h, col)
            draw.SimpleText("SPAWN MISSION", "DCUO_Font_Small", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        spawnBtn.DoClick = function()
            net.Start("DCUO:AdminAction")
                net.WriteString("spawnmission")
                net.WriteString(missionID)
            net.SendToServer()
            
            DCUO.UI.AddNotification("Mission '" .. mission.name .. "' créée!", Color(46, 204, 113), 3)
        end
        
        y = y + 110
    end
end

-- Recevoir la position
net.Receive("DCUO:AdminPosition", function()
    local pos = net.ReadVector()
    local ang = net.ReadAngle()
    
    local posString = string.format([[
-- Position copiée
{
    pos = Vector(%.2f, %.2f, %.2f),
    ang = Angle(%.2f, %.2f, %.2f),
    radius = 500,
    name = "Point de spawn",
    types = {"combat", "collect"},
}
]], pos.x, pos.y, pos.z, ang.p, ang.y, ang.r)
    
    SetClipboardText(posString)
    DCUO.UI.AddNotification("Position copiée dans le presse-papier!", Color(46, 204, 113), 3)
    
    print("=== POSITION COPIÉE ===")
    print(posString)
    print("========================")
end)

function DCUO.Admin.ShowXPManager(parent)
    parent:Clear()
    local label = vgui.Create("DLabel", parent)
    label:SetPos(20, 20)
    label:SetText("XP MANAGER - À implémenter")
    label:SetFont("DCUO_HUD_Medium")
    label:SetTextColor(DCUO.Colors.Light)
    label:SizeToContents()
end

function DCUO.Admin.ShowLogs(parent)
    parent:Clear()
    local label = vgui.Create("DLabel", parent)
    label:SetPos(20, 20)
    label:SetText("LOGS - À implémenter")
    label:SetFont("DCUO_HUD_Medium")
    label:SetTextColor(DCUO.Colors.Light)
    label:SizeToContents()
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    NETWORK                                        ║
-- ╚═══════════════════════════════════════════════════════════════════╝

net.Receive("DCUO:AdminPanel", function()
    DCUO.Admin.OpenPanel()
end)

-- Commande console
concommand.Add("dcuo_admin", function()
    DCUO.Admin.OpenPanel()
end)

-- Helper
function ColorAlpha(color, alpha)
    return Color(color.r, color.g, color.b, alpha)
end

DCUO.Log("Admin panel loaded", "SUCCESS")

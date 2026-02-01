--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Menus Client
    Menus divers pour le client
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

DCUO.UI = DCUO.UI or {}
DCUO.UI.ActiveMenus = DCUO.UI.ActiveMenus or {}

-- Éviter les conflits: d'anciennes versions du F1/F2 existent dans lua/autorun/client/.
-- On retire leurs hooks pour garantir un comportement déterministe.
hook.Remove("ShowHelp", "DCUO_OpenF1Menu")
hook.Remove("ShowTeam", "DCUO_OpenF2Menu")

hook.Remove("ShowHelp", "DCUO_OpenMainMenu")
hook.Add("ShowHelp", "DCUO_OpenMainMenu", function()
    if DCUO.UI and DCUO.UI.OpenMainMenu then
        DCUO.UI.OpenMainMenu()
    end
    return false
end)

hook.Remove("ShowTeam", "DCUO_OpenJobMenu")
hook.Remove("ShowTeam", "DCUO_OpenGuildMenu")
hook.Add("ShowTeam", "DCUO_OpenGuildMenu", function()
    if DCUO.Guilds and DCUO.Guilds.OpenMenu then
        DCUO.Guilds.OpenMenu()
    end
    return false
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    HELPERS                                        ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Vérifier si un menu est déjà ouvert
local function IsMenuOpen(menuName)
    return IsValid(DCUO.UI.ActiveMenus[menuName])
end

-- Fermer un menu existant
local function CloseMenu(menuName)
    if IsValid(DCUO.UI.ActiveMenus[menuName]) then
        DCUO.UI.ActiveMenus[menuName]:Remove()
        DCUO.UI.ActiveMenus[menuName] = nil
    end
end

-- Créer un bouton stylisé
function CreateStyledButton(parent, text, color)
    local btn = vgui.Create("DButton", parent)
    btn:SetText("")
    btn.Color = color or Color(52, 152, 219)
    btn.TextContent = text
    btn.Hovered = false
    
    btn.Paint = function(self, w, h)
        local col = self.Color
        local alpha = self.Hovered and 255 or 200
        
        -- Ombre
        draw.RoundedBox(8, 2, 2, w, h, Color(0, 0, 0, 100))
        
        -- Fond avec effet hover
        if self.Hovered then
            draw.RoundedBox(8, 0, 0, w, h, Color(col.r + 20, col.g + 20, col.b + 20, alpha))
        else
            draw.RoundedBox(8, 0, 0, w, h, Color(col.r, col.g, col.b, alpha))
        end
        
        -- Bordure brillante
        surface.SetDrawColor(col.r + 40, col.g + 40, col.b + 40, 150)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        -- Texte centré
        draw.SimpleText(self.TextContent, "DCUO_Font_Medium", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    btn.OnCursorEntered = function(self)
        self.Hovered = true
        surface.PlaySound("UI/buttonrollover.wav")
    end
    
    btn.OnCursorExited = function(self)
        self.Hovered = false
    end
    
    return btn
end

-- Créer un panel avec blur
local function CreateBlurredFrame(title, width, height, menuName)
    -- Fermer si déjà ouvert
    if IsMenuOpen(menuName) then
        CloseMenu(menuName)
        return nil
    end
    
    -- Responsive sizing
    local scrW, scrH = ScrW(), ScrH()
    width = math.min(width, scrW * 0.9)
    height = math.min(height, scrH * 0.9)
    
    -- Créer le blur en plein écran
    local blur = vgui.Create("DPanel")
    blur:SetSize(scrW, scrH)
    blur:SetPos(0, 0)
    blur:MakePopup()
    
    local blurStrength = 0
    blur.Paint = function(self, w, h)
        -- Animation du blur
        blurStrength = math.Approach(blurStrength, 5, FrameTime() * 15)
        
        for i = 1, blurStrength do
            Derma_DrawBackgroundBlur(self, CurTime())
        end
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
    end
    
    -- Frame principale avec design moderne
    local frame = vgui.Create("DPanel", blur)
    frame:SetSize(width, height)
    frame:Center()
    
    -- Animation d'ouverture
    local alpha = 0
    frame.Paint = function(self, w, h)
        alpha = math.Approach(alpha, 255, FrameTime() * 500)
        
        -- Ombre externe
        draw.RoundedBox(12, -4, -4, w + 8, h + 8, Color(0, 0, 0, alpha * 0.5))
        
        -- Fond principal
        draw.RoundedBox(10, 0, 0, w, h, Color(25, 25, 35, alpha * 0.95))
        
        -- Bordure gradient
        surface.SetDrawColor(52, 152, 219, alpha)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        -- Header bar
        draw.RoundedBoxEx(10, 0, 0, w, 60, Color(35, 35, 45, alpha), true, true, false, false)
        draw.RoundedBox(0, 0, 58, w, 2, Color(52, 152, 219, alpha))
        
        -- Titre
        draw.SimpleText(title, "DCUO_Font_Large", w/2, 30, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Bouton de fermeture
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetSize(40, 40)
    closeBtn:SetPos(width - 50, 10)
    closeBtn:SetText("")
    closeBtn.Hovered = false
    
    closeBtn.Paint = function(self, w, h)
        local col = self.Hovered and Color(231, 76, 60) or Color(150, 150, 150)
        draw.RoundedBox(8, 0, 0, w, h, Color(col.r, col.g, col.b, 200))
        
        -- Dessiner X
        surface.SetDrawColor(255, 255, 255)
        surface.DrawLine(12, 12, w-12, h-12)
        surface.DrawLine(w-12, 12, 12, h-12)
    end
    
    closeBtn.OnCursorEntered = function(self) self.Hovered = true end
    closeBtn.OnCursorExited = function(self) self.Hovered = false end
    closeBtn.DoClick = function()
        surface.PlaySound("UI/buttonclick.wav")
        blur:Remove()
    end
    
    blur.OnRemove = function()
        DCUO.UI.ActiveMenus[menuName] = nil
    end
    
    -- Enregistrer le menu actif
    DCUO.UI.ActiveMenus[menuName] = blur
    
    return frame, blur
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    MENU PRINCIPAL (F1)                            ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.UI.OpenMainMenu()
    local frame, blur = CreateBlurredFrame("MENU PRINCIPAL", 600, 700, "MainMenu")
    if not frame then return end
    
    local ply = LocalPlayer()
    local data = ply.DCUOData or {}
    
    -- Content container
    local content = vgui.Create("DPanel", frame)
    content:SetPos(0, 70)
    content:SetSize(frame:GetWide(), frame:GetTall() - 70)
    content.Paint = nil
    
    -- Informations du joueur avec design carte
    local infoPanel = vgui.Create("DPanel", content)
    infoPanel:Dock(TOP)
    infoPanel:SetTall(220)
    infoPanel:DockMargin(15, 15, 15, 10)
    
    infoPanel.Paint = function(self, w, h)
        -- Fond carte
        draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 45, 240))
        
        -- Bordure accent
        surface.SetDrawColor(52, 152, 219, 150)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        -- Header info
        draw.RoundedBoxEx(8, 0, 0, w, 40, Color(45, 45, 55), true, true, false, false)
        draw.SimpleText("INFORMATIONS DU JOUEUR", "DCUO_Font_Medium", w/2, 20, Color(52, 152, 219), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Stats avec icônes et spacing moderne
        local y = 55
        local spacing = 28
        
        draw.SimpleText((data.rpname or "Inconnu"), "DCUO_Font_Medium", 15, y, Color(255, 255, 255))
        y = y + spacing
        
        draw.SimpleText("Niveau " .. (data.level or 1), "DCUO_Font_Small", 15, y, Color(100, 200, 255))
        draw.SimpleText("XP: " .. (data.xp or 0) .. " / " .. (data.maxXP or 100), "DCUO_Font_Small", 15, y + 20, Color(155, 89, 182))
        y = y + spacing + 20
        
        local job = DCUO.Jobs.Get(data.job or "Recrue")
        if job then
            draw.SimpleText("Métier: " .. job.name, "DCUO_Font_Small", 15, y, job.color or Color(255, 255, 255))
            y = y + spacing
        end
        
        local faction = DCUO.Factions.Get(data.faction or "Neutral")
        if faction then
            draw.SimpleText("Faction: " .. faction.name, "DCUO_Font_Small", 15, y, faction.color or Color(255, 255, 255))
            y = y + spacing
        end
        
        -- Barre de vie
        draw.RoundedBox(4, 15, y, w - 30, 20, Color(20, 20, 25))
        local healthPct = ply:Health() / ply:GetMaxHealth()
        draw.RoundedBox(4, 15, y, (w - 30) * healthPct, 20, Color(231, 76, 60))
        draw.SimpleText(ply:Health() .. " / " .. ply:GetMaxHealth(), "DCUO_Font_Small", w/2, y + 10, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        y = y + 28
        
        -- Barre d'armure
        draw.RoundedBox(4, 15, y, w - 30, 20, Color(20, 20, 25))
        local armorPct = ply:Armor() / 100
        draw.RoundedBox(4, 15, y, (w - 30) * armorPct, 20, Color(46, 204, 113))
        draw.SimpleText("⛨ " .. ply:Armor(), "DCUO_Font_Small", w/2, y + 10, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Boutons avec grid layout
    local btnContainer = vgui.Create("DPanel", content)
    btnContainer:Dock(FILL)
    btnContainer:DockMargin(15, 5, 15, 15)
    btnContainer.Paint = nil
    
    local btnHeight = 65
    local btnMargin = 8
    
    -- Jobs
    local btnJobs = CreateStyledButton(btnContainer, "MÉTIERS", Color(52, 152, 219))
    btnJobs:Dock(TOP)
    btnJobs:SetTall(btnHeight)
    btnJobs:DockMargin(0, btnMargin, 0, btnMargin)
    btnJobs.DoClick = function()
        surface.PlaySound("UI/buttonclick.wav")
        blur:Remove()
        timer.Simple(0.1, function()
            if DCUO.UI and DCUO.UI.OpenJobMenu then
                DCUO.UI.OpenJobMenu()
            end
        end)
    end
    
    -- Powers
    local btnPowers = CreateStyledButton(btnContainer, "POUVOIRS (F3)", Color(155, 89, 182))
    btnPowers:Dock(TOP)
    btnPowers:SetTall(btnHeight)
    btnPowers:DockMargin(0, btnMargin, 0, btnMargin)
    btnPowers.DoClick = function()
        surface.PlaySound("UI/buttonclick.wav")
        blur:Remove()
        timer.Simple(0.1, function()
            if DCUO.UI and DCUO.UI.OpenPowersMenu then
                DCUO.UI.OpenPowersMenu()
            end
        end)
    end
    
    -- Missions
    local btnMissions = CreateStyledButton(btnContainer, "MISSIONS (F4)", Color(230, 126, 34))
    btnMissions:Dock(TOP)
    btnMissions:SetTall(btnHeight)
    btnMissions:DockMargin(0, btnMargin, 0, btnMargin)
    btnMissions.DoClick = function()
        surface.PlaySound("UI/buttonclick.wav")
        blur:Remove()
        timer.Simple(0.1, function()
            if DCUO.UI and DCUO.UI.OpenMissionsMenu then
                DCUO.UI.OpenMissionsMenu()
            end
        end)
    end

    -- Boutique d'auras (module existant)
    local btnAuras = CreateStyledButton(btnContainer, "BOUTIQUE D'AURAS", Color(155, 89, 182))
    btnAuras:Dock(TOP)
    btnAuras:SetTall(btnHeight)
    btnAuras:DockMargin(0, btnMargin, 0, btnMargin)
    btnAuras.DoClick = function()
        surface.PlaySound("UI/buttonclick.wav")
        blur:Remove()
        timer.Simple(0.1, function()
            if DCUO.AuraShop and DCUO.AuraShop.Open then
                DCUO.AuraShop.Open()
            end
        end)
    end

    -- Guildes (module existant)
    local btnGuilds = CreateStyledButton(btnContainer, "GUILDES (F2)", Color(46, 204, 113))
    btnGuilds:Dock(TOP)
    btnGuilds:SetTall(btnHeight)
    btnGuilds:DockMargin(0, btnMargin, 0, btnMargin)
    btnGuilds.DoClick = function()
        surface.PlaySound("UI/buttonclick.wav")
        blur:Remove()
        timer.Simple(0.1, function()
            if DCUO.Guilds and DCUO.Guilds.OpenMenu then
                DCUO.Guilds.OpenMenu()
            end
        end)
    end
    
    -- Camera toggle
    local cameraText = DCUO.Client.ThirdPerson and "VUE: 3ÈME PERSONNE" or "VUE: 1ÈRE PERSONNE"
    local btnCamera = CreateStyledButton(btnContainer, cameraText, Color(46, 204, 113))
    btnCamera:Dock(TOP)
    btnCamera:SetTall(btnHeight)
    btnCamera:DockMargin(0, btnMargin, 0, btnMargin)
    btnCamera.DoClick = function()
        surface.PlaySound("UI/buttonclick.wav")
        DCUO.Client.ThirdPerson = not DCUO.Client.ThirdPerson
        local mode = DCUO.Client.ThirdPerson and "3ème personne" or "1ère personne"
        btnCamera.TextContent = "VUE: " .. string.upper(mode)
        DCUO.UI.AddNotification("Vue changée: " .. mode, DCUO.Colors.Success, 2)
    end
    
    -- Close button
    local btnClose = CreateStyledButton(btnContainer, "FERMER", Color(231, 76, 60))
    btnClose:Dock(BOTTOM)
    btnClose:SetTall(btnHeight)
    btnClose:DockMargin(0, btnMargin, 0, 0)
    btnClose.DoClick = function()
        surface.PlaySound("UI/buttonclick.wav")
        blur:Remove()
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    MENU DE JOBS (F2)                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.UI.OpenJobMenu()
    local frame, blur = CreateBlurredFrame("MÉTIERS DISPONIBLES", 800, 650, "JobMenu")
    if not frame then return end
    
    local ply = LocalPlayer()
    local currentJob = (ply.DCUOData and ply.DCUOData.job) or "Recrue"
    local currentFaction = (ply.DCUOData and ply.DCUOData.faction) or "Neutral"
    
    -- Content container
    local content = vgui.Create("DPanel", frame)
    content:SetPos(0, 70)
    content:SetSize(frame:GetWide(), frame:GetTall() - 70)
    content.Paint = nil
    
    -- Info header
    local infoText = vgui.Create("DPanel", content)
    infoText:Dock(TOP)
    infoText:SetTall(50)
    infoText:DockMargin(15, 15, 15, 10)
    infoText.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 45, 240))
        surface.SetDrawColor(52, 152, 219, 150)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        draw.SimpleText("Métier actuel: " .. (DCUO.Jobs.Get(currentJob) and DCUO.Jobs.Get(currentJob).name or "Aucun"), "DCUO_Font_Medium", 15, h/2, Color(100, 200, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    -- Liste des jobs avec scroll
    local jobsList = vgui.Create("DScrollPanel", content)
    jobsList:Dock(FILL)
    jobsList:DockMargin(15, 5, 15, 15)
    
    -- Customiser la scrollbar
    local sbar = jobsList:GetVBar()
    sbar:SetWide(8)
    sbar.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 25, 200))
    end
    sbar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(52, 152, 219, 200))
    end
    sbar.btnUp.Paint = function() end
    sbar.btnDown.Paint = function() end
    
    for jobID, job in SortedPairsByMemberValue(DCUO.Jobs.List, "name") do
        -- Vérifier si le job est disponible pour la faction du joueur
        local factionOK = false
        if istable(job.faction) then
            factionOK = table.HasValue(job.faction, currentFaction)
        elseif isstring(job.faction) then
            factionOK = (job.faction == currentFaction)
        else
            factionOK = true -- Pas de restriction de faction
        end
        
        if factionOK then
            local jobPanel = vgui.Create("DPanel", jobsList)
            jobPanel:Dock(TOP)
            jobPanel:SetTall(110)
            jobPanel:DockMargin(0, 0, 0, 12)
            
            local isCurrentJob = (jobID == currentJob)
            local col = job.color or Color(100, 100, 100)
            
            jobPanel.Paint = function(self, w, h)
                -- Fond
                if isCurrentJob then
                    draw.RoundedBox(8, 0, 0, w, h, Color(col.r * 0.3, col.g * 0.3, col.b * 0.3, 240))
                    surface.SetDrawColor(col.r, col.g, col.b, 200)
                    surface.DrawOutlinedRect(0, 0, w, h, 3)
                else
                    draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 45, 240))
                    surface.SetDrawColor(col.r * 0.7, col.g * 0.7, col.b * 0.7, 150)
                    surface.DrawOutlinedRect(0, 0, w, h, 2)
                end
                
                -- Badge si job actuel
                if isCurrentJob then
                    draw.RoundedBox(6, 10, 10, 100, 25, col)
                    draw.SimpleText("ACTUEL", "DCUO_Font_Small", 60, 22, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                
                -- Nom du job
                local nameY = isCurrentJob and 45 or 15
                draw.SimpleText(job.name, "DCUO_Font_Medium", 15, nameY, col)
                
                -- Description
                local desc = job.description or "Aucune description"
                draw.SimpleText(desc, "DCUO_Font_Small", 15, nameY + 30, Color(200, 200, 200))
                
                -- Infos complémentaires
                local reqText = "Niveau requis: " .. (job.requirements and job.requirements.level or 0)
                draw.SimpleText(reqText, "DCUO_Font_Small", 15, nameY + 55, Color(150, 150, 150))
            end
            
            if not isCurrentJob then
                -- Vérifier les requis
                local canHave, reason = DCUO.Jobs.CanHaveJob(ply, jobID)
                
                -- Créer le bouton dans tous les cas
                local btnSelect = CreateStyledButton(jobPanel, canHave and "CHOISIR CE MÉTIER" or "VERROUILLÉ", col)
                btnSelect:Dock(RIGHT)
                btnSelect:DockMargin(15, 25, 15, 25)
                btnSelect:SetWide(200)
                
                if not canHave then
                    btnSelect:SetEnabled(false)
                    btnSelect.Color = Color(100, 100, 100)
                    btnSelect.Paint = function(self, w, h)
                        draw.RoundedBox(6, 0, 0, w, h, Color(60, 60, 70, 180))
                        surface.SetDrawColor(100, 100, 100, 150)
                        surface.DrawOutlinedRect(0, 0, w, h, 2)
                        draw.SimpleText("🔒 VERROUILLÉ", "DCUO_Font_Small", w/2, h/2, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        if reason then
                            draw.SimpleText(reason, "DermaDefault", w/2, h/2 + 20, Color(231, 76, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        end
                    end
                end
                
                btnSelect.DoClick = function()
                    if not canHave then
                        DCUO.UI.AddNotification(reason or "Vous ne pouvez pas choisir ce métier", Color(231, 76, 60))
                        surface.PlaySound("buttons/button10.wav")
                        return
                    end
                    
                    surface.PlaySound("UI/buttonclick.wav")
                    net.Start("DCUO:JobChange")
                        net.WriteString(jobID)
                    net.SendToServer()
                    frame:Remove()
                    blur:Remove()
                    DCUO.UI.AddNotification("Changement de métier en cours...", job.color)
                end
            end
        end
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    MENU DE POUVOIRS (F3)                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.UI.OpenPowersMenu()
    local frame, blur = CreateBlurredFrame("POUVOIRS", 800, 650, "PowersMenu")
    if not frame then return end
    
    local ply = LocalPlayer()
    local currentPower = (ply.DCUOData and ply.DCUOData.power) or nil
    local currentJob = (ply.DCUOData and ply.DCUOData.job) or "Recrue"
    local job = DCUO.Jobs.Get(currentJob)
    local allowedPowers = job and job.powers or {}
    
    -- Content container
    local content = vgui.Create("DPanel", frame)
    content:SetPos(0, 70)
    content:SetSize(frame:GetWide(), frame:GetTall() - 70)
    content.Paint = nil
    
    -- Info header
    local infoText = vgui.Create("DPanel", content)
    infoText:Dock(TOP)
    infoText:SetTall(50)
    infoText:DockMargin(15, 15, 15, 10)
    infoText.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 45, 240))
        surface.SetDrawColor(155, 89, 182, 150)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        local powerText = currentPower and (DCUO.Powers.List[currentPower] and DCUO.Powers.List[currentPower].name or "Aucun") or "Aucun pouvoir sélectionné"
        draw.SimpleText("Pouvoir actuel: " .. powerText, "DCUO_Font_Medium", 15, h/2, Color(155, 89, 182), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    -- Liste des pouvoirs
    local powersList = vgui.Create("DScrollPanel", content)
    powersList:Dock(FILL)
    powersList:DockMargin(15, 5, 15, 15)
    
    -- Customiser la scrollbar
    local sbar = powersList:GetVBar()
    sbar:SetWide(8)
    sbar.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 25, 200))
    end
    sbar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(155, 89, 182, 200))
    end
    sbar.btnUp.Paint = function() end
    sbar.btnDown.Paint = function() end
    
    local powersDisplayed = 0
    local menuFrame = frame  -- Stocker frame dans une variable locale
    local menuBlur = blur    -- Stocker blur pour pouvoir fermer le menu
    print("[DCUO MENU DEBUG] menuFrame créé:", IsValid(menuFrame), type(menuFrame))
    print("[DCUO MENU DEBUG] menuBlur créé:", IsValid(menuBlur), type(menuBlur))
    
    -- Vérifier que la liste existe
    if not DCUO.Powers.List or table.IsEmpty(DCUO.Powers.List) then
        local errorLabel = vgui.Create("DLabel", powersList)
        errorLabel:SetText("Aucun pouvoir disponible. Les pouvoirs sont maintenant donnés via SWEPs Workshop.")
        errorLabel:SetFont("DCUO_Font_18")
        errorLabel:SetTextColor(color_white)
        errorLabel:Dock(TOP)
        errorLabel:SetContentAlignment(5)
        errorLabel:SetTall(100)
        return
    end
    
    for powerID, power in SortedPairsByMemberValue(DCUO.Powers.List, "name") do
        -- Vérifier si le pouvoir est disponible pour ce job
        if table.HasValue(allowedPowers, powerID) then
            powersDisplayed = powersDisplayed + 1
            
            local powerPanel = vgui.Create("DPanel", powersList)
            powerPanel:Dock(TOP)
            powerPanel:SetTall(120)
            powerPanel:DockMargin(0, 0, 0, 12)
            
            local isCurrentPower = (powerID == currentPower)
            local col = power.color or Color(100, 200, 255)
        
        powerPanel.Paint = function(self, w, h)
            -- Fond
            if isCurrentPower then
                draw.RoundedBox(8, 0, 0, w, h, Color(col.r * 0.3, col.g * 0.3, col.b * 0.3, 240))
                surface.SetDrawColor(col.r, col.g, col.b, 200)
                surface.DrawOutlinedRect(0, 0, w, h, 3)
            else
                draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 45, 240))
                surface.SetDrawColor(col.r * 0.7, col.g * 0.7, col.b * 0.7, 150)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            end
            
            -- Badge si pouvoir actuel
            if isCurrentPower then
                draw.RoundedBox(6, 10, 10, 100, 25, col)
                draw.SimpleText("ACTUEL", "DCUO_Font_Small", 60, 22, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            
            -- Nom du pouvoir
            local nameY = isCurrentPower and 45 or 15
            draw.SimpleText(power.name, "DCUO_Font_Medium", 15, nameY, col)
            
            -- Description
            local desc = power.description or "Aucune description"
            draw.SimpleText(desc, "DCUO_Font_Small", 15, nameY + 30, Color(200, 200, 200))
            
            -- Cooldown
            local cooldownText = "Cooldown: " .. (power.cooldown or 10) .. "s"
            draw.SimpleText(cooldownText, "DCUO_Font_Small", 15, nameY + 55, Color(150, 150, 150))
            
            -- Dégâts si disponible
            if power.damage then
                local dmgText = "Dégâts: " .. power.damage
                draw.SimpleText(dmgText, "DCUO_Font_Small", 250, nameY + 55, Color(231, 76, 60))
            end
        end
        
        -- Boutons d'action
        if not isCurrentPower then
            local btnSelect = CreateStyledButton(powerPanel, "ÉQUIPER", col)
            btnSelect:Dock(RIGHT)
            btnSelect:SetWide(200)
            btnSelect:DockMargin(10, 35, 10, 35)
            btnSelect.DoClick = function()
                print("[DCUO MENU DEBUG] btnSelect.DoClick - menuBlur:", IsValid(menuBlur))
                surface.PlaySound("UI/buttonclick.wav")
                net.Start("DCUO:PowerEquip")
                net.WriteString(powerID)
                net.SendToServer()
                DCUO.UI.AddNotification("Équipement: " .. power.name, power.color)
                if IsValid(menuBlur) then
                    menuBlur:Remove()
                end
            end
        else
            local btnUnequip = CreateStyledButton(powerPanel, "DÉSÉQUIPER", Color(231, 76, 60))
            btnUnequip:Dock(RIGHT)
            btnUnequip:SetWide(200)
            btnUnequip:DockMargin(10, 35, 10, 35)
            btnUnequip.DoClick = function()
                print("[DCUO MENU DEBUG] btnUnequip.DoClick - menuBlur:", IsValid(menuBlur))
                surface.PlaySound("UI/buttonclick.wav")
                net.Start("DCUO:PowerUnequip")
                net.WriteString(powerID)
                net.SendToServer()
                DCUO.UI.AddNotification("Pouvoir retiré", Color(231, 76, 60))
                if IsValid(menuBlur) then
                    menuBlur:Remove()
                end
            end
        end
        end -- Fin du if table.HasValue
    end
    
    -- Message si aucun pouvoir disponible
    if powersDisplayed == 0 then
        local noPowers = vgui.Create("DPanel", powersList)
        noPowers:Dock(TOP)
        noPowers:SetTall(100)
        noPowers.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 45, 240))
            draw.SimpleText("Votre métier n'a pas de pouvoirs disponibles", "DCUO_Font_Medium", w/2, h/2 - 15, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Changez de métier pour débloquer des pouvoirs", "DCUO_Font_Small", w/2, h/2 + 15, Color(120, 120, 120), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    MENU DE MISSIONS (F4)                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.UI.OpenMissionsMenu()
    local frame, blur = CreateBlurredFrame("MISSIONS DISPONIBLES", 800, 650, "MissionsMenu")
    if not frame then return end
    
    local ply = LocalPlayer()
    local currentLevel = (ply.DCUOData and ply.DCUOData.level) or 1
    
    -- Content container
    local content = vgui.Create("DPanel", frame)
    content:SetPos(0, 70)
    content:SetSize(frame:GetWide(), frame:GetTall() - 70)
    content.Paint = nil
    
    -- Info header
    local infoText = vgui.Create("DPanel", content)
    infoText:Dock(TOP)
    infoText:SetTall(50)
    infoText:DockMargin(15, 15, 15, 10)
    infoText.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 45, 240))
        surface.SetDrawColor(230, 126, 34, 150)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        draw.SimpleText("Votre niveau: " .. currentLevel, "DCUO_Font_Medium", 15, h/2, Color(230, 126, 34), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    -- Liste des missions
    local missionsList = vgui.Create("DScrollPanel", content)
    missionsList:Dock(FILL)
    missionsList:DockMargin(15, 5, 15, 15)
    
    -- Customiser la scrollbar
    local sbar = missionsList:GetVBar()
    sbar:SetWide(8)
    sbar.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 25, 200))
    end
    sbar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(230, 126, 34, 200))
    end
    sbar.btnUp.Paint = function() end
    sbar.btnDown.Paint = function() end
    
    local missionsDisplayed = 0
    
    for missionID, mission in SortedPairsByMemberValue(DCUO.Missions.List, "levelRequired") do
        local requiredLevel = mission.levelRequired or 1
        local canAccept = currentLevel >= requiredLevel
        
        local missionPanel = vgui.Create("DPanel", missionsList)
        missionPanel:Dock(TOP)
        missionPanel:SetTall(135)
        missionPanel:DockMargin(0, 0, 0, 12)
        
        local col = canAccept and Color(230, 126, 34) or Color(100, 100, 100)
        
        missionPanel.Paint = function(self, w, h)
            -- Fond
            if canAccept then
                draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 45, 240))
                surface.SetDrawColor(230, 126, 34, 150)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            else
                draw.RoundedBox(8, 0, 0, w, h, Color(25, 25, 30, 200))
                surface.SetDrawColor(100, 100, 100, 100)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            end
            
            -- Badge niveau
            local badgeColor = canAccept and Color(46, 204, 113) or Color(150, 150, 150)
            draw.RoundedBox(6, 10, 10, 80, 25, badgeColor)
            draw.SimpleText("NIV. " .. requiredLevel, "DCUO_Font_Small", 50, 22, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            -- Nom de la mission
            local nameColor = canAccept and Color(255, 200, 0) or Color(150, 150, 150)
            draw.SimpleText(mission.name, "DCUO_Font_Medium", 15, 45, nameColor)
            
            -- Description
            local desc = mission.description or "Aucune description"
            local descColor = canAccept and Color(200, 200, 200) or Color(120, 120, 120)
            draw.SimpleText(desc, "DCUO_Font_Small", 15, 75, descColor)
            
            -- Récompenses
            local rewardY = 100
            if mission.xpReward then
                draw.RoundedBox(4, 15, rewardY, 150, 22, Color(155, 89, 182, 200))
                draw.SimpleText("XP: +" .. mission.xpReward, "DCUO_Font_Small", 90, rewardY + 11, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            
            if mission.moneyReward then
                draw.RoundedBox(4, 175, rewardY, 150, 22, Color(241, 196, 15, 200))
                draw.SimpleText("Argent: " .. mission.moneyReward .. "$", "DCUO_Font_Small", 250, rewardY + 11, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            
            -- Verrou si niveau insuffisant
            if not canAccept then
                draw.SimpleText("⚠ Niveau insuffisant", "DCUO_Font_Small", w - 15, h - 15, Color(231, 76, 60), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            end
        end
        
        if canAccept then
            local btnAccept = CreateStyledButton(missionPanel, "ACCEPTER LA MISSION", Color(46, 204, 113))
            btnAccept:Dock(BOTTOM)
            btnAccept:DockMargin(15, 10, 15, 15)
            btnAccept:SetTall(45)
            btnAccept.DoClick = function()
                surface.PlaySound("UI/buttonclick.wav")
                net.Start("DCUO:MissionUpdate")
                    net.WriteString("accept")
                    net.WriteString(missionID)
                net.SendToServer()
                frame:Remove()
                blur:Remove()
                DCUO.UI.AddNotification("Mission acceptée: " .. mission.name, Color(46, 204, 113))
            end
            
            -- Augmenter la hauteur du panel pour le bouton
            missionPanel:SetTall(180)
        else
            -- Message pour les missions verrouillées
            local lblLocked = vgui.Create("DLabel", missionPanel)
            lblLocked:Dock(BOTTOM)
            lblLocked:DockMargin(15, 10, 15, 15)
            lblLocked:SetTall(30)
            lblLocked:SetText("🔒 Niveau " .. requiredLevel .. " requis")
            lblLocked:SetFont("DCUO_Font_Small")
            lblLocked:SetTextColor(Color(231, 76, 60))
            lblLocked:SetContentAlignment(5)
        end
        
        missionsDisplayed = missionsDisplayed + 1
    end
    
    -- Message si aucune mission
    if missionsDisplayed == 0 then
        local noMissions = vgui.Create("DPanel", missionsList)
        noMissions:Dock(TOP)
        noMissions:SetTall(100)
        noMissions.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 45, 240))
            draw.SimpleText("Aucune mission disponible pour votre niveau", "DCUO_Font_Medium", w/2, h/2, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end

DCUO.Log("Menus system loaded", "SUCCESS")

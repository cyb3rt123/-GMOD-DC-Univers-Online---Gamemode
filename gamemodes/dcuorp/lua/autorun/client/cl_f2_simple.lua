-- DCUO-RP - Menu F2 Guildes Simple
-- Menu guildes basé sur le style F3/F4

if SERVER then return end

-- Initialiser les tables nécessaires
DCUO.UI = DCUO.UI or {}
DCUO.UI.ActiveMenus = DCUO.UI.ActiveMenus or {}
DCUO.Guilds = DCUO.Guilds or {}
DCUO.Guilds.PlayerData = DCUO.Guilds.PlayerData or {}

function DCUO.Guilds.OpenMenu()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    -- Vérifier si déjà ouvert
    if IsValid(DCUO.UI.ActiveMenus["GuildMenu"]) then
        DCUO.UI.ActiveMenus["GuildMenu"]:Remove()
        return
    end
    
    local scrW, scrH = ScrW(), ScrH()
    local width, height = 800, 600
    
    -- Blur background
    local blur = vgui.Create("DPanel")
    blur:SetSize(scrW, scrH)
    blur:SetPos(0, 0)
    blur:MakePopup()
    blur:SetKeyboardInputEnabled(true)
    blur:SetMouseInputEnabled(true)
    
    local blurStrength = 0
    blur.Paint = function(self, w, h)
        blurStrength = math.Approach(blurStrength, 5, FrameTime() * 15)
        for i = 1, blurStrength do
            Derma_DrawBackgroundBlur(self, CurTime())
        end
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
    end
    
    -- Frame principale
    local frame = vgui.Create("DPanel", blur)
    frame:SetSize(width, height)
    frame:Center()
    frame:SetKeyboardInputEnabled(true)
    frame:SetMouseInputEnabled(true)
    
    local alpha = 0
    frame.Paint = function(self, w, h)
        alpha = math.Approach(alpha, 255, FrameTime() * 500)
        
        draw.RoundedBox(12, -4, -4, w + 8, h + 8, Color(0, 0, 0, alpha * 0.5))
        draw.RoundedBox(10, 0, 0, w, h, Color(25, 25, 35, alpha * 0.95))
        
        surface.SetDrawColor(52, 152, 219, alpha)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        draw.RoundedBoxEx(10, 0, 0, w, 60, Color(35, 35, 45, alpha), true, true, false, false)
        draw.RoundedBox(0, 0, 58, w, 2, Color(52, 152, 219, alpha))
        
        draw.SimpleText("MENU GUILDES", "DCUO_Font_Large", w/2, 30, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Bouton fermer
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetSize(40, 40)
    closeBtn:SetPos(width - 50, 10)
    closeBtn:SetText("")
    closeBtn.Hovered = false
    
    closeBtn.Paint = function(self, w, h)
        local col = self.Hovered and Color(231, 76, 60) or Color(150, 150, 150)
        draw.RoundedBox(8, 0, 0, w, h, Color(col.r, col.g, col.b, 200))
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
        DCUO.UI.ActiveMenus["GuildMenu"] = nil
    end
    
    DCUO.UI.ActiveMenus["GuildMenu"] = blur
    
    -- Contenu
    local sid64 = ply:SteamID64()
    local playerGuild = DCUO.Guilds.PlayerData[tostring(sid64 or "")] or {}
    local hasGuild = playerGuild.guild ~= nil
    
    -- Panel principal
    local contentPanel = vgui.Create("DPanel", frame)
    contentPanel:SetPos(15, 75)
    contentPanel:SetSize(width - 30, height - 90)
    contentPanel.Paint = nil
    
    if not hasGuild then
        -- Creation de guilde
        local createPanel = vgui.Create("DPanel", contentPanel)
        createPanel:Dock(TOP)
        createPanel:SetTall(200)
        createPanel:DockMargin(0, 0, 0, 15)
        
        createPanel.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 45, 240))
            surface.SetDrawColor(52, 152, 219, 150)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
            
            draw.RoundedBoxEx(8, 0, 0, w, 40, Color(45, 45, 55), true, true, false, false)
            draw.SimpleText("CREER UNE GUILDE", "DCUO_Font_Medium", w/2, 20, Color(46, 204, 113), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        -- Nom
        local nameLabel = vgui.Create("DLabel", createPanel)
        nameLabel:SetPos(20, 60)
        nameLabel:SetSize(200, 25)
        nameLabel:SetText("Nom de la guilde:")
        nameLabel:SetFont("DCUO_Font_Small")
        nameLabel:SetTextColor(Color(200, 200, 200))
        
        local nameEntry = vgui.Create("DTextEntry", createPanel)
        nameEntry:SetPos(20, 90)
        nameEntry:SetSize(400, 35)
        nameEntry:SetPlaceholderText("Entrez le nom...")
        nameEntry:SetFont("DCUO_Font_Small")
        nameEntry:SetKeyboardInputEnabled(true)
        timer.Simple(0.1, function()
            if IsValid(nameEntry) and IsValid(blur) then
                blur:SetKeyboardInputEnabled(true)
                frame:SetKeyboardInputEnabled(true)
                nameEntry:RequestFocus()
            end
        end)
        
        -- Bouton créer
        local createBtn = vgui.Create("DButton", createPanel)
        createBtn:SetPos(450, 60)
        createBtn:SetSize(300, 65)
        createBtn:SetText("")
        createBtn.Hovered = false
        
        createBtn.Paint = function(self, w, h)
            local col = Color(46, 204, 113)
            if self.Hovered then
                draw.RoundedBox(8, 0, 0, w, h, Color(col.r + 20, col.g + 20, col.b + 20, 255))
            else
                draw.RoundedBox(8, 0, 0, w, h, Color(col.r, col.g, col.b, 200))
            end
            
            draw.SimpleText("CREER LA GUILDE", "DCUO_Font_Medium", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        createBtn.OnCursorEntered = function(self)
            self.Hovered = true
            surface.PlaySound("UI/buttonrollover.wav")
        end
        
        createBtn.OnCursorExited = function(self)
            self.Hovered = false
        end
        
        createBtn.DoClick = function()
            local name = nameEntry:GetValue()
            
            if name == "" then
                chat.AddText(Color(231, 76, 60), "[Guildes] ", Color(255, 255, 255), "Veuillez entrer un nom de guilde.")
                surface.PlaySound("buttons/button10.wav")
                return
            end
            
            surface.PlaySound("UI/buttonclick.wav")
            
            net.Start("DCUO:Guild:Create")
            net.WriteString(name)
            net.WriteString("")
            net.WriteString("")
            net.SendToServer()
            
            blur:Remove()
        end
        
        -- Liste guildes
        local listPanel = vgui.Create("DPanel", contentPanel)
        listPanel:Dock(FILL)
        listPanel:DockMargin(0, 0, 0, 0)
        
        listPanel.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 45, 240))
            surface.SetDrawColor(52, 152, 219, 150)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
            
            draw.RoundedBoxEx(8, 0, 0, w, 40, Color(45, 45, 55), true, true, false, false)
            draw.SimpleText("GUILDES DISPONIBLES", "DCUO_Font_Medium", w/2, 20, Color(230, 126, 34), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    else
        -- Afficher guilde
        local guild = playerGuild.guild or {}
        
        local infoPanel = vgui.Create("DPanel", contentPanel)
        infoPanel:Dock(TOP)
        infoPanel:SetTall(150)
        infoPanel:DockMargin(0, 0, 0, 15)
        
        infoPanel.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 45, 240))
            surface.SetDrawColor(52, 152, 219, 150)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
            
            draw.RoundedBoxEx(8, 0, 0, w, 40, Color(45, 45, 55), true, true, false, false)
            draw.SimpleText(guild.name or "Ma Guilde", "DCUO_Font_Medium", w/2, 20, Color(46, 204, 113), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            draw.SimpleText("Chef: " .. (guild.leader or "Inconnu"), "DCUO_Font_Small", 15, 60, Color(200, 200, 200), TEXT_ALIGN_LEFT)
            local memberCount = istable(guild.members) and table.Count(guild.members) or 0
            draw.SimpleText("Membres: " .. memberCount, "DCUO_Font_Small", 15, 85, Color(52, 152, 219), TEXT_ALIGN_LEFT)
        end
        
        -- Bouton quitter
        local leaveBtn = vgui.Create("DButton", contentPanel)
        leaveBtn:Dock(BOTTOM)
        leaveBtn:SetTall(50)
        leaveBtn:DockMargin(0, 15, 0, 0)
        leaveBtn:SetText("")
        leaveBtn.Hovered = false
        
        leaveBtn.Paint = function(self, w, h)
            local col = Color(231, 76, 60)
            draw.RoundedBox(8, 0, 0, w, h, self.Hovered and Color(col.r + 20, col.g + 20, col.b + 20) or col)
            draw.SimpleText("QUITTER LA GUILDE", "DCUO_Font_Medium", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        leaveBtn.OnCursorEntered = function(self)
            self.Hovered = true
            surface.PlaySound("UI/buttonrollover.wav")
        end
        
        leaveBtn.OnCursorExited = function(self)
            self.Hovered = false
        end
        
        leaveBtn.DoClick = function()
            surface.PlaySound("UI/buttonclick.wav")
            blur:Remove()
        end
    end
end

-- F2 est géré par le menu moderne (ui/cl_menus.lua). On expose une commande explicite.
concommand.Add("dcuo_guilds", function()
    if DCUO.Guilds and DCUO.Guilds.OpenMenu then
        DCUO.Guilds.OpenMenu()
    end
end)

-- Réception des données de guilde du serveur
net.Receive("DCUO:Guild:Sync", function()
    local data = net.ReadTable()
    DCUO.Guilds.List = data or {}
    
    -- Mettre à jour les données du joueur local
    local ply = LocalPlayer()
    if IsValid(ply) then
        local sid = ply:SteamID()
        for guildID, guild in pairs(DCUO.Guilds.List) do
            if guild.members and guild.members[sid] then
                DCUO.Guilds.PlayerData[tostring(ply:SteamID64() or "")] = {
                    guild = guild,
                    guildID = guildID
                }
                break
            end
        end
    end
end)

print("[DCUO] Menu F2 Guildes simple charge - DCUO.Guilds.OpenMenu existe:", DCUO.Guilds.OpenMenu ~= nil)

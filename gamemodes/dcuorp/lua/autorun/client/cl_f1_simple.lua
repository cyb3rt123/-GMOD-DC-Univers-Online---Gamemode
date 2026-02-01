-- DCUO-RP - Menu F1 Simple
-- Menu principal basé sur le style F3/F4

if SERVER then return end

-- Initialiser les tables nécessaires
DCUO.UI = DCUO.UI or {}
DCUO.UI.ActiveMenus = DCUO.UI.ActiveMenus or {}
DCUO.F1Menu = DCUO.F1Menu or {}

function DCUO.F1Menu.Open()
    -- Vérifier si déjà ouvert
    if IsValid(DCUO.UI.ActiveMenus["F1Menu"]) then
        DCUO.UI.ActiveMenus["F1Menu"]:Remove()
        return
    end
    
    local scrW, scrH = ScrW(), ScrH()
    local width, height = 900, 650
    
    -- Blur background
    local blur = vgui.Create("DPanel")
    blur:SetSize(scrW, scrH)
    blur:SetPos(0, 0)
    blur:MakePopup()
    
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
    
    local alpha = 0
    frame.Paint = function(self, w, h)
        alpha = math.Approach(alpha, 255, FrameTime() * 500)
        
        draw.RoundedBox(12, -4, -4, w + 8, h + 8, Color(0, 0, 0, alpha * 0.5))
        draw.RoundedBox(10, 0, 0, w, h, Color(25, 25, 35, alpha * 0.95))
        
        surface.SetDrawColor(52, 152, 219, alpha)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        draw.RoundedBoxEx(10, 0, 0, w, 60, Color(35, 35, 45, alpha), true, true, false, false)
        draw.RoundedBox(0, 0, 58, w, 2, Color(52, 152, 219, alpha))
        
        draw.SimpleText("MENU PRINCIPAL", "DCUO_Font_Large", w/2, 30, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
        DCUO.UI.ActiveMenus["F1Menu"] = nil
    end
    
    DCUO.UI.ActiveMenus["F1Menu"] = blur
    
    -- Contenu
    local ply = LocalPlayer()
    local data = ply.DCUOData or {}
    
    -- Panel infos
    local infoPanel = vgui.Create("DPanel", frame)
    infoPanel:SetPos(15, 75)
    infoPanel:SetSize(width - 30, 200)
    
    infoPanel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 45, 240))
        surface.SetDrawColor(52, 152, 219, 150)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        draw.RoundedBoxEx(8, 0, 0, w, 40, Color(45, 45, 55), true, true, false, false)
        draw.SimpleText("INFORMATIONS DU JOUEUR", "DCUO_Font_Medium", w/2, 20, Color(52, 152, 219), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        local y = 55
        local stats = {
            {"Nom RP:", data.rpname or "Aucun"},
            {"Niveau:", tostring(data.level or 1)},
            {"XP:", (data.xp or 0) .. " / " .. (data.maxXP or 100)},
            {"Faction:", data.faction or "Aucune"},
            {"Metier:", data.job or "Citoyen"},
        }
        
        for _, stat in ipairs(stats) do
            draw.SimpleText(stat[1], "DCUO_Font_Small", 15, y, Color(200, 200, 200), TEXT_ALIGN_LEFT)
            draw.SimpleText(stat[2], "DCUO_Font_Small", w - 15, y, Color(52, 152, 219), TEXT_ALIGN_RIGHT)
            y = y + 25
        end
    end
    
    -- Boutons
    local buttonY = 290
    local buttons = {
        {text = "Changer de metier", func = function()
            blur:Remove()
            if DCUO.UI.OpenJobMenu then DCUO.UI.OpenJobMenu() end
        end},
        {text = "Boutique d'Auras", func = function()
            blur:Remove()
            if DCUO.AuraShop and DCUO.AuraShop.OpenMenu then DCUO.AuraShop.OpenMenu() end
        end},
        {text = "Missions", func = function()
            blur:Remove()
            if DCUO.UI.OpenMissionsMenu then DCUO.UI.OpenMissionsMenu() end
        end},
        {text = "Guildes", func = function()
            blur:Remove()
            if DCUO.Guilds and DCUO.Guilds.OpenMenu then DCUO.Guilds.OpenMenu() end
        end},
    }
    
    for i, btn in ipairs(buttons) do
        local button = vgui.Create("DButton", frame)
        button:SetPos(15, buttonY)
        button:SetSize(width - 30, 60)
        button:SetText("")
        button.Hovered = false
        
        button.Paint = function(self, w, h)
            local col = Color(52, 152, 219)
            if self.Hovered then
                draw.RoundedBox(8, 0, 0, w, h, Color(col.r + 20, col.g + 20, col.b + 20, 255))
            else
                draw.RoundedBox(8, 0, 0, w, h, Color(col.r, col.g, col.b, 200))
            end
            
            surface.SetDrawColor(col.r + 40, col.g + 40, col.b + 40, 150)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
            
            draw.SimpleText(btn.text, "DCUO_Font_Medium", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        button.OnCursorEntered = function(self)
            self.Hovered = true
            surface.PlaySound("UI/buttonrollover.wav")
        end
        
        button.OnCursorExited = function(self)
            self.Hovered = false
        end
        
        button.DoClick = function()
            surface.PlaySound("UI/buttonclick.wav")
            btn.func()
        end
        
        buttonY = buttonY + 70
    end
end

-- Hook pour la touche F1
hook.Add("ShowHelp", "DCUO_OpenF1Menu", function()
    DCUO.F1Menu.Open()
    return false -- Empêche le menu par défaut
end)

print("[DCUO] Menu F1 simple charge - DCUO.F1Menu.Open existe:", DCUO.F1Menu.Open ~= nil)

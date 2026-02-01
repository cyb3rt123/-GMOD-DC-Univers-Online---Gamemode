--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - NPC Boutique (Client)
    Affichage du texte rotatif et menu
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    TEXTE ROTATIF AU-DESSUS DU NPC                 ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("PostDrawOpaqueRenderables", "DCUO:ShopNPC:DrawText", function()
    for _, npc in ipairs(ents.GetAll()) do
        if IsValid(npc) and npc.IsShopNPC then
            local pos = npc:GetPos() + Vector(0, 0, 85)
            local ang = LocalPlayer():EyeAngles()
            ang:RotateAroundAxis(ang:Forward(), 90)
            ang:RotateAroundAxis(ang:Right(), 90)
            ang.y = ang.y + (RealTime() * 50) -- Rotation
            
            cam.Start3D2D(pos, ang, 0.15)
                -- Ombre
                draw.SimpleTextOutlined("BOUTIQUE", "DermaLarge", 0, 0, Color(255, 215, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, Color(0, 0, 0, 200))
                
                -- Texte principal
                draw.SimpleText("BOUTIQUE", "DermaLarge", 0, 0, Color(255, 255, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                -- Sous-texte
                draw.SimpleText("Appuyez sur E", "DermaDefault", 0, 35, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            cam.End3D2D()
        end
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    MENU BOUTIQUE                                  ║
-- ╚═══════════════════════════════════════════════════════════════════╝

net.Receive("DCUO:Shop:Open", function()
    DCUO.Shop.OpenMenu()
end)

DCUO.Shop = DCUO.Shop or {}

function DCUO.Shop.OpenMenu()
    if IsValid(DCUO.Shop.Frame) then
        DCUO.Shop.Frame:Remove()
        return
    end
    
    local scrW, scrH = ScrW(), ScrH()
    local w, h = scrW * 0.8, scrH * 0.8
    
    -- Frame principale
    local frame = vgui.Create("DFrame")
    frame:SetSize(w, h)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    DCUO.Shop.Frame = frame
    
    frame.Paint = function(self, fw, fh)
        -- Blur
        Derma_DrawBackgroundBlur(self, 0)
        
        -- Fond
        draw.RoundedBox(12, 0, 0, fw, fh, Color(15, 15, 20, 250))
        
        -- Header gradient
        draw.RoundedBoxEx(12, 0, 0, fw, 80, Color(30, 30, 40, 220), true, true, false, false)
        
        -- Titre
        draw.SimpleText("🛒 BOUTIQUE", "DCUO_Font_48", fw/2, 40, Color(255, 215, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Ligne accent
        surface.SetDrawColor(255, 215, 0, 200)
        surface.DrawRect(20, 75, fw - 40, 2)
        
        -- Bordure
        surface.SetDrawColor(255, 215, 0, 100)
        surface.DrawOutlinedRect(0, 0, fw, fh, 3)
    end
    
    -- Bouton Fermer
    local btnClose = vgui.Create("DButton", frame)
    btnClose:SetSize(50, 50)
    btnClose:SetPos(w - 70, 15)
    btnClose:SetText("")
    
    btnClose.Paint = function(self, bw, bh)
        local col = self:IsHovered() and Color(220, 50, 50) or Color(180, 40, 40)
        draw.RoundedBox(25, 0, 0, bw, bh, col)
        draw.SimpleText("✖", "DCUO_Font_24", bw/2, bh/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    btnClose.DoClick = function()
        frame:Remove()
    end
    
    -- Catégories (gauche)
    local categoryPanel = vgui.Create("DPanel", frame)
    categoryPanel:SetSize(220, h - 120)
    categoryPanel:SetPos(20, 95)
    categoryPanel.Paint = function(self, pw, ph)
        draw.RoundedBox(8, 0, 0, pw, ph, Color(25, 25, 35, 200))
        surface.SetDrawColor(255, 215, 0, 80)
        surface.DrawOutlinedRect(0, 0, pw, ph, 1)
    end
    
    -- Panel de contenu
    local contentPanel = vgui.Create("DPanel", frame)
    contentPanel:SetSize(w - 260, h - 120)
    contentPanel:SetPos(250, 95)
    contentPanel.Paint = function(self, pw, ph)
        draw.RoundedBox(8, 0, 0, pw, ph, Color(25, 25, 35, 200))
        surface.SetDrawColor(255, 215, 0, 80)
        surface.DrawOutlinedRect(0, 0, pw, ph, 1)
    end
    
    -- Catégories
    local categories = {
        {icon = "✨", name = "Auras", items = DCUO.Auras and DCUO.Auras.List or {}},
        {icon = "[*]", name = "Apparence", items = {}},
        {icon = "[W]", name = "Armes", items = {}},
        {icon = "🎁", name = "Spécial", items = {}},
    }
    
    local selectedCategory = 1
    
    local function ShowCategory(categoryIndex)
        selectedCategory = categoryIndex
        contentPanel:Clear()
        
        local category = categories[categoryIndex]
        
        -- Titre catégorie
        local title = vgui.Create("DLabel", contentPanel)
        title:SetPos(20, 20)
        title:SetSize(contentPanel:GetWide() - 40, 40)
        title:SetFont("DCUO_Font_32")
        title:SetText(category.icon .. " " .. category.name)
        title:SetTextColor(Color(255, 215, 0))
        
        -- Scroll des items
        local scroll = vgui.Create("DScrollPanel", contentPanel)
        scroll:SetPos(20, 70)
        scroll:SetSize(contentPanel:GetWide() - 40, contentPanel:GetTall() - 90)
        
        if category.name == "Auras" and DCUO.Auras then
            local itemW = 250
            local itemH = 140
            local padding = 15
            local cols = math.floor((scroll:GetWide() - padding) / (itemW + padding))
            
            local x, y = 0, 0
            
            for _, aura in ipairs(DCUO.Auras.List) do
                local col = x % cols
                local row = math.floor(x / cols)
                
                local itemPanel = vgui.Create("DPanel", scroll)
                itemPanel:SetSize(itemW, itemH)
                itemPanel:SetPos(col * (itemW + padding), row * (itemH + padding))
                
                local owned = false
                if LocalPlayer().DCUOData and LocalPlayer().DCUOData.auras then
                    owned = table.HasValue(LocalPlayer().DCUOData.auras, aura.id)
                end
                
                itemPanel.Paint = function(self, pw, ph)
                    local bgCol = owned and Color(50, 80, 50, 200) or Color(40, 40, 55, 200)
                    draw.RoundedBox(8, 0, 0, pw, ph, bgCol)
                    
                    -- Nom
                    draw.SimpleText(aura.name, "DCUO_Font_20", pw/2, 20, color_white, TEXT_ALIGN_CENTER)
                    
                    -- Prix
                    if not owned then
                        draw.SimpleText("💰 " .. aura.price .. " DCUO Coins", "DCUO_Font_16", pw/2, 50, Color(255, 215, 0), TEXT_ALIGN_CENTER)
                    else
                        draw.SimpleText("[V] POSSÉDÉ", "DCUO_Font_16", pw/2, 50, Color(100, 255, 100), TEXT_ALIGN_CENTER)
                    end
                    
                    -- Bordure
                    surface.SetDrawColor(aura.color.r, aura.color.g, aura.color.b, 150)
                    surface.DrawOutlinedRect(0, 0, pw, ph, 2)
                end
                
                -- Bouton Acheter
                if not owned then
                    local btnBuy = vgui.Create("DButton", itemPanel)
                    btnBuy:SetSize(200, 35)
                    btnBuy:SetPos((itemW - 200) / 2, itemH - 45)
                    btnBuy:SetText("")
                    
                    btnBuy.Paint = function(self, bw, bh)
                        local col = self:IsHovered() and Color(70, 140, 70) or Color(50, 120, 50)
                        draw.RoundedBox(6, 0, 0, bw, bh, col)
                        draw.SimpleText("ACHETER", "DCUO_Font_18", bw/2, bh/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                    
                    btnBuy.DoClick = function()
                        net.Start("DCUO:Shop:Purchase")
                            net.WriteString(aura.id)
                        net.SendToServer()
                        
                        timer.Simple(0.3, function()
                            if IsValid(frame) then
                                ShowCategory(selectedCategory)
                            end
                        end)
                    end
                end
                
                x = x + 1
            end
        else
            -- Message vide
            local lblEmpty = vgui.Create("DLabel", scroll)
            lblEmpty:SetPos(10, 50)
            lblEmpty:SetSize(scroll:GetWide() - 20, 30)
            lblEmpty:SetFont("DCUO_Font_20")
            lblEmpty:SetText("Aucun item disponible dans cette catégorie")
            lblEmpty:SetTextColor(Color(150, 150, 150))
            lblEmpty:SetContentAlignment(5)
        end
    end
    
    -- Boutons catégories
    for i, cat in ipairs(categories) do
        local btn = vgui.Create("DButton", categoryPanel)
        btn:SetSize(200, 50)
        btn:SetPos(10, 10 + (i-1) * 60)
        btn:SetText("")
        
        btn.Paint = function(self, bw, bh)
            local col = Color(35, 35, 50)
            if selectedCategory == i then
                col = Color(60, 60, 90)
            elseif self:IsHovered() then
                col = Color(45, 45, 65)
            end
            
            draw.RoundedBox(6, 0, 0, bw, bh, col)
            
            -- Icône
            draw.SimpleText(cat.icon, "DCUO_Font_24", 20, bh/2, Color(255, 215, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            -- Nom
            draw.SimpleText(cat.name, "DCUO_Font_18", 55, bh/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            -- Indicateur sélection
            if selectedCategory == i then
                surface.SetDrawColor(255, 215, 0)
                surface.DrawRect(0, 0, 3, bh)
            end
        end
        
        btn.DoClick = function()
            ShowCategory(i)
        end
    end
    
    -- Afficher la première catégorie
    ShowCategory(1)
end

DCUO.Log("Shop NPC Menu (Client) Loaded", "SUCCESS")

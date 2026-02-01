--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Boutique d'Auras (Client)
    Interface d'achat d'auras avec XP
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

DCUO.AuraShop = DCUO.AuraShop or {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONTS                                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

surface.CreateFont("DCUO_AuraShop_Title", {
    font = "Roboto",
    size = 32,
    weight = 700,
    antialias = true,
})

surface.CreateFont("DCUO_AuraShop_Subtitle", {
    font = "Roboto",
    size = 20,
    weight = 600,
    antialias = true,
})

surface.CreateFont("DCUO_AuraShop_Text", {
    font = "Roboto",
    size = 16,
    weight = 500,
    antialias = true,
})

surface.CreateFont("DCUO_AuraShop_Small", {
    font = "Roboto",
    size = 14,
    weight = 400,
    antialias = true,
})

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    OUVRIR LA BOUTIQUE                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.AuraShop.Open()
    if IsValid(DCUO.AuraShop.Frame) then
        DCUO.AuraShop.Frame:Remove()
    end
    
    local scrW, scrH = ScrW(), ScrH()
    local w, h = math.min(1200, scrW * 0.8), math.min(700, scrH * 0.8)
    
    -- Frame principale
    local frame = vgui.Create("DFrame")
    frame:SetSize(w, h)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    DCUO.AuraShop.Frame = frame
    
    frame.Paint = function(self, fw, fh)
        -- Background
        draw.RoundedBox(8, 0, 0, fw, fh, Color(20, 20, 30, 250))
        
        -- Header
        draw.RoundedBoxEx(8, 0, 0, fw, 60, Color(30, 30, 40, 255), true, true, false, false)
        
        -- Titre
        draw.SimpleText("✨ BOUTIQUE D'AURAS", "DCUO_AuraShop_Title", fw/2, 15, Color(255, 215, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        
        -- XP disponible
        local xp = LocalPlayer().DCUOData and LocalPlayer().DCUOData.xp or 0
        draw.SimpleText("XP Disponible: " .. xp, "DCUO_AuraShop_Text", fw - 20, 35, Color(100, 200, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    end
    
    -- Bouton fermer
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPos(w - 40, 15)
    closeBtn:SetText("✖")
    closeBtn:SetFont("DCUO_AuraShop_Subtitle")
    closeBtn:SetTextColor(Color(255, 255, 255))
    closeBtn.Paint = function(self, bw, bh)
        local col = self:IsHovered() and Color(200, 50, 50) or Color(150, 50, 50)
        draw.RoundedBox(4, 0, 0, bw, bh, col)
    end
    closeBtn.DoClick = function()
        frame:Remove()
    end
    
    -- Scroll panel
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(10, 70)
    scroll:SetSize(w - 20, h - 80)
    
    -- Barre de scroll personnalisée
    local sbar = scroll:GetVBar()
    sbar:SetWide(8)
    sbar.Paint = function(self, sw, sh)
        draw.RoundedBox(4, 0, 0, sw, sh, Color(40, 40, 50))
    end
    sbar.btnGrip.Paint = function(self, gw, gh)
        draw.RoundedBox(4, 0, 0, gw, gh, Color(100, 150, 255))
    end
    
    -- Catégories d'auras
    local categories = {
        {name = "⚡ Électriques", auras = {"electric_blue", "electric_yellow", "electric_red", "speed_force"}},
        {name = "🔥 Feu", auras = {"fire_orange", "fire_blue", "fire_green"}},
        {name = "✨ Énergie", auras = {"energy_white", "energy_purple", "energy_cyan", "lantern_green"}},
        {name = "💫 Particules", auras = {"sparkles_gold", "sparkles_rainbow"}},
        {name = "💀 Sombres", auras = {"dark_smoke", "dark_purple"}},
        {name = "🌟 Légendaires", auras = {"legendary_hero", "legendary_villain", "legendary_cosmic"}},
        {name = "🎨 Spéciales", auras = {"kryptonite_green"}},
    }
    
    local yPos = 10
    
    for _, category in ipairs(categories) do
        -- Header catégorie
        local catHeader = vgui.Create("DPanel", scroll)
        catHeader:SetPos(0, yPos)
        catHeader:SetSize(scroll:GetWide() - 10, 40)
        catHeader.Paint = function(self, cw, ch)
            draw.RoundedBox(4, 0, 0, cw, ch, Color(40, 40, 50))
            draw.SimpleText(category.name, "DCUO_AuraShop_Subtitle", 15, ch/2, Color(255, 215, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        yPos = yPos + 50
        
        -- Auras de cette catégorie
        local xPos = 10
        for _, auraId in ipairs(category.auras) do
            local aura = DCUO.Auras.Get(auraId)
            if aura then
                local auraPanel = DCUO.AuraShop.CreateAuraCard(aura, auraId, scroll)
                auraPanel:SetPos(xPos, yPos)
                
                xPos = xPos + 280
                if xPos + 280 > scroll:GetWide() then
                    xPos = 10
                    yPos = yPos + 160
                end
            end
        end
        
        yPos = yPos + 170
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CRÉER UNE CARTE D'AURA                         ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.AuraShop.CreateAuraCard(aura, auraId, parent)
    local card = vgui.Create("DButton", parent)
    card:SetSize(270, 150)
    card:SetText("")
    
    -- Vérifier si possédée
    local owned = LocalPlayer().DCUOData and LocalPlayer().DCUOData.auras and table.HasValue(LocalPlayer().DCUOData.auras, auraId)
    local equipped = LocalPlayer().DCUOData and LocalPlayer().DCUOData.equippedAura == auraId
    local canBuy = DCUO.Auras.CanBuy(LocalPlayer(), auraId)
    
    card.Paint = function(self, cw, ch)
        local col = owned and Color(30, 60, 30) or Color(40, 40, 50)
        if self:IsHovered() then
            col = Color(col.r + 20, col.g + 20, col.b + 20)
        end
        
        -- Background
        draw.RoundedBox(8, 0, 0, cw, ch, col)
        
        -- Bordure colorée
        draw.RoundedBox(8, 0, 0, cw, 4, aura.color)
        
        -- Nom
        draw.SimpleText(aura.name, "DCUO_AuraShop_Text", cw/2, 15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        
        -- Description
        draw.DrawText(aura.description, "DCUO_AuraShop_Small", 10, 40, Color(200, 200, 200), TEXT_ALIGN_LEFT)
        
        -- Coût
        local costColor = owned and Color(100, 255, 100) or (canBuy and Color(100, 200, 255) or Color(255, 100, 100))
        draw.SimpleText("💎 " .. aura.cost .. " XP", "DCUO_AuraShop_Text", cw/2, 90, costColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        
        -- Niveau requis
        draw.SimpleText("Niveau " .. aura.level, "DCUO_AuraShop_Small", cw/2, 110, Color(255, 215, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        
        -- Status
        if equipped then
            draw.RoundedBox(4, 5, ch - 30, cw - 10, 25, Color(200, 100, 0))
            draw.SimpleText("[V] ÉQUIPÉE - CLIQUER POUR RETIRER", "DCUO_AuraShop_Small", cw/2, ch - 17, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        elseif owned then
            draw.RoundedBox(4, 5, ch - 30, cw - 10, 25, Color(50, 100, 200))
            draw.SimpleText("POSSÉDÉE - CLIQUER POUR ÉQUIPER", "DCUO_AuraShop_Small", cw/2, ch - 17, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            local btnCol = canBuy and Color(50, 150, 50) or Color(100, 100, 100)
            draw.RoundedBox(4, 5, ch - 30, cw - 10, 25, btnCol)
            draw.SimpleText(canBuy and "ACHETER (PERMANENT)" or "BLOQUÉE", "DCUO_AuraShop_Small", cw/2, ch - 17, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    card.DoClick = function()
        if owned and equipped then
            -- Déséquiper l'aura
            net.Start("DCUO:RequestEquipAura")
                net.WriteString("none")
            net.SendToServer()
            
            timer.Simple(0.2, function()
                DCUO.AuraShop.Open()
            end)
        elseif owned and not equipped then
            -- Équiper l'aura (gratuit, déjà possédée)
            net.Start("DCUO:RequestEquipAura")
                net.WriteString(auraId)
            net.SendToServer()
            
            timer.Simple(0.2, function()
                DCUO.AuraShop.Open()
            end)
        elseif not owned and canBuy then
            -- Acheter l'aura (achat unique permanent)
            Derma_Query(
                "Acheter '" .. aura.name .. "' pour " .. aura.cost .. " XP ?\n\nCette aura sera débloquée définitivement.",
                "Confirmation d'achat",
                "Oui",
                function()
                    net.Start("DCUO:BuyAura")
                        net.WriteString(auraId)
                    net.SendToServer()
                    
                    timer.Simple(0.2, function()
                        DCUO.AuraShop.Open()
                    end)
                end,
                "Non"
            )
        end
    end
    
    return card
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    COMMANDE CHAT                                  ║
-- ╚═══════════════════════════════════════════════════════════════════╝

concommand.Add("dcuo_auras", function()
    DCUO.AuraShop.Open()
end)

-- Message d'aide
hook.Add("PlayerSay", "DCUO:AuraShopHelp", function(ply, text)
    if string.lower(text) == "!auras" or string.lower(text) == "/auras" then
        DCUO.AuraShop.Open()
        return ""
    end
end)

DCUO.Log("Aura shop UI loaded", "SUCCESS")

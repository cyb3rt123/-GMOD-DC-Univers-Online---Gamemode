--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Créateur de Personnage
    Menu de création de personnage immersif
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

DCUO.CharacterCreator = DCUO.CharacterCreator or {}

local creatorFrame = nil
local selectedFaction = "Neutral"
local characterData = {
    firstname = "",
    lastname = "",
    age = 25,
    origin = "",
    faction = "Neutral",
    gender = "male",
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    OUVRIR LE CRÉATEUR                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.CharacterCreator.Open()
    if IsValid(creatorFrame) then
        creatorFrame:Remove()
    end
    
    local scrW, scrH = ScrW(), ScrH()
    
    -- Frame principale
    creatorFrame = vgui.Create("DFrame")
    creatorFrame:SetSize(900, 700)
    creatorFrame:SetPos(scrW / 2 - 450, scrH / 2 - 350)
    creatorFrame:SetTitle("")
    creatorFrame:SetDraggable(false)
    creatorFrame:ShowCloseButton(false)
    creatorFrame:MakePopup()
    
    creatorFrame.Paint = function(self, w, h)
        -- Background avec blur
        Derma_DrawBackgroundBlur(self, CurTime())
        
        -- Background sombre
        draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(DCUO.Colors.Dark, 240))
        
        -- Bordure néon
        surface.SetDrawColor(DCUO.Colors.Electric.r, DCUO.Colors.Electric.g, DCUO.Colors.Electric.b, 150)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        -- Titre
        draw.SimpleText("CRÉATION DE PERSONNAGE", "DCUO_HUD_Large", w / 2, 30, DCUO.Colors.Electric, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Programme Genesis - Dossier de Recrue", "DCUO_HUD_Small", w / 2, 70, DCUO.Colors.Light, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Scroll Panel
    local scroll = vgui.Create("DScrollPanel", creatorFrame)
    scroll:Dock(FILL)
    scroll:DockMargin(20, 100, 20, 80)
    
    -- ═══ PRÉNOM ═══
    local fnameLabel = vgui.Create("DLabel", scroll)
    fnameLabel:Dock(TOP)
    fnameLabel:DockMargin(0, 10, 0, 5)
    fnameLabel:SetText("PRÉNOM")
    fnameLabel:SetFont("DCUO_HUD_Small")
    fnameLabel:SetTextColor(DCUO.Colors.Electric)
    
    local fnameEntry = vgui.Create("DTextEntry", scroll)
    fnameEntry:Dock(TOP)
    fnameEntry:DockMargin(0, 0, 0, 10)
    fnameEntry:SetTall(40)
    fnameEntry:SetFont("DCUO_HUD_Small")
    fnameEntry:SetPlaceholderText("Entrez votre prénom...")
    fnameEntry.OnChange = function(self)
        characterData.firstname = self:GetValue()
    end
    fnameEntry.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, ColorAlpha(DCUO.Colors.Dark, 150))
        surface.SetDrawColor(DCUO.Colors.Electric.r, DCUO.Colors.Electric.g, DCUO.Colors.Electric.b, 100)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        self:DrawTextEntryText(DCUO.Colors.Light, DCUO.Colors.Electric, DCUO.Colors.Light)
    end
    
    -- ═══ NOM ═══
    local lnameLabel = vgui.Create("DLabel", scroll)
    lnameLabel:Dock(TOP)
    lnameLabel:DockMargin(0, 10, 0, 5)
    lnameLabel:SetText("NOM")
    lnameLabel:SetFont("DCUO_HUD_Small")
    lnameLabel:SetTextColor(DCUO.Colors.Electric)
    
    local lnameEntry = vgui.Create("DTextEntry", scroll)
    lnameEntry:Dock(TOP)
    lnameEntry:DockMargin(0, 0, 0, 10)
    lnameEntry:SetTall(40)
    lnameEntry:SetFont("DCUO_HUD_Small")
    lnameEntry:SetPlaceholderText("Entrez votre nom...")
    lnameEntry.OnChange = function(self)
        characterData.lastname = self:GetValue()
    end
    lnameEntry.Paint = fnameEntry.Paint
    
    -- ═══ ÂGE ═══
    local ageLabel = vgui.Create("DLabel", scroll)
    ageLabel:Dock(TOP)
    ageLabel:DockMargin(0, 10, 0, 5)
    ageLabel:SetText("ÂGE: " .. characterData.age)
    ageLabel:SetFont("DCUO_HUD_Small")
    ageLabel:SetTextColor(DCUO.Colors.Electric)
    
    local ageSlider = vgui.Create("DNumSlider", scroll)
    ageSlider:Dock(TOP)
    ageSlider:DockMargin(0, 0, 0, 10)
    ageSlider:SetMin(18)
    ageSlider:SetMax(60)
    ageSlider:SetDecimals(0)
    ageSlider:SetValue(25)
    ageSlider:SetText("")
    ageSlider.OnValueChanged = function(self, value)
        characterData.age = math.floor(value)
        ageLabel:SetText("ÂGE: " .. characterData.age)
    end
    
    -- ═══ ORIGINE ═══
    local originLabel = vgui.Create("DLabel", scroll)
    originLabel:Dock(TOP)
    originLabel:DockMargin(0, 10, 0, 5)
    originLabel:SetText("ORIGINE / HISTOIRE")
    originLabel:SetFont("DCUO_HUD_Small")
    originLabel:SetTextColor(DCUO.Colors.Electric)
    
    local originEntry = vgui.Create("DTextEntry", scroll)
    originEntry:Dock(TOP)
    originEntry:DockMargin(0, 0, 0, 10)
    originEntry:SetTall(80)
    originEntry:SetFont("DCUO_HUD_Tiny")
    originEntry:SetMultiline(true)
    originEntry:SetPlaceholderText("Décrivez l'origine de votre personnage...")
    originEntry.OnChange = function(self)
        characterData.origin = self:GetValue()
    end
    originEntry.Paint = fnameEntry.Paint
    
    -- ═══ FACTION ═══
    local factionLabel = vgui.Create("DLabel", scroll)
    factionLabel:Dock(TOP)
    factionLabel:DockMargin(0, 10, 0, 5)
    factionLabel:SetText("ALIGNEMENT")
    factionLabel:SetFont("DCUO_HUD_Small")
    factionLabel:SetTextColor(DCUO.Colors.Electric)
    
    local factionPanel = vgui.Create("DPanel", scroll)
    factionPanel:Dock(TOP)
    factionPanel:DockMargin(0, 0, 0, 10)
    factionPanel:SetTall(120)
    factionPanel.Paint = function() end
    
    -- Boutons de faction
    local factions = {
        {id = "Hero", name = "HÉROS", desc = "Protégez les innocents", color = DCUO.Colors.Hero},
        {id = "Villain", name = "VILAIN", desc = "Dominez le monde", color = DCUO.Colors.Villain},
        {id = "Neutral", name = "NEUTRE", desc = "Suivez votre propre voie", color = DCUO.Colors.Neutral},
    }
    
    for i, faction in ipairs(factions) do
        local btn = vgui.Create("DButton", factionPanel)
        btn:SetPos((i - 1) * 290, 0)
        btn:SetSize(280, 110)
        btn:SetText("")
        
        btn.Paint = function(self, w, h)
            local color = faction.color
            local alpha = 150
            
            if characterData.faction == faction.id then
                alpha = 255
                -- Bordure active
                surface.SetDrawColor(color.r, color.g, color.b, 200)
                draw.RoundedBox(8, -2, -2, w + 4, h + 4, color)
            end
            
            if self:IsHovered() then
                alpha = 200
            end
            
            -- Background
            draw.RoundedBox(6, 0, 0, w, h, ColorAlpha(DCUO.Colors.Dark, alpha))
            
            -- Bordure
            surface.SetDrawColor(color.r, color.g, color.b, alpha)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
            
            -- Texte
            draw.SimpleText(faction.name, "DCUO_HUD_Medium", w / 2, 30, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(faction.desc, "DCUO_HUD_Tiny", w / 2, 70, DCUO.Colors.Light, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        btn.DoClick = function()
            characterData.faction = faction.id
            surface.PlaySound("buttons/button14.wav")
        end
    end
    
    -- ═══ BOUTON VALIDER ═══
    local validateBtn = vgui.Create("DButton", creatorFrame)
    validateBtn:SetPos(creatorFrame:GetWide() / 2 - 150, creatorFrame:GetTall() - 60)
    validateBtn:SetSize(300, 50)
    validateBtn:SetText("")
    
    validateBtn.Paint = function(self, w, h)
        local color = DCUO.Colors.Success
        
        if self:IsHovered() then
            -- Glow
            surface.SetDrawColor(color.r, color.g, color.b, 100)
            draw.RoundedBox(8, -2, -2, w + 4, h + 4, color)
        end
        
        -- Background
        draw.RoundedBox(6, 0, 0, w, h, color)
        
        -- Texte
        draw.SimpleText("VALIDER ET COMMENCER", "DCUO_HUD_Medium", w / 2, h / 2, DCUO.Colors.Light, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    validateBtn.DoClick = function()
        -- Validation
        if characterData.firstname == "" or characterData.lastname == "" then
            DCUO.UI.AddNotification("Veuillez remplir votre nom complet", DCUO.Colors.Error, 3)
            surface.PlaySound("buttons/button10.wav")
            return
        end
        
        -- Créer le nom RP complet
        characterData.rpname = characterData.firstname .. " " .. characterData.lastname
        
        -- Envoyer au serveur
        net.Start("DCUO:CreateCharacter")
            net.WriteTable(characterData)
        net.SendToServer()
        
        -- Fermer
        creatorFrame:Remove()
        
        DCUO.UI.AddNotification("Personnage créé avec succès!", DCUO.Colors.Success, 5)
        surface.PlaySound("buttons/button9.wav")
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    NETWORK                                        ║
-- ╚═══════════════════════════════════════════════════════════════════╝

net.Receive("DCUO:OpenCharacterCreator", function()
    DCUO.Log("Received DCUO:OpenCharacterCreator from server!", "SUCCESS")
    DCUO.Log("Opening character creator UI...", "INFO")
    DCUO.CharacterCreator.Open()
    DCUO.Log("Character creator opened!", "SUCCESS")
end)

DCUO.Log("Character creator loaded", "SUCCESS")

--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Scoreboard Impressionnant
    Affiche les joueurs connectés avec leurs informations
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

DCUO.Scoreboard = DCUO.Scoreboard or {}
DCUO.Scoreboard.IsOpen = false
DCUO.Scoreboard.Frame = nil

-- Couleurs du scoreboard
local COLOR_BG = Color(15, 15, 20, 245)
local COLOR_HEADER = Color(25, 25, 30, 250)
local COLOR_PLAYER_BG = Color(30, 30, 35, 230)
local COLOR_PLAYER_HOVER = Color(40, 40, 50, 240)
local COLOR_ACCENT = Color(52, 152, 219)
local COLOR_GOLD = Color(241, 196, 15)

-- Configuration
local SCOREBOARD_WIDTH = 900
local SCOREBOARD_HEIGHT = 700
local HEADER_HEIGHT = 120
local LOGO_SIZE = 80
local PLAYER_HEIGHT = 60

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CRÉER LE SCOREBOARD                            ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Scoreboard.Create()
    print("[DCUO Scoreboard] Create() appelée...")
    
    if IsValid(DCUO.Scoreboard.Frame) then
        print("[DCUO Scoreboard] Fermeture de l'ancien frame...")
        DCUO.Scoreboard.Frame:Remove()
    end
    
    local scrW, scrH = ScrW(), ScrH()
    
    -- Frame principale
    local frame = vgui.Create("DFrame")
    frame:SetSize(SCOREBOARD_WIDTH, SCOREBOARD_HEIGHT)
    frame:SetPos(scrW / 2 - SCOREBOARD_WIDTH / 2, scrH / 2 - SCOREBOARD_HEIGHT / 2)
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    frame:SetKeyboardInputEnabled(false)
    
    print("[DCUO Scoreboard] Frame VGUI créée avec succès!")
    
    frame.Paint = function(self, w, h)
        -- Fond avec blur
        Derma_DrawBackgroundBlur(self, 0)
        
        -- Fond principal
        draw.RoundedBox(12, 0, 0, w, h, COLOR_BG)
        
        -- Bordure brillante
        surface.SetDrawColor(COLOR_ACCENT.r, COLOR_ACCENT.g, COLOR_ACCENT.b, 150)
        surface.DrawOutlinedRect(0, 0, w, h, 3)
        
        -- Ligne de séparation après le header
        surface.SetDrawColor(COLOR_ACCENT)
        surface.DrawRect(20, HEADER_HEIGHT, w - 40, 2)
    end
    
    DCUO.Scoreboard.Frame = frame
    
    -- ═══ HEADER (Logo + Infos Serveur) ═══
    DCUO.Scoreboard.CreateHeader(frame)
    
    -- ═══ LISTE DES JOUEURS ═══
    DCUO.Scoreboard.CreatePlayerList(frame)
    
    -- ═══ FOOTER (Statistiques) ═══
    DCUO.Scoreboard.CreateFooter(frame)
    
    DCUO.Scoreboard.IsOpen = true
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    HEADER (Logo + Titre)                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Scoreboard.CreateHeader(parent)
    local header = vgui.Create("DPanel", parent)
    header:SetPos(0, 0)
    header:SetSize(parent:GetWide(), HEADER_HEIGHT)
    
    header.Paint = function(self, w, h)
        -- Fond du header
        draw.RoundedBoxEx(12, 0, 0, w, h, COLOR_HEADER, true, true, false, false)
        
        -- Gradient subtil
        surface.SetDrawColor(COLOR_ACCENT.r, COLOR_ACCENT.g, COLOR_ACCENT.b, 30)
        surface.DrawRect(0, 0, w, h)
        
        -- Logo du serveur (cercle avec initiales)
        local logoX = 30
        local logoY = h / 2
        
        -- Cercle externe (glow)
        draw.NoTexture()
        surface.SetDrawColor(COLOR_ACCENT.r, COLOR_ACCENT.g, COLOR_ACCENT.b, 100)
        for i = 0, 5 do
            surface.DrawOutlinedCircle(logoX + LOGO_SIZE/2, logoY, LOGO_SIZE/2 + i, 100)
        end
        
        -- Cercle du logo
        surface.SetDrawColor(COLOR_ACCENT.r, COLOR_ACCENT.g, COLOR_ACCENT.b, 200)
        surface.DrawOutlinedCircle(logoX + LOGO_SIZE/2, logoY, LOGO_SIZE/2, 100)
        
        draw.RoundedBox(LOGO_SIZE/2, logoX, logoY - LOGO_SIZE/2, LOGO_SIZE, LOGO_SIZE, Color(COLOR_ACCENT.r, COLOR_ACCENT.g, COLOR_ACCENT.b, 50))
        
        -- Initiales du serveur
        draw.SimpleText("DCUO", "DermaLarge", logoX + LOGO_SIZE/2, logoY, COLOR_ACCENT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Titre du serveur
        local titleX = logoX + LOGO_SIZE + 30
        draw.SimpleText("DC UNIVERSE ONLINE - ROLEPLAY", "DermaLarge", titleX, h/2 - 15, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        -- Sous-titre
        local serverName = GetHostName() or "Serveur GMOD"
        draw.SimpleText(serverName, "DermaDefault", titleX, h/2 + 15, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        -- Compteur de joueurs (à droite)
        local playerCount = player.GetCount()
        local maxPlayers = game.MaxPlayers()
        local countText = playerCount .. " / " .. maxPlayers .. " joueurs"
        
        draw.RoundedBox(8, w - 220, h/2 - 25, 200, 50, Color(COLOR_GOLD.r, COLOR_GOLD.g, COLOR_GOLD.b, 100))
        surface.SetDrawColor(COLOR_GOLD)
        surface.DrawOutlinedRect(w - 220, h/2 - 25, 200, 50, 2)
        
        draw.SimpleText(countText, "DermaLarge", w - 120, h/2 - 10, COLOR_GOLD, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("EN LIGNE", "DermaDefault", w - 120, h/2 + 12, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    LISTE DES JOUEURS                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Scoreboard.CreatePlayerList(parent)
    local listContainer = vgui.Create("DPanel", parent)
    listContainer:SetPos(10, HEADER_HEIGHT + 20)
    listContainer:SetSize(parent:GetWide() - 20, parent:GetTall() - HEADER_HEIGHT - 80)
    listContainer.Paint = nil
    
    -- Colonnes header
    local columnHeader = vgui.Create("DPanel", listContainer)
    columnHeader:Dock(TOP)
    columnHeader:SetTall(40)
    columnHeader:DockMargin(0, 0, 0, 5)
    
    columnHeader.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 50, 200))
        
        -- Colonnes
        local columns = {
            {x = 50, text = "NOM", align = TEXT_ALIGN_LEFT},
            {x = 350, text = "MÉTIER", align = TEXT_ALIGN_LEFT},
            {x = 550, text = "FACTION", align = TEXT_ALIGN_LEFT},
            {x = 680, text = "NIVEAU", align = TEXT_ALIGN_CENTER},
            {x = 780, text = "PING", align = TEXT_ALIGN_CENTER},
        }
        
        for _, col in ipairs(columns) do
            draw.SimpleText(col.text, "DermaDefaultBold", col.x, h/2, Color(200, 200, 200), col.align, TEXT_ALIGN_CENTER)
        end
    end
    
    -- Liste scrollable
    local playerList = vgui.Create("DScrollPanel", listContainer)
    playerList:Dock(FILL)
    
    -- Customiser la scrollbar
    local sbar = playerList:GetVBar()
    sbar:SetWide(8)
    sbar.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 25, 200))
    end
    sbar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(COLOR_ACCENT.r, COLOR_ACCENT.g, COLOR_ACCENT.b, 200))
    end
    sbar.btnUp.Paint = function() end
    sbar.btnDown.Paint = function() end
    
    -- Ajouter chaque joueur
    for _, ply in ipairs(player.GetAll()) do
        DCUO.Scoreboard.CreatePlayerRow(playerList, ply)
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    LIGNE JOUEUR                                   ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Scoreboard.CreatePlayerRow(parent, ply)
    local row = vgui.Create("DButton", parent)
    row:Dock(TOP)
    row:SetTall(PLAYER_HEIGHT)
    row:DockMargin(0, 0, 0, 3)
    row:SetText("")
    
    local isHovered = false
    
    row.Paint = function(self, w, h)
        local bgColor = isHovered and COLOR_PLAYER_HOVER or COLOR_PLAYER_BG
        draw.RoundedBox(8, 0, 0, w, h, bgColor)
        
        -- Bordure de faction
        local factionColor = Color(100, 100, 100)
        if IsValid(ply) and ply.DCUOData and ply.DCUOData.faction then
            if ply.DCUOData.faction == "Hero" then
                factionColor = Color(52, 152, 219) -- Bleu
            elseif ply.DCUOData.faction == "Villain" then
                factionColor = Color(231, 76, 60) -- Rouge
            elseif ply.DCUOData.faction == "Neutral" then
                factionColor = Color(149, 165, 166) -- Gris
            end
        end
        
        surface.SetDrawColor(factionColor)
        surface.DrawRect(0, 0, 5, h)
        
        if not IsValid(ply) then return end
        
        -- Avatar (cercle avec initiale)
        local avatarX = 25
        local avatarY = h / 2
        local avatarSize = 36
        
        draw.NoTexture()
        surface.SetDrawColor(factionColor.r, factionColor.g, factionColor.b, 150)
        draw.RoundedBox(avatarSize/2, avatarX - avatarSize/2, avatarY - avatarSize/2, avatarSize, avatarSize, Color(factionColor.r, factionColor.g, factionColor.b, 50))
        surface.DrawOutlinedCircle(avatarX, avatarY, avatarSize/2, 50)
        
        local initial = string.sub(ply:Nick(), 1, 1):upper()
        draw.SimpleText(initial, "DermaLarge", avatarX, avatarY, factionColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Nom du joueur
        local nameColor = Color(255, 255, 255)
        if ply == LocalPlayer() then
            nameColor = COLOR_GOLD
        end
        draw.SimpleText(ply:Nick(), "DermaDefaultBold", 50, h/2, nameColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        -- Métier
        local jobName = "Recrue"
        if ply.DCUOData and ply.DCUOData.job then
            local job = DCUO.Jobs.Get(ply.DCUOData.job)
            if job then
                jobName = job.name
            end
        end
        draw.SimpleText(jobName, "DermaDefault", 350, h/2, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        -- Faction
        local factionName = ply.DCUOData and ply.DCUOData.faction or "Neutral"
        local factionDisplay = factionName == "Hero" and "Héros" or (factionName == "Villain" and "Vilain" or "Neutre")
        draw.SimpleText(factionDisplay, "DermaDefault", 550, h/2, factionColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        -- Niveau avec badge
        local level = (ply.DCUOData and ply.DCUOData.level) or 1
        local levelBgX = 680 - 25
        local levelBgY = h/2 - 15
        
        draw.RoundedBox(6, levelBgX, levelBgY, 50, 30, Color(COLOR_GOLD.r, COLOR_GOLD.g, COLOR_GOLD.b, 100))
        surface.SetDrawColor(COLOR_GOLD)
        surface.DrawOutlinedRect(levelBgX, levelBgY, 50, 30, 1)
        draw.SimpleText(level, "DermaDefaultBold", 680, h/2, COLOR_GOLD, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Ping avec couleur
        local ping = ply:Ping()
        local pingColor = Color(46, 204, 113) -- Vert
        if ping > 100 then
            pingColor = Color(241, 196, 15) -- Orange
        end
        if ping > 200 then
            pingColor = Color(231, 76, 60) -- Rouge
        end
        
        draw.SimpleText(ping .. " ms", "DermaDefault", 780, h/2, pingColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Indicateur Admin
        if ply:IsAdmin() then
            draw.RoundedBox(4, w - 85, h/2 - 12, 70, 24, Color(231, 76, 60, 150))
            draw.SimpleText("ADMIN", "DermaDefault", w - 50, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    row.OnCursorEntered = function()
        isHovered = true
    end
    
    row.OnCursorExited = function()
        isHovered = false
    end
    
    row.DoClick = function()
        -- Clic sur un joueur (ouvrir menu contextuel par exemple)
        if IsValid(ply) and ply ~= LocalPlayer() then
            -- Pourrait ouvrir un menu d'interaction
            surface.PlaySound("UI/buttonclick.wav")
        end
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FOOTER (Statistiques)                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Scoreboard.CreateFooter(parent)
    local footer = vgui.Create("DPanel", parent)
    footer:SetPos(10, parent:GetTall() - 50)
    footer:SetSize(parent:GetWide() - 20, 40)
    
    footer.Paint = function(self, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, Color(25, 25, 30, 230), false, false, true, true)
        
        -- Stats serveur
        local stats = {
            {icon = "★", text = "Serveur: " .. (GetHostName() or "DCUO-RP"), color = COLOR_ACCENT},
            {icon = "🌍", text = "Map: " .. game.GetMap(), color = Color(46, 204, 113)},
            {icon = "⏱", text = "Uptime: " .. string.FormattedTime(CurTime()), color = Color(241, 196, 15)},
        }
        
        local startX = 20
        local spacing = (w - 40) / #stats
        
        for i, stat in ipairs(stats) do
            local x = startX + (i - 1) * spacing
            draw.SimpleText(stat.icon .. " " .. stat.text, "DermaDefault", x, h/2, stat.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        -- Instructions
        draw.SimpleText("Maintenez TAB pour voir le scoreboard", "DermaDefault", w - 20, h/2, Color(150, 150, 150), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONCTIONS UTILITAIRES                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Dessiner un cercle (helper)
function surface.DrawOutlinedCircle(x, y, radius, segments)
    local circle = {}
    table.insert(circle, {x = x, y = y, u = 0.5, v = 0.5})
    for i = 0, segments do
        local a = math.rad((i / segments) * -360)
        table.insert(circle, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})
    end
    
    surface.DrawPoly(circle)
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    HOOKS                                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Ouvrir le scoreboard
hook.Add("ScoreboardShow", "DCUO:ShowScoreboard", function()
    print("[DCUO Scoreboard] ScoreboardShow hook déclenché!")
    DCUO.Scoreboard.Create()
    DCUO.Scoreboard.IsOpen = true
    print("[DCUO Scoreboard] Scoreboard créé et affiché!")
    return false -- Retourner false pour empêcher le scoreboard par défaut APRÈS avoir créé le nôtre
end)

-- Fermer le scoreboard
hook.Add("ScoreboardHide", "DCUO:HideScoreboard", function()
    print("[DCUO Scoreboard] ScoreboardHide hook déclenché!")
    if IsValid(DCUO.Scoreboard.Frame) then
        DCUO.Scoreboard.Frame:Remove()
        DCUO.Scoreboard.Frame = nil
        print("[DCUO Scoreboard] Frame supprimée!")
    end
    DCUO.Scoreboard.IsOpen = false
    return false -- Retourner false pour empêcher le comportement par défaut
end)

print("[DCUO] Scoreboard chargé avec succès! Appuyez sur TAB pour l'afficher.")

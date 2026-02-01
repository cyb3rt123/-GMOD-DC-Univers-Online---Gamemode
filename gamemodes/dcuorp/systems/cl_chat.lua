--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Chat Avancé (Client)
    Interface et affichage des messages
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

DCUO.Chat = DCUO.Chat or {}
DCUO.Chat.Messages = {}
DCUO.Chat.MaxMessages = DCUO.Chat.Config.MaxHistoryLines or 100

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    RÉCEPTION DES MESSAGES                         ║
-- ╚═══════════════════════════════════════════════════════════════════╝

net.Receive("DCUO:Chat:Message", function()
    local channelID = net.ReadString()
    local sender = net.ReadEntity()
    local message = net.ReadString()
    local isPM = net.ReadBool()
    
    local channel = DCUO.Chat.GetChannel(channelID)
    if not channel then return end
    
    -- Ajouter à l'historique
    local messageData = {
        channel = channel,
        sender = sender,
        message = message,
        time = os.date("%H:%M"),
        realtime = RealTime(),
    }
    
    table.insert(DCUO.Chat.Messages, messageData)
    
    -- Limiter l'historique
    if #DCUO.Chat.Messages > DCUO.Chat.MaxMessages then
        table.remove(DCUO.Chat.Messages, 1)
    end
    
    -- Afficher dans le chat console
    DCUO.Chat.PrintToConsole(messageData)
    
    -- Son
    if DCUO.Chat.Config.EnableSounds then
        surface.PlaySound("buttons/button14.wav")
    end
end)

net.Receive("DCUO:Chat:PM", function()
    local other = net.ReadEntity()
    local message = net.ReadString()
    local sent = net.ReadBool()
    
    if not IsValid(other) then return end
    
    local otherName = other.DCUOData and other.DCUOData.rpname or other:Nick()
    
    -- Afficher dans le chat
    if sent then
        chat.AddText(
            Color(255, 100, 255), "[MP → ",
            DCUO.Chat.GetPlayerColor(other), otherName,
            Color(255, 100, 255), "] ",
            color_white, message
        )
    else
        chat.AddText(
            Color(255, 100, 255), "[MP ← ",
            DCUO.Chat.GetPlayerColor(other), otherName,
            Color(255, 100, 255), "] ",
            color_white, message
        )
        
        -- Son différent pour réception
        if DCUO.Chat.Config.EnableSounds then
            surface.PlaySound("buttons/button15.wav")
        end
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    AFFICHAGE CONSOLE                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Chat.PrintToConsole(messageData)
    local channel = messageData.channel
    local sender = messageData.sender
    local message = messageData.message
    local time = messageData.time
    
    if not IsValid(sender) then return end
    
    local playerName = DCUO.Chat.FormatPlayerName(sender)
    local playerColor = DCUO.Chat.GetPlayerColor(sender)
    
    -- Construire le message
    local parts = {}
    
    if DCUO.Chat.Config.ShowTimestamp then
        table.insert(parts, Color(150, 150, 150))
        table.insert(parts, "[" .. time .. "] ")
    end
    
    table.insert(parts, channel.color)
    table.insert(parts, channel.icon .. " " .. channel.prefix .. " ")
    
    table.insert(parts, playerColor)
    table.insert(parts, playerName)
    
    table.insert(parts, color_white)
    table.insert(parts, ": " .. message)
    
    chat.AddText(unpack(parts))
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    AFFICHAGE HUD                                  ║
-- ╚═══════════════════════════════════════════════════════════════════╝

local chatHUDEnabled = CreateClientConVar("dcuo_chat_hud", "1", true, false, "Afficher les messages sur le HUD")
local chatHUDX = CreateClientConVar("dcuo_chat_hud_x", "20", true, false, "Position X du chat HUD")
local chatHUDY = CreateClientConVar("dcuo_chat_hud_y", "400", true, false, "Position Y du chat HUD")

hook.Add("HUDPaint", "DCUO:Chat:HUD", function()
    if not chatHUDEnabled:GetBool() then return end
    if not LocalPlayer():Alive() then return end
    
    local x = chatHUDX:GetInt()
    local y = chatHUDY:GetInt()
    local maxWidth = 600
    local lineHeight = 22
    local maxLines = 8
    local fadeTime = DCUO.Chat.Config.FadeTime
    
    -- Filtrer les messages récents
    local recentMessages = {}
    for i = #DCUO.Chat.Messages, 1, -1 do
        local msg = DCUO.Chat.Messages[i]
        if RealTime() - msg.realtime <= fadeTime then
            table.insert(recentMessages, msg)
            if #recentMessages >= maxLines then break end
        end
    end
    
    -- Inverser pour afficher du plus ancien au plus récent
    table.Reverse(recentMessages)
    
    -- Afficher
    for i, messageData in ipairs(recentMessages) do
        local alpha = 255
        local timeSince = RealTime() - messageData.realtime
        
        -- Fade out dans les dernières secondes
        if timeSince > fadeTime - 2 then
            alpha = math.Clamp(255 * (1 - (timeSince - (fadeTime - 2)) / 2), 0, 255)
        end
        
        local yPos = y + (i - 1) * lineHeight
        
        -- Background
        local bgAlpha = alpha * 0.6
        draw.RoundedBox(4, x - 5, yPos - 2, maxWidth, lineHeight - 2, Color(10, 10, 15, bgAlpha))
        
        -- Icône canal
        draw.SimpleText(
            messageData.channel.icon,
            "DermaDefault",
            x,
            yPos,
            Color(messageData.channel.color.r, messageData.channel.color.g, messageData.channel.color.b, alpha),
            TEXT_ALIGN_LEFT
        )
        
        -- Nom joueur
        local playerName = IsValid(messageData.sender) and messageData.sender:Nick() or "Unknown"
        local playerColor = IsValid(messageData.sender) and DCUO.Chat.GetPlayerColor(messageData.sender) or color_white
        
        draw.SimpleText(
            playerName .. ":",
            "DermaDefaultBold",
            x + 25,
            yPos,
            Color(playerColor.r, playerColor.g, playerColor.b, alpha),
            TEXT_ALIGN_LEFT
        )
        
        -- Message
        local nameWidth = surface.GetTextSize(playerName .. ": ")
        draw.SimpleText(
            messageData.message,
            "DermaDefault",
            x + 25 + nameWidth,
            yPos,
            Color(255, 255, 255, alpha),
            TEXT_ALIGN_LEFT
        )
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FENÊTRE DE CHAT (F9)                           ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Chat.OpenWindow()
    if IsValid(DCUO.Chat.Window) then
        DCUO.Chat.Window:Remove()
        return
    end
    
    local w, h = 700, 500
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(w, h)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    DCUO.Chat.Window = frame
    
    frame.Paint = function(self, fw, fh)
        Derma_DrawBackgroundBlur(self, 0)
        draw.RoundedBox(8, 0, 0, fw, fh, Color(20, 20, 30, 240))
        
        -- Header
        draw.RoundedBoxEx(8, 0, 0, fw, 40, Color(30, 30, 45), true, true, false, false)
        draw.SimpleText("💬 HISTORIQUE DU CHAT", "DCUO_Font_24", fw/2, 20, DCUO.Colors.Electric, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Bordure
        surface.SetDrawColor(DCUO.Colors.Electric.r, DCUO.Colors.Electric.g, DCUO.Colors.Electric.b, 100)
        surface.DrawOutlinedRect(0, 0, fw, fh, 2)
    end
    
    -- Bouton fermer
    local btnClose = vgui.Create("DButton", frame)
    btnClose:SetSize(30, 30)
    btnClose:SetPos(w - 35, 5)
    btnClose:SetText("")
    
    btnClose.Paint = function(self, bw, bh)
        local col = self:IsHovered() and Color(220, 50, 50) or Color(180, 40, 40)
        draw.RoundedBox(15, 0, 0, bw, bh, col)
        draw.SimpleText("✖", "DermaDefault", bw/2, bh/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    btnClose.DoClick = function()
        frame:Remove()
    end
    
    -- Liste des messages
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(10, 50)
    scroll:SetSize(w - 20, h - 60)
    
    local y = 0
    for _, messageData in ipairs(DCUO.Chat.Messages) do
        local msgPanel = vgui.Create("DPanel", scroll)
        msgPanel:SetSize(w - 40, 25)
        msgPanel:SetPos(0, y)
        
        msgPanel.Paint = function(self, pw, ph)
            local bgCol = y % 50 == 0 and Color(25, 25, 35) or Color(30, 30, 40)
            draw.RoundedBox(4, 0, 0, pw, ph, bgCol)
            
            -- Temps
            draw.SimpleText(messageData.time, "DermaDefault", 5, ph/2, Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            -- Canal
            draw.SimpleText(
                messageData.channel.icon,
                "DermaDefault",
                60,
                ph/2,
                messageData.channel.color,
                TEXT_ALIGN_LEFT,
                TEXT_ALIGN_CENTER
            )
            
            -- Joueur
            local playerName = IsValid(messageData.sender) and messageData.sender:Nick() or "Unknown"
            local playerColor = IsValid(messageData.sender) and DCUO.Chat.GetPlayerColor(messageData.sender) or color_white
            
            draw.SimpleText(
                playerName .. ":",
                "DermaDefaultBold",
                85,
                ph/2,
                playerColor,
                TEXT_ALIGN_LEFT,
                TEXT_ALIGN_CENTER
            )
            
            -- Message
            local nameW = surface.GetTextSize(playerName .. ": ")
            draw.SimpleText(
                messageData.message,
                "DermaDefault",
                85 + nameW,
                ph/2,
                color_white,
                TEXT_ALIGN_LEFT,
                TEXT_ALIGN_CENTER
            )
        end
        
        y = y + 25
    end
    
    -- Scroll vers le bas
    timer.Simple(0.1, function()
        if IsValid(scroll) then
            scroll:GetVBar():SetScroll(scroll:GetVBar().CanvasSize)
        end
    end)
end

-- Bind F9
hook.Add("PlayerButtonDown", "DCUO:Chat:OpenWindow", function(ply, button)
    if button == KEY_F9 then
        DCUO.Chat.OpenWindow()
    end
end)

concommand.Add("dcuo_chat", function()
    DCUO.Chat.OpenWindow()
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    MENU D'AIDE                                    ║
-- ╚═══════════════════════════════════════════════════════════════════╝

concommand.Add("dcuo_chat_help", function()
    local helpFrame = vgui.Create("DFrame")
    helpFrame:SetSize(600, 500)
    helpFrame:Center()
    helpFrame:SetTitle("Aide - Commandes de Chat")
    helpFrame:MakePopup()
    
    local scroll = vgui.Create("DScrollPanel", helpFrame)
    scroll:Dock(FILL)
    
    local y = 10
    
    for _, channel in ipairs(DCUO.Chat.Channels) do
        local panel = vgui.Create("DPanel", scroll)
        panel:SetSize(560, 60)
        panel:SetPos(10, y)
        
        panel.Paint = function(self, pw, ph)
            draw.RoundedBox(6, 0, 0, pw, ph, Color(40, 40, 50))
            
            -- Icône
            draw.SimpleText(channel.icon, "DermaLarge", 15, ph/2, channel.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            -- Nom
            draw.SimpleText(channel.name, "DermaDefaultBold", 60, 15, color_white, TEXT_ALIGN_LEFT)
            
            -- Commande
            draw.SimpleText("Commande: " .. channel.command, "DermaDefault", 60, 30, Color(150, 150, 255), TEXT_ALIGN_LEFT)
            
            -- Description
            draw.SimpleText(channel.description, "DermaDefault", 60, 45, Color(200, 200, 200), TEXT_ALIGN_LEFT)
        end
        
        y = y + 65
    end
    
    -- Commande PM
    local pmPanel = vgui.Create("DPanel", scroll)
    pmPanel:SetSize(560, 60)
    pmPanel:SetPos(10, y)
    
    pmPanel.Paint = function(self, pw, ph)
        draw.RoundedBox(6, 0, 0, pw, ph, Color(40, 40, 50))
        draw.SimpleText("💌", "DermaLarge", 15, ph/2, Color(255, 100, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Message Privé", "DermaDefaultBold", 60, 15, color_white, TEXT_ALIGN_LEFT)
        draw.SimpleText("Commande: /pm <joueur> <message>", "DermaDefault", 60, 30, Color(150, 150, 255), TEXT_ALIGN_LEFT)
        draw.SimpleText("Envoyer un message privé à un joueur", "DermaDefault", 60, 45, Color(200, 200, 200), TEXT_ALIGN_LEFT)
    end
end)

DCUO.Log("Chat System (Client) Loaded", "SUCCESS")

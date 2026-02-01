-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     DUEL SYSTEM (CLIENT)                          ║
-- ║        Cinématiques et effets visuels des duels                   ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Variables locales
local activeDuel = nil
local countdownNumber = 0
local finishCamData = nil

-- Couleurs
local colorArenaWall = Color(255, 50, 50, 80)
local colorCountdown = Color(255, 200, 0)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     NETWORK RECEIVERS                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Recevoir une demande de duel
net.Receive("DCUO_DuelRequest", function()
    local requester = net.ReadEntity()
    local requestID = net.ReadString()
    
    if not IsValid(requester) then return end
    
    -- Créer la popup d'acceptation
    DCUO.ShowDuelRequest(requester, requestID)
end)

-- Démarrage du duel (cinématique intro)
net.Receive("DCUO_DuelStart", function()
    local duelID = net.ReadInt(16)
    local centerPos = net.ReadVector()
    local player1 = net.ReadEntity()
    local player2 = net.ReadEntity()
    
    activeDuel = {
        id = duelID,
        centerPos = centerPos,
        player1 = player1,
        player2 = player2,
        state = "intro"
    }
    
    -- Son d'intro
    surface.PlaySound("ambient/alarms/warningbell1.wav")
    
    -- Message
    chat.AddText(Color(255, 100, 100), "═══════════════════════════════")
    chat.AddText(Color(255, 200, 0), "DUEL COMMENCE")
    chat.AddText(Color(255, 255, 255), player1:Nick(), Color(200, 200, 200), " VS ", Color(255, 255, 255), player2:Nick())
    chat.AddText(Color(255, 100, 100), "═══════════════════════════════")
end)

-- Compte à rebours
net.Receive("DCUO_DuelCountdown", function()
    local duelID = net.ReadInt(16)
    local number = net.ReadInt(8)
    
    if activeDuel and activeDuel.id == duelID then
        countdownNumber = number
        activeDuel.state = "countdown"
        
        -- Son
        if number <= 3 then
            surface.PlaySound("buttons/button17.wav")
        end
        
        if number == DCUO.Duel.Config.CountdownDuration then
            surface.PlaySound("buttons/button3.wav")
            activeDuel.state = "fighting"
        end
    end
end)

-- Cinématique finale
net.Receive("DCUO_DuelFinishCam", function()
    local duelID = net.ReadInt(16)
    local winner = net.ReadEntity()
    local loser = net.ReadEntity()
    local reason = net.ReadString()
    
    if activeDuel and activeDuel.id == duelID then
        activeDuel.state = "finishing"
        
        finishCamData = {
            winner = winner,
            loser = loser,
            reason = reason,
            startTime = CurTime()
        }
        
        -- Son dramatique
        surface.PlaySound("physics/body/body_medium_break3.wav")
        
        -- Message
        chat.AddText(Color(255, 100, 100), "═══════════════════════════════")
        chat.AddText(Color(255, 200, 0), reason)
        chat.AddText(Color(0, 255, 0), winner:Nick(), Color(255, 255, 255), " a vaincu ", Color(255, 50, 50), loser:Nick())
        chat.AddText(Color(255, 100, 100), "═══════════════════════════════")
    end
end)

-- Fin du duel
net.Receive("DCUO_DuelEnd", function()
    local duelID = net.ReadInt(16)
    
    if activeDuel and activeDuel.id == duelID then
        activeDuel = nil
        countdownNumber = 0
        finishCamData = nil
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     POPUP DEMANDE DE DUEL                         ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.ShowDuelRequest(requester, requestID)
    -- Son de notification
    surface.PlaySound("buttons/button9.wav")
    
    -- Créer la frame
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 200)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 20, 250))
        draw.RoundedBoxEx(8, 0, 0, w, 60, Color(255, 100, 50), true, true, false, false)
        draw.SimpleText("DEMANDE DE DUEL", "DCUO_Font_Medium", w / 2, 30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Message
    local msg = vgui.Create("DLabel", frame)
    msg:SetPos(20, 80)
    msg:SetSize(360, 40)
    msg:SetText(requester:Nick() .. " vous défie en duel !")
    msg:SetFont("DCUO_Font_Small")
    msg:SetTextColor(color_white)
    msg:SetContentAlignment(5)
    msg:SetWrap(true)
    
    -- Bouton Accepter
    local acceptBtn = vgui.Create("DButton", frame)
    acceptBtn:SetPos(20, 130)
    acceptBtn:SetSize(170, 50)
    acceptBtn:SetText("")
    acceptBtn.DoClick = function()
        RunConsoleCommand("dcuo_accept_duel", requestID)
        frame:Remove()
    end
    acceptBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(0, 200, 0, 220) or Color(0, 150, 0, 200)
        draw.RoundedBox(6, 0, 0, w, h, col)
        draw.SimpleText("ACCEPTER", "DCUO_Font_Small", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Bouton Refuser
    local declineBtn = vgui.Create("DButton", frame)
    declineBtn:SetPos(210, 130)
    declineBtn:SetSize(170, 50)
    declineBtn:SetText("")
    declineBtn.DoClick = function()
        frame:Remove()
        chat.AddText(Color(255, 100, 100), "[DUEL] ", Color(255, 255, 255), "Vous avez refusé le duel.")
    end
    declineBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(200, 0, 0, 220) or Color(150, 0, 0, 200)
        draw.RoundedBox(6, 0, 0, w, h, col)
        draw.SimpleText("REFUSER", "DCUO_Font_Small", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Auto-fermer après 30 secondes
    timer.Simple(30, function()
        if IsValid(frame) then
            frame:Remove()
        end
    end)
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     AFFICHAGE VISUEL                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Dessiner l'arène
hook.Add("PostDrawTranslucentRenderables", "DCUO_Duel_DrawArena", function()
    if not activeDuel then return end
    if activeDuel.state == "intro" or activeDuel.state == "finishing" then return end
    
    local center = activeDuel.centerPos
    local radius = DCUO.Duel.Config.ArenaRadius
    local height = DCUO.Duel.Config.ArenaWallHeight
    
    -- Dessiner un cylindre de barrière
    render.SetColorMaterial()
    
    local segments = 32
    for i = 0, segments - 1 do
        local ang1 = (i / segments) * math.pi * 2
        local ang2 = ((i + 1) / segments) * math.pi * 2
        
        local x1 = center.x + math.cos(ang1) * radius
        local y1 = center.y + math.sin(ang1) * radius
        local x2 = center.x + math.cos(ang2) * radius
        local y2 = center.y + math.sin(ang2) * radius
        
        render.DrawQuad(
            Vector(x1, y1, center.z),
            Vector(x2, y2, center.z),
            Vector(x2, y2, center.z + height),
            Vector(x1, y1, center.z + height),
            colorArenaWall
        )
    end
    
    -- Cercle au sol
    render.DrawQuadEasy(
        center,
        Vector(0, 0, 1),
        radius * 2,
        radius * 2,
        Color(255, 50, 50, 30)
    )
end)

-- HUD du duel
hook.Add("HUDPaint", "DCUO_Duel_HUD", function()
    if not activeDuel then return end
    
    local scrW, scrH = ScrW(), ScrH()
    
    -- Compte à rebours
    if activeDuel.state == "countdown" and countdownNumber > 0 then
        local text = countdownNumber < DCUO.Duel.Config.CountdownDuration and tostring(countdownNumber) or "FIGHT!"
        local size = countdownNumber < DCUO.Duel.Config.CountdownDuration and 120 or 100
        
        -- Animation pulsation
        local pulse = math.abs(math.sin(CurTime() * 10))
        size = size + pulse * 20
        
        draw.SimpleTextOutlined(
            text,
            "DermaLarge",
            scrW / 2,
            scrH / 2,
            colorCountdown,
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER,
            4,
            Color(0, 0, 0, 200)
        )
    end
    
    -- Barre de vie des combattants (en haut)
    if activeDuel.state == "fighting" and IsValid(activeDuel.player1) and IsValid(activeDuel.player2) then
        local barW = 300
        local barH = 30
        local spacing = 20
        
        -- Player 1 (gauche)
        local p1Health = activeDuel.player1:Health() / activeDuel.player1:GetMaxHealth()
        draw.RoundedBox(4, scrW / 2 - barW - spacing, 20, barW, barH, Color(40, 40, 40, 200))
        draw.RoundedBox(4, scrW / 2 - barW - spacing, 20, barW * p1Health, barH, Color(0, 150, 255))
        draw.SimpleText(activeDuel.player1:Nick(), "DCUO_Font_Small", scrW / 2 - barW - spacing + 10, 35, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        -- VS
        draw.SimpleText("VS", "DCUO_Font_Medium", scrW / 2, 35, Color(255, 200, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Player 2 (droite)
        local p2Health = activeDuel.player2:Health() / activeDuel.player2:GetMaxHealth()
        draw.RoundedBox(4, scrW / 2 + spacing, 20, barW, barH, Color(40, 40, 40, 200))
        draw.RoundedBox(4, scrW / 2 + spacing, 20, barW * p2Health, barH, Color(255, 50, 50))
        draw.SimpleText(activeDuel.player2:Nick(), "DCUO_Font_Small", scrW / 2 + spacing + barW - 10, 35, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    
    -- Cinématique finale style Mortal Kombat
    if activeDuel.state == "finishing" and finishCamData then
        local elapsed = CurTime() - finishCamData.startTime
        local alpha = math.Clamp(255 - (elapsed / DCUO.Duel.Config.FinishAnimDuration) * 255, 0, 255)
        
        -- Fond noir avec fade
        draw.RoundedBox(0, 0, 0, scrW, scrH, Color(0, 0, 0, alpha * 0.8))
        
        -- Texte FATALITY / K.O.
        draw.SimpleTextOutlined(
            finishCamData.reason,
            "DermaLarge",
            scrW / 2,
            scrH / 2 - 100,
            Color(255, 0, 0, alpha),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER,
            6,
            Color(0, 0, 0, alpha)
        )
        
        -- Nom du gagnant
        if IsValid(finishCamData.winner) then
            draw.SimpleTextOutlined(
                finishCamData.winner:Nick() .. " WINS",
                "DCUO_Font_Large",
                scrW / 2,
                scrH / 2,
                Color(255, 200, 0, alpha),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER,
                4,
                Color(0, 0, 0, alpha)
            )
        end
    end
end)

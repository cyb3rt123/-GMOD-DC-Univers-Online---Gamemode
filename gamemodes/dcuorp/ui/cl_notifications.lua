--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Notifications
    Notifications élégantes et animées
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

DCUO.UI = DCUO.UI or {}
DCUO.UI.Notifications = DCUO.UI.Notifications or {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    VARIABLES                                      ║
-- ╚═══════════════════════════════════════════════════════════════════╝

local notifications = {}
local maxNotifications = 5
local notificationHeight = 60
local notificationWidth = 400

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONTS                                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

surface.CreateFont("DCUO_Notification_Title", {
    font = "Roboto",
    size = 20,
    weight = 600,
    antialias = true,
})

surface.CreateFont("DCUO_Notification_Text", {
    font = "Roboto",
    size = 16,
    weight = 400,
    antialias = true,
})

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    AJOUTER UNE NOTIFICATION                       ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.UI.AddNotification(text, color, duration, icon)
    color = color or DCUO.Colors.Light
    duration = duration or 5
    icon = icon or "icon16/information.png"
    
    -- Créer la notification
    local notif = {
        text = text,
        color = color,
        icon = icon,
        time = CurTime(),
        duration = duration,
        alpha = 0,
        targetAlpha = 255,
        y = 0,
        targetY = 0,
    }
    
    -- Ajouter à la liste
    table.insert(notifications, notif)
    
    -- Limiter le nombre de notifications
    while #notifications > maxNotifications do
        table.remove(notifications, 1)
    end
    
    -- Son
    surface.PlaySound("buttons/button15.wav")
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    DESSINER LES NOTIFICATIONS                     ║
-- ╚═══════════════════════════════════════════════════════════════════╝

local function DrawNotifications()
    local scrW, scrH = ScrW(), ScrH()
    local baseX = scrW - notificationWidth - 20
    local baseY = 100
    
    for i = #notifications, 1, -1 do
        local notif = notifications[i]
        
        -- Calculer le temps restant
        local timeLeft = notif.duration - (CurTime() - notif.time)
        
        -- Supprimer si expiré
        if timeLeft <= 0 then
            -- Fade out
            notif.targetAlpha = 0
            
            if notif.alpha <= 10 then
                table.remove(notifications, i)
                continue
            end
        end
        
        -- Calculer la position cible
        notif.targetY = baseY + ((i - 1) * (notificationHeight + 10))
        
        -- Smooth animations
        notif.alpha = Lerp(notif.alpha, notif.targetAlpha, FrameTime() * 10)
        notif.y = Lerp(notif.y, notif.targetY, FrameTime() * 10)
        
        -- Position
        local x = baseX
        local y = notif.y
        
        -- Background avec bordure néon
        local bgColor = ColorAlpha(DCUO.Colors.Dark, math.min(200, notif.alpha))
        local glowColor = ColorAlpha(notif.color, math.min(100, notif.alpha))
        
        -- Glow
        surface.SetDrawColor(glowColor.r, glowColor.g, glowColor.b, glowColor.a)
        draw.RoundedBox(8, x - 2, y - 2, notificationWidth + 4, notificationHeight + 4, glowColor)
        
        -- Background
        surface.SetDrawColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
        draw.RoundedBox(6, x, y, notificationWidth, notificationHeight, bgColor)
        
        -- Barre de temps
        local timePercent = math.Clamp(timeLeft / notif.duration, 0, 1)
        surface.SetDrawColor(notif.color.r, notif.color.g, notif.color.b, notif.alpha)
        draw.RoundedBox(0, x, y + notificationHeight - 4, notificationWidth * timePercent, 4, notif.color)
        
        -- Icon
        if notif.icon then
            surface.SetDrawColor(255, 255, 255, notif.alpha)
            surface.SetMaterial(Material(notif.icon))
            surface.DrawTexturedRect(x + 10, y + 10, 32, 32)
        end
        
        -- Texte
        local textColor = ColorAlpha(DCUO.Colors.Light, notif.alpha)
        draw.DrawText(notif.text, "DCUO_Notification_Text", x + 50, y + 20, textColor, TEXT_ALIGN_LEFT)
    end
end

hook.Add("HUDPaint", "DCUO:DrawNotifications", DrawNotifications)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    HELPER FUNCTION                                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function Lerp(a, b, t)
    return a + (b - a) * t
end

function ColorAlpha(color, alpha)
    return Color(color.r, color.g, color.b, alpha)
end

DCUO.Log("Notifications system loaded", "SUCCESS")

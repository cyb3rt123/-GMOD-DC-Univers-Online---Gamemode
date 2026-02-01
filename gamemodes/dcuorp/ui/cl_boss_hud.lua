--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - HUD Boss (Client)
    Affichage de la barre de vie du boss en haut de l'écran
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

local activeBoss = nil
local bossName = ""
local bossHealth = 0
local bossMaxHealth = 1

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONTS                                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

surface.CreateFont("DCUO_BossHUD_Name", {
    font = "Roboto",
    size = 28,
    weight = 800,
    antialias = true,
    shadow = true,
})

surface.CreateFont("DCUO_BossHUD_Health", {
    font = "Roboto",
    size = 20,
    weight = 600,
    antialias = true,
    shadow = true,
})

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    NETWORK RECEIVERS                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

net.Receive("DCUO:BossSpawned", function()
    activeBoss = net.ReadEntity()
    bossName = net.ReadString()
    local pos = net.ReadVector()
    
    -- Son d'alerte
    surface.PlaySound("ambient/alarms/klaxon1.wav")
    
    -- Notification
    chat.AddText(Color(255, 50, 50), "[!] BOSS APPARU : ", Color(255, 255, 255), bossName)
end)

net.Receive("DCUO:BossKilled", function()
    local name = net.ReadString()
    
    -- Effet sonore victoire
    surface.PlaySound("ambient/levels/citadel/strange_talk" .. math.random(1, 11) .. ".wav")
    
    -- Reset
    activeBoss = nil
end)

net.Receive("DCUO:BossWaypoint", function()
    local pos = net.ReadVector()
    local name = net.ReadString()
    
    -- Activer le GPS vers le boss
    if DCUO.MissionHUD and DCUO.MissionHUD.ClearWaypoints and DCUO.MissionHUD.AddWaypoint then
        DCUO.MissionHUD.ClearWaypoints()
        DCUO.MissionHUD.AddWaypoint(pos, "[>] " .. name, Color(255, 50, 50))
        
        chat.AddText(Color(0, 255, 0), "[V] ", Color(255, 255, 255), "GPS activé vers ", Color(255, 50, 50), name)
        surface.PlaySound("buttons/button14.wav")
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    UPDATE BOSS                                    ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("Think", "DCUO:UpdateBoss", function()
    -- Détecter tous les boss à proximité
    if not IsValid(activeBoss) then
        -- Chercher un boss
        for _, ent in ipairs(ents.GetAll()) do
            if IsValid(ent) and ent:GetNWBool("DCUO_IsBoss", false) then
                activeBoss = ent
                bossName = ent:GetNWString("DCUO_BossName", "Boss")
                break
            end
        end
    end
    
    if not IsValid(activeBoss) then
        activeBoss = nil
        return
    end
    
    if not IsValid(LocalPlayer()) then return end
    
    -- Vérifier distance
    local distance = LocalPlayer():GetPos():Distance(activeBoss:GetPos())
    if distance > (DCUO.Bosses.Config.HUDRadius or 10000) then
        return
    end
    
    -- Update santé (direct depuis l'entité + network)
    bossHealth = activeBoss:GetNWInt("DCUO_BossHealth", activeBoss:Health())
    bossMaxHealth = activeBoss:GetNWInt("DCUO_BossMaxHealth", activeBoss:GetMaxHealth())
    bossName = activeBoss:GetNWString("DCUO_BossName", "Boss")
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    AFFICHER HUD BOSS                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("HUDPaint", "DCUO:DrawBossHUD", function()
    if not IsValid(activeBoss) or not IsValid(LocalPlayer()) then return end
    
    -- Vérifier distance
    local distance = LocalPlayer():GetPos():Distance(activeBoss:GetPos())
    if distance > (DCUO.Bosses.Config.HUDRadius or 10000) then return end
    
    local scrW, scrH = ScrW(), ScrH()
    
    -- Position en haut centre
    local barWidth = 600
    local barHeight = 40
    local x = scrW/2 - barWidth/2
    local y = 50
    
    -- Background
    draw.RoundedBox(8, x - 10, y - 10, barWidth + 20, barHeight + 40, Color(0, 0, 0, 200))
    
    -- Nom du boss
    draw.SimpleText(
        "[X] " .. bossName .. " [X]",
        "DCUO_BossHUD_Name",
        scrW/2, y - 5,
        Color(255, 50, 50),
        TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP
    )
    
    -- Barre de santé - Background
    draw.RoundedBox(6, x, y + 30, barWidth, barHeight, Color(50, 0, 0, 255))
    
    -- Barre de santé - Remplissage
    local healthPercent = bossHealth / bossMaxHealth
    local healthWidth = barWidth * healthPercent
    
    -- Couleur dégradée
    local healthColor = Color(
        255,
        math.min(255, 255 * healthPercent * 2),
        0
    )
    
    draw.RoundedBox(6, x + 2, y + 32, healthWidth - 4, barHeight - 4, healthColor)
    
    -- Effet de lueur
    local glowAlpha = math.abs(math.sin(CurTime() * 3)) * 100
    draw.RoundedBox(6, x, y + 30, healthWidth, barHeight, Color(255, 255, 255, glowAlpha))
    
    -- Texte santé
    draw.SimpleText(
        bossHealth .. " / " .. bossMaxHealth .. " HP",
        "DCUO_BossHUD_Health",
        scrW/2, y + 30 + barHeight/2,
        Color(255, 255, 255),
        TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
    )
    
    -- Pourcentage
    draw.SimpleText(
        math.Round(healthPercent * 100) .. "%",
        "DCUO_BossHUD_Health",
        x + barWidth + 50, y + 30 + barHeight/2,
        Color(255, 215, 0),
        TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
    )
    
    -- Distance
    draw.SimpleText(
        math.Round(distance) .. "m",
        "DermaDefault",
        x - 50, y + 30 + barHeight/2,
        Color(200, 200, 200),
        TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER
    )
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    NETTOYAGE                                      ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("EntityRemoved", "DCUO:BossRemoved", function(ent)
    if ent == activeBoss then
        activeBoss = nil
    end
end)

DCUO.Log("Boss HUD loaded", "SUCCESS")

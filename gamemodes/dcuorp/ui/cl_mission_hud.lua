--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - HUD de Mission Amélioré avec GPS 3D
    Affiche les détails de la mission active et la navigation avancée
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

DCUO.MissionHUD = DCUO.MissionHUD or {}
DCUO.MissionHUD.ActiveMission = nil
DCUO.MissionHUD.MissionPosition = nil
DCUO.MissionHUD.Waypoints = {} -- Points de passage multiples
DCUO.MissionHUD.PathBeacons = {} -- Balises visuelles du chemin
DCUO.MissionHUD.CurrentCheckpoint = 1 -- Checkpoint actuel
DCUO.MissionHUD.CheckpointRadius = 150 -- Rayon pour valider un checkpoint

-- Configuration GPS
local GPS_CONFIG = {
    -- Mini-carte
    minimap = {
        enabled = true,
        size = 200,
        zoom = 0.3,
        x = ScrW() - 220,  -- En haut à droite
        y = 280,           -- Sous le menu des missions
    },
    -- Flèche directionnelle
    arrow = {
        size = 80,
        glowEffect = true,
        pulsating = true,
    },
    -- Balises 3D
    beacons = {
        enabled = true,
        height = 500,
        color = Color(230, 126, 34),
        pulseSpeed = 2,
    },
    -- Chemin au sol
    pathLine = {
        enabled = true,
        width = 3,
        segments = 20,
    },
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    ACTIVATION/DÉSACTIVATION                       ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.MissionHUD.SetActiveMission(missionData, position)
    DCUO.MissionHUD.ActiveMission = missionData
    DCUO.MissionHUD.MissionPosition = position
    
    DCUO.Log("Mission HUD activated: " .. (missionData and missionData.name or "None"), "INFO")
end

function DCUO.MissionHUD.ClearMission()
    DCUO.MissionHUD.ActiveMission = nil
    DCUO.MissionHUD.MissionPosition = nil
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CALCUL DE LA DIRECTION & NAVIGATION            ║
-- ╚═══════════════════════════════════════════════════════════════════╝

local function GetDirectionToMission()
    if not DCUO.MissionHUD.MissionPosition then return nil, 0, 0 end
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return nil, 0, 0 end
    
    local missionPos = DCUO.MissionHUD.MissionPosition
    local plyPos = ply:GetPos()
    local distance = plyPos:Distance(missionPos)
    
    -- Calculer l'angle horizontal
    local toMission = (missionPos - plyPos):Angle()
    local plyAngle = ply:EyeAngles()
    
    -- Différence d'angle horizontal
    local angleDiff = toMission.y - plyAngle.y
    
    -- Normaliser entre -180 et 180
    while angleDiff > 180 do angleDiff = angleDiff - 360 end
    while angleDiff < -180 do angleDiff = angleDiff + 360 end
    
    -- Calculer la différence de hauteur
    local heightDiff = missionPos.z - plyPos.z
    
    return angleDiff, distance, heightDiff
end

-- Calculer un chemin simple vers l'objectif
local function CalculatePath(startPos, endPos)
    local path = {}
    local segments = GPS_CONFIG.pathLine.segments
    
    for i = 0, segments do
        local t = i / segments
        local pos = LerpVector(t, startPos, endPos)
        
        -- Ajuster la hauteur pour rester au-dessus du sol
        local tr = util.TraceLine({
            start = pos + Vector(0, 0, 1000),
            endpos = pos - Vector(0, 0, 2000),
            mask = MASK_SOLID_BRUSHONLY
        })
        
        if tr.Hit then
            pos.z = tr.HitPos.z + 50 -- 50 unités au-dessus du sol
        end
        
        table.insert(path, pos)
    end
    
    return path
end

-- Ajouter un waypoint
function DCUO.MissionHUD.AddWaypoint(position, name, color)
    table.insert(DCUO.MissionHUD.Waypoints, {
        pos = position,
        name = name or "Waypoint",
        color = color or Color(230, 126, 34),
        time = CurTime(),
    })
end

-- Effacer tous les waypoints
function DCUO.MissionHUD.ClearWaypoints()
    DCUO.MissionHUD.Waypoints = {}
    DCUO.MissionHUD.CurrentCheckpoint = 1
end

-- Définir une série de checkpoints pour une mission
function DCUO.MissionHUD.SetCheckpoints(checkpoints)
    DCUO.MissionHUD.Waypoints = {}
    DCUO.MissionHUD.CurrentCheckpoint = 1
    
    for i, checkpoint in ipairs(checkpoints) do
        table.insert(DCUO.MissionHUD.Waypoints, {
            pos = checkpoint.pos,
            name = checkpoint.name or ("Checkpoint " .. i),
            color = checkpoint.color or Color(230, 126, 34),
            time = CurTime(),
            index = i,
        })
    end
    
    -- Activer le premier checkpoint
    if DCUO.MissionHUD.Waypoints[1] then
        DCUO.MissionHUD.MissionPosition = DCUO.MissionHUD.Waypoints[1].pos
        print("[GPS] Checkpoint 1/" .. #DCUO.MissionHUD.Waypoints .. " activé: " .. DCUO.MissionHUD.Waypoints[1].name)
    end
end

-- Vérifier si le joueur a atteint le checkpoint actuel (THROTTLED pour performance)
local nextCheckpointCheck = 0
hook.Add("Think", "DCUO:MissionHUD:CheckCheckpoints", function()
    -- THROTTLE: Check seulement toutes les 0.5 secondes au lieu de chaque frame
    if CurTime() < nextCheckpointCheck then return end
    nextCheckpointCheck = CurTime() + 0.5
    
    if not DCUO.MissionHUD.MissionPosition then return end
    if not DCUO.MissionHUD.Waypoints or #DCUO.MissionHUD.Waypoints == 0 then return end
    if DCUO.MissionHUD.CurrentCheckpoint > #DCUO.MissionHUD.Waypoints then return end
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local currentWaypoint = DCUO.MissionHUD.Waypoints[DCUO.MissionHUD.CurrentCheckpoint]
    if not currentWaypoint then return end
    
    local dist = ply:GetPos():Distance(currentWaypoint.pos)
    
    if dist <= DCUO.MissionHUD.CheckpointRadius then
        -- Checkpoint atteint !
        surface.PlaySound("buttons/button14.wav")
        
        local checkpointName = currentWaypoint.name or ("Checkpoint " .. DCUO.MissionHUD.CurrentCheckpoint)
        notification.AddLegacy("[V] " .. checkpointName .. " atteint", NOTIFY_GENERIC, 3)
        
        print("[GPS] Checkpoint " .. DCUO.MissionHUD.CurrentCheckpoint .. "/" .. #DCUO.MissionHUD.Waypoints .. " validé: " .. checkpointName)
        
        -- Passer au checkpoint suivant
        DCUO.MissionHUD.CurrentCheckpoint = DCUO.MissionHUD.CurrentCheckpoint + 1
        
        if DCUO.MissionHUD.CurrentCheckpoint <= #DCUO.MissionHUD.Waypoints then
            -- Activer le prochain checkpoint
            local nextWaypoint = DCUO.MissionHUD.Waypoints[DCUO.MissionHUD.CurrentCheckpoint]
            DCUO.MissionHUD.MissionPosition = nextWaypoint.pos
            
            local nextName = nextWaypoint.name or ("Checkpoint " .. DCUO.MissionHUD.CurrentCheckpoint)
            print("[GPS] Direction: " .. nextName .. " (" .. DCUO.MissionHUD.CurrentCheckpoint .. "/" .. #DCUO.MissionHUD.Waypoints .. ")")
            notification.AddLegacy("➤ Direction: " .. nextName, NOTIFY_HINT, 4)
        else
            -- Tous les checkpoints atteints !
            print("[GPS] Tous les checkpoints ont été atteints !")
            notification.AddLegacy("[!] Mission terminée !", NOTIFY_GENERIC, 5)
            surface.PlaySound("buttons/button15.wav")
            -- Ne pas effacer la position pour garder l'affichage
        end
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    AFFICHAGE DU HUD                               ║
-- ╚═══════════════════════════════════════════════════════════════════╝

local arrowMat = Material("icon16/arrow_up.png", "smooth")

hook.Add("HUDPaint", "DCUO_MissionHUD", function()
    if not DCUO.MissionHUD.ActiveMission then return end
    
    local mission = DCUO.MissionHUD.ActiveMission
    local scrW, scrH = ScrW(), ScrH()
    
    -- Position du panneau (coin supérieur droit)
    local panelW = 350
    local panelH = 150
    local panelX = scrW - panelW - 20
    local panelY = 20
    
    -- Fond du panneau avec blur
    local blurStrength = 3
    for i = 1, blurStrength do
        local blurMat = Material("pp/blurscreen")
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(blurMat)
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(panelX - 5, panelY - 5, panelW + 10, panelH + 10)
    end
    
    -- Fond semi-transparent
    draw.RoundedBox(8, panelX, panelY, panelW, panelH, Color(25, 25, 35, 240))
    
    -- Bordure
    surface.SetDrawColor(230, 126, 34, 180)
    surface.DrawOutlinedRect(panelX, panelY, panelW, panelH, 3)
    
    -- Badge "MISSION EN COURS"
    draw.RoundedBox(4, panelX + 10, panelY + 10, 140, 25, Color(230, 126, 34))
    draw.SimpleText("MISSION EN COURS", "DermaDefault", panelX + 80, panelY + 22, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Timer (si disponible)
    if mission.endTime then
        local timeLeft = math.max(0, mission.endTime - CurTime())
        local minutes = math.floor(timeLeft / 60)
        local seconds = math.floor(timeLeft % 60)
        local timerText = string.format("%02d:%02d", minutes, seconds)
        
        -- Couleur selon le temps restant
        local timerColor = Color(100, 200, 255)
        if timeLeft < 60 then
            timerColor = Color(231, 76, 60)  -- Rouge si moins d'1 minute
        elseif timeLeft < 180 then
            timerColor = Color(243, 156, 18)  -- Orange si moins de 3 minutes
        end
        
        draw.RoundedBox(4, panelX + panelW - 90, panelY + 10, 75, 25, Color(20, 20, 25, 200))
        draw.SimpleText(timerText, "DermaDefaultBold", panelX + panelW - 52, panelY + 22, timerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Nom de la mission
    draw.SimpleText(mission.name, "DermaDefaultBold", panelX + 15, panelY + 45, Color(255, 200, 0))
    
    -- Description
    local desc = mission.description or "Aucune description"
    if #desc > 50 then desc = string.sub(desc, 1, 47) .. "..." end
    draw.SimpleText(desc, "DermaDefault", panelX + 15, panelY + 65, Color(200, 200, 200))
    
    -- Récompense XP
    if mission.xpReward then
        draw.RoundedBox(4, panelX + 15, panelY + 90, 150, 25, Color(155, 89, 182, 200))
        draw.SimpleText("XP: +" .. mission.xpReward, "DermaDefault", panelX + 90, panelY + 102, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Distance à la mission
    local angleDiff, distance, heightDiff = GetDirectionToMission()
    if distance then
        local distText = math.Round(distance / 52.49) .. "m" -- Conversion unités Hammer en mètres
        draw.SimpleText(distText, "DermaDefaultBold", panelX + 15, panelY + 125, Color(100, 200, 255))
        
        -- Indicateur de hauteur
        if math.abs(heightDiff) > 100 then
            local heightIcon = heightDiff > 0 and "▲" or "▼"
            local heightColor = heightDiff > 0 and Color(46, 204, 113) or Color(231, 76, 60)
            local heightText = heightIcon .. " " .. math.Round(math.abs(heightDiff) / 52.49) .. "m"
            draw.SimpleText(heightText, "DermaDefault", panelX + 120, panelY + 125, heightColor)
        end
    end
    
    -- Instruction /cancel
    draw.SimpleText("Tapez /cancel pour annuler", "DermaDefault", panelX + panelW - 15, panelY + 125, Color(150, 150, 150), TEXT_ALIGN_RIGHT)
    
    -- ╔═════════════════════════════════════════════════════════════╗
    -- ║              FLÈCHE DIRECTIONNELLE AMÉLIORÉE                ║
    -- ╚═════════════════════════════════════════════════════════════╝
    
    if angleDiff and distance then
        local arrowSize = GPS_CONFIG.arrow.size
        local centerX = scrW / 2
        local centerY = 120
        
        -- Effet de pulsation
        local pulse = 1
        if GPS_CONFIG.arrow.pulsating then
            pulse = 1 + math.sin(CurTime() * 3) * 0.1
        end
        
        -- Fond circulaire avec glow
        if GPS_CONFIG.arrow.glowEffect then
            for i = 1, 5 do
                local glowSize = arrowSize * pulse + i * 10
                draw.RoundedBox(glowSize/2, centerX - glowSize/2, centerY - glowSize/2, glowSize, glowSize, Color(230, 126, 34, 50 - i * 8))
            end
        end
        
        -- Fond principal
        draw.RoundedBox(arrowSize/2, centerX - arrowSize/2, centerY - arrowSize/2, arrowSize, arrowSize, Color(25, 25, 35, 240))
        
        -- Cercle de progression (distance)
        local progress = math.Clamp(1 - (distance / 5000), 0, 1)
        for i = 0, 360 * progress, 3 do
            local rad = math.rad(i - 90)
            local x = centerX + math.cos(rad) * (arrowSize / 2 + 3)
            local y = centerY + math.sin(rad) * (arrowSize / 2 + 3)
            surface.SetDrawColor(46, 204, 113, 255)
            surface.DrawRect(x - 2, y - 2, 4, 4)
        end
        
        -- Dessiner la flèche rotative
        surface.SetMaterial(arrowMat)
        surface.SetDrawColor(230, 126, 34, 255)
        
        local m = Matrix()
        m:Translate(Vector(centerX, centerY, 0))
        m:Rotate(Angle(0, angleDiff, 0))
        m:Scale(Vector(pulse, pulse, 1))
        m:Translate(Vector(-arrowSize/2, -arrowSize/2, 0))
        
        cam.PushModelMatrix(m)
        surface.DrawTexturedRect(0, 0, arrowSize, arrowSize)
        cam.PopModelMatrix()
        
        -- Indicateur de hauteur sur la flèche
        if heightDiff and math.abs(heightDiff) > 100 then
            local heightArrow = heightDiff > 0 and "▲" or "▼"
            local heightColor = heightDiff > 0 and Color(46, 204, 113) or Color(231, 76, 60)
            draw.SimpleText(heightArrow, "DermaLarge", centerX, centerY, heightColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        -- Bordure circulaire
        surface.SetDrawColor(230, 126, 34, 255)
        for i = 0, 360, 3 do
            local rad = math.rad(i)
            local x = centerX + math.cos(rad) * (arrowSize / 2)
            local y = centerY + math.sin(rad) * (arrowSize / 2)
            surface.DrawRect(x - 1, y - 1, 2, 2)
        end
        
        -- Distance au centre de la flèche
        local distText = math.Round(distance / 52.49) .. "m"
        draw.SimpleText(distText, "DermaDefault", centerX, centerY + arrowSize/2 + 15, Color(230, 126, 34), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end
    
    -- ╔═════════════════════════════════════════════════════════════╗
    -- ║                    OBJECTIFS                                ║
    -- ╚═════════════════════════════════════════════════════════════╝
    
    if mission.objectives then
        local objY = panelY + panelH + 15
        
        for i, objective in ipairs(mission.objectives) do
            local objW = panelW
            local objH = 35
            
            -- Fond
            draw.RoundedBox(6, panelX, objY, objW, objH, Color(35, 35, 45, 230))
            surface.SetDrawColor(100, 100, 100, 150)
            surface.DrawOutlinedRect(panelX, objY, objW, objH, 2)
            
            -- Texte objectif
            local current = objective.current or 0
            local count = objective.count or 1
            local desc = objective.description or "Objectif " .. i
            local objText = string.format("%s (%d/%d)", desc, current, count)
            
            -- Couleur selon complétion
            local color = (current >= count) and Color(46, 204, 113) or Color(200, 200, 200)
            draw.SimpleText(objText, "DermaDefault", panelX + 10, objY + objH/2, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            -- Barre de progression
            local barW = objW - 20
            local barH = 4
            local barX = panelX + 10
            local barY = objY + objH - 10
            
            draw.RoundedBox(2, barX, barY, barW, barH, Color(50, 50, 50))
            
            local progress = math.Clamp(current / count, 0, 1)
            local progressColor = (current >= count) and Color(46, 204, 113) or Color(52, 152, 219)
            draw.RoundedBox(2, barX, barY, barW * progress, barH, progressColor)
            
            objY = objY + objH + 8
        end
    end
    
    -- ╔═════════════════════════════════════════════════════════════╗
    -- ║                    MINI-CARTE 3D                            ║
    -- ╚═════════════════════════════════════════════════════════════╝
    
    if GPS_CONFIG.minimap.enabled and DCUO.MissionHUD.MissionPosition then
        local ply = LocalPlayer()
        if IsValid(ply) then
            local mapSize = GPS_CONFIG.minimap.size
            local mapX = ScrW() - 220  -- Dynamique pour s'adapter
            local mapY = 280
            local zoom = GPS_CONFIG.minimap.zoom
            
            -- Fond de la mini-carte
            draw.RoundedBox(8, mapX, mapY, mapSize, mapSize, Color(15, 15, 20, 240))
            surface.SetDrawColor(52, 152, 219, 200)
            surface.DrawOutlinedRect(mapX, mapY, mapSize, mapSize, 3)
            
            -- Titre
            draw.SimpleText("MINI-CARTE", "DermaDefault", mapX + mapSize/2, mapY + 10, Color(52, 152, 219), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            
            -- Position du joueur au centre
            local playerPos = ply:GetPos()
            local centerX = mapX + mapSize/2
            local centerY = mapY + mapSize/2
            
            -- Dessiner la grille
            surface.SetDrawColor(40, 40, 50, 150)
            for i = 0, mapSize, 40 do
                surface.DrawLine(mapX + i, mapY + 30, mapX + i, mapY + mapSize)
                surface.DrawLine(mapX, mapY + 30 + i, mapX + mapSize, mapY + 30 + i)
            end
            
            -- Dessiner l'objectif de mission
            local missionPos = DCUO.MissionHUD.MissionPosition
            local relativePos = (missionPos - playerPos) * zoom
            local missionX = centerX + relativePos.y
            local missionY = centerY - relativePos.x
            
            -- Vérifier si dans les limites de la carte
            if missionX >= mapX and missionX <= mapX + mapSize and missionY >= mapY + 30 and missionY <= mapY + mapSize then
                -- Pulse de l'objectif
                local pulse = 1 + math.sin(CurTime() * 4) * 0.3
                local objSize = 12 * pulse
                
                -- Glow
                for i = 1, 3 do
                    draw.NoTexture()
                    surface.SetDrawColor(230, 126, 34, 100 - i * 30)
                    local glowSize = objSize + i * 4
                    draw.RoundedBox(glowSize/2, missionX - glowSize/2, missionY - glowSize/2, glowSize, glowSize, Color(230, 126, 34, 100 - i * 30))
                end
                
                -- Marqueur objectif
                draw.RoundedBox(objSize/2, missionX - objSize/2, missionY - objSize/2, objSize, objSize, Color(230, 126, 34))
                draw.SimpleText("✦", "DermaDefault", missionX, missionY, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            
            -- Dessiner les waypoints
            for _, waypoint in ipairs(DCUO.MissionHUD.Waypoints) do
                local wpRelPos = (waypoint.pos - playerPos) * zoom
                local wpX = centerX + wpRelPos.y
                local wpY = centerY - wpRelPos.x
                
                if wpX >= mapX and wpX <= mapX + mapSize and wpY >= mapY + 30 and wpY <= mapY + mapSize then
                    draw.RoundedBox(3, wpX - 4, wpY - 4, 8, 8, waypoint.color)
                end
            end
            
            -- Joueur au centre (toujours visible)
            local playerAngle = ply:EyeAngles().y
            draw.RoundedBox(4, centerX - 6, centerY - 6, 12, 12, Color(52, 152, 219))
            
            -- Triangle directionnel
            local triSize = 8
            local rad = math.rad(playerAngle - 90)
            local points = {
                {x = centerX + math.cos(rad) * triSize, y = centerY + math.sin(rad) * triSize},
                {x = centerX + math.cos(rad + 2.5) * triSize, y = centerY + math.sin(rad + 2.5) * triSize},
                {x = centerX + math.cos(rad - 2.5) * triSize, y = centerY + math.sin(rad - 2.5) * triSize},
            }
            draw.NoTexture()
            surface.SetDrawColor(255, 255, 255)
            surface.DrawPoly(points)
            
            -- Échelle
            local scale = math.Round(1000 * zoom)
            draw.SimpleText(scale .. "m", "DermaDefault", mapX + mapSize - 10, mapY + mapSize - 10, Color(150, 150, 150), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        end
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║              BALISES 3D ET CHEMIN DANS LE MONDE                   ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("PostDrawTranslucentRenderables", "DCUO_MissionBeacons", function()
    if not DCUO.MissionHUD.MissionPosition then return end
    if not GPS_CONFIG.beacons.enabled then return end
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local missionPos = DCUO.MissionHUD.MissionPosition
    local playerPos = ply:GetPos()
    local distance = playerPos:Distance(missionPos)
    
    -- Ne pas afficher si trop proche
    if distance < 200 then return end
    
    -- ═══ BALISE PRINCIPALE DE MISSION ═══
    
    -- Colonne de lumière
    local beaconHeight = GPS_CONFIG.beacons.height
    local pulse = math.sin(CurTime() * GPS_CONFIG.beacons.pulseSpeed) * 0.5 + 0.5
    local beaconColor = GPS_CONFIG.beacons.color
    
    -- Trace au sol pour trouver la position de base
    local tr = util.TraceLine({
        start = missionPos + Vector(0, 0, 1000),
        endpos = missionPos - Vector(0, 0, 2000),
        mask = MASK_SOLID_BRUSHONLY
    })
    
    local basePos = tr.Hit and tr.HitPos or missionPos
    
    -- Dessiner la colonne
    render.SetColorMaterial()
    
    for i = 0, beaconHeight, 50 do
        local alpha = 255 * (1 - i / beaconHeight) * pulse
        local width = 30 + math.sin(CurTime() * 2 + i * 0.01) * 10
        
        render.DrawBeam(
            basePos + Vector(0, 0, i),
            basePos + Vector(0, 0, i + 50),
            width,
            0,
            1,
            Color(beaconColor.r, beaconColor.g, beaconColor.b, alpha)
        )
    end
    
    -- Cercle au sol
    local circlePoints = {}
    for i = 0, 32 do
        local ang = math.rad((i / 32) * 360)
        local radius = 80 + pulse * 20
        table.insert(circlePoints, basePos + Vector(math.cos(ang) * radius, math.sin(ang) * radius, 5))
    end
    
    render.StartBeam(#circlePoints)
    for i, pos in ipairs(circlePoints) do
        render.AddBeam(pos, 15, i / #circlePoints, Color(beaconColor.r, beaconColor.g, beaconColor.b, 200 * pulse))
    end
    render.EndBeam()
    
    -- Marqueur 3D au sommet
    local topPos = basePos + Vector(0, 0, beaconHeight)
    local toScreen = topPos:ToScreen()
    
    if toScreen.visible and distance > 500 then
        local distText = math.Round(distance / 52.49) .. "m"
        draw.SimpleTextOutlined("OBJECTIF", "DermaLarge", toScreen.x, toScreen.y - 30, beaconColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 200))
        draw.SimpleTextOutlined(distText, "DermaDefaultBold", toScreen.x, toScreen.y - 10, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 200))
    end
    
    -- ═══ TRACÉ DU CHEMIN AU SOL ═══
    
    if GPS_CONFIG.pathLine.enabled and distance > 300 and distance < 5000 then
        local path = CalculatePath(playerPos, missionPos)
        
        if #path > 1 then
            render.SetColorMaterial()
            
            for i = 1, #path - 1 do
                local startPos = path[i]
                local endPos = path[i + 1]
                
                -- Progression de couleur le long du chemin
                local progress = i / #path
                local alpha = 255 * (1 - progress * 0.5)
                
                render.DrawBeam(
                    startPos,
                    endPos,
                    GPS_CONFIG.pathLine.width * (1 + pulse * 0.2),
                    0,
                    1,
                    Color(52, 152, 219, alpha)
                )
                
                -- Points lumineux sur le chemin
                if i % 3 == 0 then
                    local pointPulse = math.sin(CurTime() * 3 - i * 0.3) * 0.5 + 0.5
                    render.DrawSprite(startPos, 10 + pointPulse * 5, 10 + pointPulse * 5, Color(52, 152, 219, 255 * pointPulse))
                end
            end
        end
    end
    
    -- ═══ WAYPOINTS PERSONNALISÉS ═══
    
    for idx, waypoint in ipairs(DCUO.MissionHUD.Waypoints) do
        local wpDist = playerPos:Distance(waypoint.pos)
        if wpDist > 100 and wpDist < 3000 then
            -- Mini colonne
            local wpHeight = 300
            render.DrawBeam(
                waypoint.pos,
                waypoint.pos + Vector(0, 0, wpHeight),
                15,
                0,
                1,
                Color(waypoint.color.r, waypoint.color.g, waypoint.color.b, 150 * pulse)
            )
            
            -- Texte 3D
            local wpScreen = (waypoint.pos + Vector(0, 0, wpHeight)):ToScreen()
            if wpScreen.visible then
                draw.SimpleTextOutlined(waypoint.name, "DermaDefault", wpScreen.x, wpScreen.y, waypoint.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 200))
            end
        end
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    RÉSEAU - RECEVOIR MISSIONS                     ║
-- ╚═══════════════════════════════════════════════════════════════════╝

net.Receive("DCUO:MissionUpdate", function()
    local updateType = net.ReadString()
    
    if updateType == "start" then
        local missionData = net.ReadTable()
        local position = net.ReadVector()
        
        DCUO.MissionHUD.SetActiveMission(missionData, position)
        DCUO.UI.AddNotification("Mission démarrée: " .. missionData.name, Color(230, 126, 34))
        
    elseif updateType == "complete" then
        if DCUO.MissionHUD.ActiveMission then
            DCUO.UI.AddNotification("Mission terminée!", Color(46, 204, 113))
        end
        DCUO.MissionHUD.ClearMission()
        
    elseif updateType == "failed" then
        if DCUO.MissionHUD.ActiveMission then
            DCUO.UI.AddNotification("Mission échouée!", Color(231, 76, 60))
        end
        DCUO.MissionHUD.ClearMission()
        
    elseif updateType == "objective" then
        local objectives = net.ReadTable()
        if DCUO.MissionHUD.ActiveMission then
            DCUO.MissionHUD.ActiveMission.objectives = objectives
        end
        
    elseif updateType == "joined" then
        local missionData = net.ReadTable()
        -- Pour rejoindre une mission existante
        if missionData.position then
            DCUO.MissionHUD.SetActiveMission(missionData, missionData.position)
        end
    end
end)

DCUO.Log("Mission HUD loaded", "SUCCESS")

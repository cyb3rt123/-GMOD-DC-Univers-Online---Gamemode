--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Cinématiques (Client)
    Cinématiques d'introduction et effets de caméra
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

DCUO.Cinematics = DCUO.Cinematics or {}

-- Debug: Vérifier que DCUO.Config existe
if not DCUO or not DCUO.Config then
    print("[DCUO-RP] [ERROR] DCUO.Config not found in cl_cinematics.lua!")
    return
end

print("[DCUO-RP] [INFO] cl_cinematics.lua loaded - DCUO.Cinematics initialized")

local cinematicActive = false
local cinematicStartTime = 0
local cinematicDuration = 0
local cinematicCallback = nil
local cinematicText = ""
local cinematicTextLines = {}

-- Positions de caméra pour la cinématique
local cameraPositions = {}
local currentCameraIndex = 1

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONTS                                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

surface.CreateFont("DCUO_Cinematic_Title", {
    font = "Roboto",
    size = 42,
    weight = 700,
    antialias = true,
    shadow = true,
})

surface.CreateFont("DCUO_Cinematic_Text", {
    font = "Roboto",
    size = 24,
    weight = 500,
    antialias = true,
    shadow = true,
})

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    JOUER LA CINÉMATIQUE D'INTRO                   ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Cinematics.PlayIntro(callback)
    -- Vérifier que la config existe
    if not DCUO.Config or not DCUO.Config.Cinematic then
        DCUO.Log("ERROR: DCUO.Config.Cinematic not found!", "ERROR")
        if callback then callback() end
        return
    end
    
    cinematicActive = true
    cinematicStartTime = CurTime()
    cinematicDuration = DCUO.Config.Cinematic.Duration or 70 -- 1 minute 10 secondes
    cinematicCallback = callback
    cinematicText = DCUO.Config.Cinematic.Message or "Bienvenue dans DCUO-RP"
    
    -- Diviser le texte en lignes
    cinematicTextLines = string.Explode("\n", cinematicText)
    
    -- Générer des positions de caméra aléatoires
    local ply = LocalPlayer()
    local basePos = ply:GetPos()
    
    cameraPositions = {
        {pos = basePos + Vector(500, 0, 200), ang = Angle(10, 180, 0)},
        {pos = basePos + Vector(-500, 500, 300), ang = Angle(15, 45, 0)},
        {pos = basePos + Vector(0, -500, 250), ang = Angle(20, 90, 0)},
        {pos = basePos + Vector(300, 300, 400), ang = Angle(25, 225, 0)},
    }
    
    currentCameraIndex = 1
    
    -- Désactiver le HUD
    DCUO.Client.InCinematic = true
    
    -- Musique
    DCUO.Log("Checking for cinematic music...", "INFO")
    DCUO.Log("Music config exists: " .. tostring(DCUO.Config.Cinematic.Music ~= nil), "INFO")
    DCUO.Log("Music type: " .. tostring(DCUO.Config.Cinematic.MusicType), "INFO")
    
    if DCUO.Config.Cinematic.Music then
        if DCUO.Config.Cinematic.MusicType == "mp3" then
            -- Jouer un fichier MP3 local
            DCUO.Log("Playing MP3: " .. DCUO.Config.Cinematic.Music, "INFO")
            surface.PlaySound(DCUO.Config.Cinematic.Music)
        elseif DCUO.Config.Cinematic.MusicType == "youtube" then
            -- Créer un lecteur HTML pour YouTube
            DCUO.Log("Creating YouTube player for: " .. DCUO.Config.Cinematic.Music, "INFO")
            DCUO.Cinematics.CreateYouTubePlayer(DCUO.Config.Cinematic.Music)
        end
    else
        DCUO.Log("No music configured for cinematic", "WARNING")
    end
    
    DCUO.Log("Intro cinematic started", "INFO")
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    ARRÊTER LA CINÉMATIQUE                         ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Cinematics.Stop()
    cinematicActive = false
    DCUO.Client.InCinematic = false
    
    DCUO.Log("Cinematics.Stop() called", "INFO")
    DCUO.Log("Callback exists: " .. tostring(cinematicCallback ~= nil), "INFO")
    
    -- Notifier le serveur que la cinématique est terminée
    net.Start("DCUO:EndCinematic")
    net.SendToServer()
    
    -- Arrêter le lecteur YouTube si actif
    if DCUO.Cinematics.YouTubePlayer and IsValid(DCUO.Cinematics.YouTubePlayer) then
        DCUO.Cinematics.YouTubePlayer:Remove()
        DCUO.Cinematics.YouTubePlayer = nil
    end
    
    if cinematicCallback then
        DCUO.Log("Executing cinematic callback...", "INFO")
        cinematicCallback()
        cinematicCallback = nil
        DCUO.Log("Callback executed!", "SUCCESS")
    else
        DCUO.Log("No callback to execute", "WARNING")
    end
    
    DCUO.Log("Cinematic stopped", "INFO")
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    OBTENIR LA VUE DE LA CAMÉRA                    ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Cinematics.GetView()
    if not cinematicActive then return end
    
    local elapsed = CurTime() - cinematicStartTime
    
    -- Vérifier si la cinématique est terminée
    if elapsed >= cinematicDuration then
        DCUO.Cinematics.Stop()
        return
    end
    
    -- Changer de position de caméra tous les 4 secondes
    local segmentDuration = cinematicDuration / #cameraPositions
    currentCameraIndex = math.Clamp(math.floor(elapsed / segmentDuration) + 1, 1, #cameraPositions)
    
    local currentCam = cameraPositions[currentCameraIndex]
    local nextCam = cameraPositions[currentCameraIndex % #cameraPositions + 1]
    
    -- Interpolation smooth entre les positions
    local t = (elapsed % segmentDuration) / segmentDuration
    local smoothT = math.ease.InOutSine(t)
    
    local pos = LerpVector(smoothT, currentCam.pos, nextCam.pos)
    local ang = LerpAngle(smoothT, currentCam.ang, nextCam.ang)
    
    local view = {
        origin = pos,
        angles = ang,
        fov = 90,
        drawviewer = false,
    }
    
    return view
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    DESSINER LA CINÉMATIQUE                        ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("HUDPaint", "DCUO:DrawCinematic", function()
    if not cinematicActive then return end
    
    local scrW, scrH = ScrW(), ScrH()
    local elapsed = CurTime() - cinematicStartTime
    local progress = elapsed / cinematicDuration
    
    -- Barres cinématiques (letterbox)
    local barHeight = 100
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(0, 0, scrW, barHeight)
    surface.DrawRect(0, scrH - barHeight, scrW, barHeight)
    
    -- Fade in/out
    local fadeAlpha = 255
    if elapsed < 2 then
        fadeAlpha = math.Clamp((2 - elapsed) / 2 * 255, 0, 255)
    elseif elapsed > cinematicDuration - 2 then
        fadeAlpha = math.Clamp((cinematicDuration - elapsed) / 2 * 255, 0, 255)
    else
        fadeAlpha = 0
    end
    
    if fadeAlpha > 0 then
        surface.SetDrawColor(0, 0, 0, fadeAlpha)
        surface.DrawRect(0, 0, scrW, scrH)
    end
    
    -- Texte cinématique
    local textAlpha = 255
    if elapsed < 1 then
        textAlpha = math.Clamp(elapsed / 1 * 255, 0, 255)
    elseif elapsed > cinematicDuration - 3 then
        textAlpha = math.Clamp((cinematicDuration - elapsed) / 3 * 255, 0, 255)
    end
    
    -- Titre
    draw.SimpleText("DC UNIVERSE ONLINE", "DCUO_Cinematic_Title", scrW / 2, scrH / 2 - 150, ColorAlpha(DCUO.Colors.Electric, textAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("ROLEPLAY", "DCUO_Cinematic_Title", scrW / 2, scrH / 2 - 100, ColorAlpha(DCUO.Colors.Hero, textAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Message
    local lineY = scrH / 2
    for i, line in ipairs(cinematicTextLines) do
        if line:Trim() ~= "" then
            draw.SimpleText(line, "DCUO_Cinematic_Text", scrW / 2, lineY, ColorAlpha(DCUO.Colors.Light, textAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            lineY = lineY + 35
        else
            lineY = lineY + 20
        end
    end
    
    -- Barre de progression
    local barWidth = 600
    local barX = scrW / 2 - barWidth / 2
    local barY = scrH - 50
    
    -- Background
    surface.SetDrawColor(0, 0, 0, 150)
    draw.RoundedBox(4, barX, barY, barWidth, 6, Color(0, 0, 0, 150))
    
    -- Progression
    surface.SetDrawColor(DCUO.Colors.Electric.r, DCUO.Colors.Electric.g, DCUO.Colors.Electric.b, 255)
    draw.RoundedBox(4, barX, barY, barWidth * progress, 6, DCUO.Colors.Electric)
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    LECTEUR YOUTUBE                                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Cinematics.CreateYouTubePlayer(url)
    -- Créer un panel HTML pour jouer la musique YouTube
    DCUO.Cinematics.YouTubePlayer = vgui.Create("DHTML")
    DCUO.Cinematics.YouTubePlayer:SetSize(1, 1)  -- Petite taille mais existante
    DCUO.Cinematics.YouTubePlayer:SetPos(0, 0)
    DCUO.Cinematics.YouTubePlayer:SetVisible(false)  -- Invisible mais fonctionnel
    
    -- Extraire l'ID de la vidéo YouTube
    local videoId = ""
    if string.find(url, "youtu.be/") then
        videoId = string.match(url, "youtu.be/([%w-_]+)")
    elseif string.find(url, "youtube.com/watch") then
        videoId = string.match(url, "v=([%w-_]+)")
    else
        -- Si c'est juste l'ID
        videoId = url
    end
    
    DCUO.Log("Creating YouTube player for video ID: " .. videoId, "INFO")
    
    -- Charger le lecteur YouTube embarqué
    local html = [[
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { margin: 0; padding: 0; overflow: hidden; background: black; }
            </style>
        </head>
        <body>
            <div id="player"></div>
            <script>
                var tag = document.createElement('script');
                tag.src = "https://www.youtube.com/iframe_api";
                var firstScriptTag = document.getElementsByTagName('script')[0];
                firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
                
                var player;
                function onYouTubeIframeAPIReady() {
                    player = new YT.Player('player', {
                        height: '1',
                        width: '1',
                        videoId: ']] .. videoId .. [[',
                        playerVars: {
                            'autoplay': 1,
                            'controls': 0,
                            'disablekb': 1,
                            'fs': 0,
                            'modestbranding': 1,
                            'playsinline': 1,
                            'enablejsapi': 1
                        },
                        events: {
                            'onReady': function(event) {
                                event.target.playVideo();
                                console.log('YouTube player ready and playing!');
                            },
                            'onStateChange': function(event) {
                                console.log('YouTube player state:', event.data);
                            }
                        }
                    });
                }
            </script>
        </body>
        </html>
    ]]
    
    DCUO.Cinematics.YouTubePlayer:SetHTML(html)
    
    DCUO.Log("YouTube player HTML loaded for video: " .. videoId, "SUCCESS")
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    HELPER FUNCTIONS                               ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function LerpVector(t, a, b)
    return a + (b - a) * t
end

function LerpAngle(t, a, b)
    local result = Angle()
    result.p = Lerp(t, a.p, b.p)
    result.y = Lerp(t, a.y, b.y)
    result.r = Lerp(t, a.r, b.r)
    return result
end

function Lerp(t, a, b)
    return a + (b - a) * t
end

function ColorAlpha(color, alpha)
    return Color(color.r, color.g, color.b, alpha)
end

DCUO.Log("Cinematics system loaded", "SUCCESS")

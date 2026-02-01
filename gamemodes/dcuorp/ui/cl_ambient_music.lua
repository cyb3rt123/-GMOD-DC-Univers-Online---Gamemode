--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Musique d'Ambiance
    Système de musique d'ambiance YouTube en boucle
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

DCUO.AmbientMusic = DCUO.AmbientMusic or {}

-- Configuration
DCUO.AmbientMusic.Config = {
    Enabled = true,
    VideoID = "xbMZBjc8Oe4",  -- ID de la vidéo YouTube (par défaut: Man of Steel theme)
    Volume = 15,  -- Volume de 0 à 100 (30 = assez bas pour fond sonore)
    UseLocalSounds = true,  -- Utiliser les sons locaux .mp3 au lieu de YouTube
}

-- Variables locales
local musicPanel = nil
local currentSound = nil
local isReady = false
local shouldLoop = true

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    JOUER UN SON LOCAL .MP3                        ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.AmbientMusic.Play(soundPath, volume)
    -- Arrêter le son en cours
    DCUO.AmbientMusic.Stop()
    
    volume = volume or (DCUO.AmbientMusic.Config.Volume / 100)
    
    -- Vérifier que le chemin est valide
    if not soundPath or soundPath == "" then
        DCUO.Log("Invalid sound path", "ERROR")
        return
    end
    
    -- Créer le son avec CreateSound
    sound.PlayFile("sound/" .. soundPath, "noplay", function(station, errCode, errStr)
        if IsValid(station) then
            currentSound = station
            currentSound:SetVolume(volume)
            currentSound:Play()
            
            -- Loop automatique
            currentSound:EnableLooping(true)
            
            DCUO.Log("Playing ambient music: " .. soundPath .. " at volume " .. (volume * 100) .. "%", "SUCCESS")
        else
            DCUO.Log("Failed to load sound: " .. soundPath .. " - " .. tostring(errStr), "ERROR")
            print("[DCUO Music] Error code: " .. tostring(errCode))
            print("[DCUO Music] Error string: " .. tostring(errStr))
            print("[DCUO Music] Tried path: sound/" .. soundPath)
        end
    end)
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CRÉATION DU PLAYER YOUTUBE                     ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.AmbientMusic.CreatePlayer(videoID)
    if IsValid(musicPanel) then
        musicPanel:Remove()
    end
    
    videoID = videoID or DCUO.AmbientMusic.Config.VideoID
    
    DCUO.Log("Creating ambient music player for video: " .. videoID, "INFO")
    
    -- Créer le panel DHTML invisible
    musicPanel = vgui.Create("DHTML")
    musicPanel:SetSize(1, 1)
    musicPanel:SetPos(0, 0)
    musicPanel:SetVisible(false)
    
    -- HTML avec YouTube iframe API
    local html = [[
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { margin: 0; padding: 0; overflow: hidden; }
            </style>
        </head>
        <body>
            <div id="player"></div>
            <script src="https://www.youtube.com/iframe_api"></script>
            <script>
                var player;
                var videoId = ']] .. videoID .. [[';
                var targetVolume = ]] .. DCUO.AmbientMusic.Config.Volume .. [[;
                
                function onYouTubeIframeAPIReady() {
                    console.log('YouTube API ready, creating player...');
                    player = new YT.Player('player', {
                        height: '1',
                        width: '1',
                        videoId: videoId,
                        playerVars: {
                            'autoplay': 1,
                            'controls': 0,
                            'disablekb': 1,
                            'fs': 0,
                            'modestbranding': 1,
                            'rel': 0,
                            'showinfo': 0,
                            'enablejsapi': 1
                        },
                        events: {
                            'onReady': onPlayerReady,
                            'onStateChange': onPlayerStateChange
                        }
                    });
                }
                
                function onPlayerReady(event) {
                    console.log('YouTube player ready!');
                    event.target.setVolume(targetVolume);
                    event.target.playVideo();
                    console.log('Ambient music started with volume: ' + targetVolume);
                }
                
                function onPlayerStateChange(event) {
                    console.log('Player state changed: ' + event.data);
                    // YT.PlayerState.ENDED = 0
                    if (event.data == 0) {
                        console.log('Video ended, looping...');
                        event.target.seekTo(0);
                        event.target.playVideo();
                    }
                }
                
                // Fonction pour changer le volume depuis Lua
                function setVolume(vol) {
                    if (player && player.setVolume) {
                        player.setVolume(vol);
                        console.log('Volume changed to: ' + vol);
                    }
                }
                
                // Fonction pour changer la vidéo depuis Lua
                function changeVideo(newVideoId) {
                    if (player && player.loadVideoById) {
                        player.loadVideoById(newVideoId);
                        console.log('Video changed to: ' + newVideoId);
                    }
                }
            </script>
        </body>
        </html>
    ]]
    
    musicPanel:SetHTML(html)
    
    DCUO.Log("Ambient music player created with volume: " .. DCUO.AmbientMusic.Config.Volume, "SUCCESS")
    
    return musicPanel
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CONTRÔLES DE MUSIQUE                           ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Démarrer la musique d'ambiance
function DCUO.AmbientMusic.Start(videoID)
    if not DCUO.AmbientMusic.Config.Enabled then
        DCUO.Log("Ambient music is disabled", "INFO")
        return
    end
    
    DCUO.AmbientMusic.CreatePlayer(videoID)
end

-- Arrêter la musique d'ambiance
function DCUO.AmbientMusic.Stop()
    -- Arrêter le son local
    if IsValid(currentSound) then
        currentSound:Stop()
        currentSound = nil
        DCUO.Log("Local ambient music stopped", "INFO")
    end
    
    -- Arrêter YouTube
    if IsValid(musicPanel) then
        musicPanel:Remove()
        musicPanel = nil
        DCUO.Log("YouTube ambient music stopped", "INFO")
    end
end

-- Changer le volume (0-100)
function DCUO.AmbientMusic.SetVolume(volume)
    volume = math.Clamp(volume, 0, 100)
    DCUO.AmbientMusic.Config.Volume = volume
    
    -- Volume pour son local
    if IsValid(currentSound) then
        currentSound:SetVolume(volume / 100)
        DCUO.Log("Local ambient music volume set to: " .. volume, "INFO")
    end
    
    -- Volume pour YouTube
    if IsValid(musicPanel) then
        musicPanel:Call("setVolume(" .. volume .. ")")
        DCUO.Log("YouTube ambient music volume set to: " .. volume, "INFO")
    end
end

-- Changer la vidéo YouTube
function DCUO.AmbientMusic.ChangeVideo(videoID)
    DCUO.AmbientMusic.Config.VideoID = videoID
    
    if IsValid(musicPanel) then
        musicPanel:Call("changeVideo('" .. videoID .. "')")
        DCUO.Log("Ambient music changed to: " .. videoID, "INFO")
    else
        DCUO.AmbientMusic.Start(videoID)
    end
end

-- Activer/Désactiver
function DCUO.AmbientMusic.Toggle()
    DCUO.AmbientMusic.Config.Enabled = not DCUO.AmbientMusic.Config.Enabled
    
    if DCUO.AmbientMusic.Config.Enabled then
        DCUO.AmbientMusic.Start()
        DCUO.Log("Ambient music enabled", "SUCCESS")
    else
        DCUO.AmbientMusic.Stop()
        DCUO.Log("Ambient music disabled", "INFO")
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    COMMANDES CONSOLE                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

concommand.Add("dcuo_ambient_music_start", function(ply, cmd, args)
    local videoID = args[1] or DCUO.AmbientMusic.Config.VideoID
    DCUO.AmbientMusic.Start(videoID)
end)

concommand.Add("dcuo_ambient_music_stop", function(ply, cmd, args)
    DCUO.AmbientMusic.Stop()
end)

concommand.Add("dcuo_ambient_music_volume", function(ply, cmd, args)
    local volume = tonumber(args[1]) or 30
    DCUO.AmbientMusic.SetVolume(volume)
end)

concommand.Add("dcuo_ambient_music_toggle", function(ply, cmd, args)
    DCUO.AmbientMusic.Toggle()
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    AUTO-START                                     ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Démarrer la musique d'ambiance après un court délai
hook.Add("InitPostEntity", "DCUO:StartAmbientMusic", function()
    timer.Simple(3, function()
        if DCUO.AmbientMusic.Config.Enabled then
            -- Utiliser les sons locaux si activé
            if DCUO.AmbientMusic.Config.UseLocalSounds then
                -- Liste des musiques d'ambiance disponibles
                local ambientTracks = {
                    "dcuo/ambient/metropolis.mp3",
                    "dcuo/ambient/gotham.mp3",
                    "dcuo/ambient/atlantis.mp3",
                }
                
                -- Choisir une piste aléatoire
                local track = table.Random(ambientTracks)
                DCUO.AmbientMusic.Play(track, 0.3)  -- Volume 30%
                print("[DCUO] Musique d'ambiance démarrée: " .. track)
            else
                DCUO.AmbientMusic.Start()
            end
            
            DCUO.Log("Ambient music auto-started", "SUCCESS")
        end
    end)
end)

-- Redémarrer après changement de map
hook.Add("OnReloaded", "DCUO:RestartAmbientMusic", function()
    if DCUO.AmbientMusic.Config.Enabled then
        if DCUO.AmbientMusic.Config.UseLocalSounds then
            local ambientTracks = {
                "dcuo/ambient/metropolis.mp3",
                "dcuo/ambient/gotham.mp3",
                "dcuo/ambient/atlantis.mp3",
            }
            local track = table.Random(ambientTracks)
            DCUO.AmbientMusic.Play(track, 0.3)
        else
            DCUO.AmbientMusic.Start()
        end
    end
end)

DCUO.Log("Ambient music system loaded", "SUCCESS")

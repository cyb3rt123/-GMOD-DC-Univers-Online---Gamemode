--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Musique de Map Automatique
    Détecte la map et joue la musique appropriée
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

-- Attendre que le joueur soit complètement spawné
hook.Add("InitPostEntity", "DCUO:AutoMusic", function()
    timer.Simple(2, function()
        local mapName = string.lower(game.GetMap())
        
        print("[DCUO Music] Current map: " .. mapName)
        
        -- Détecter la map et jouer la musique appropriée
        if string.find(mapName, "gotham") or string.find(mapName, "batman") then
            print("[DCUO Music] Playing Gotham theme")
            if DCUO.AmbientMusic and DCUO.AmbientMusic.Play then
                DCUO.AmbientMusic.Play("dcuo/ambient/gotham.mp3")
            end
            
        elseif string.find(mapName, "metropolis") or string.find(mapName, "superman") then
            print("[DCUO Music] Playing Metropolis theme")
            if DCUO.AmbientMusic and DCUO.AmbientMusic.Play then
                DCUO.AmbientMusic.Play("dcuo/ambient/metropolis.mp3")
            end
            
        else
            -- Musique par défaut pour les autres maps
            print("[DCUO Music] Playing default combat theme")
            if DCUO.AmbientMusic and DCUO.AmbientMusic.Play then
                DCUO.AmbientMusic.Play("dcuo/ambient/combat.mp3")
            end
        end
    end)
end)

-- Commande pour tester la musique
concommand.Add("dcuo_test_music", function(ply, cmd, args)
    if not DCUO.AmbientMusic then
        print("[DCUO Music] System not loaded!")
        return
    end
    
    local track = args[1] or "dcuo/ambient/metropolis.mp3"
    print("[DCUO Music] Testing track: " .. track)
    DCUO.AmbientMusic.Play(track)
end)

concommand.Add("dcuo_stop_music", function()
    if DCUO.AmbientMusic and DCUO.AmbientMusic.Stop then
        DCUO.AmbientMusic.Stop()
        print("[DCUO Music] Music stopped")
    end
end)

concommand.Add("dcuo_music_volume", function(ply, cmd, args)
    local volume = tonumber(args[1]) or 0.3
    if DCUO.AmbientMusic and DCUO.AmbientMusic.SetVolume then
        DCUO.AmbientMusic.SetVolume(volume * 100)  -- Convertir 0-1 en 0-100
        print("[DCUO Music] Volume set to: " .. (volume * 100) .. "%")
    end
end)

-- Commande de diagnostic
concommand.Add("dcuo_music_diagnostic", function()
    print("=== DCUO MUSIC DIAGNOSTIC ===")
    print("")
    
    -- 1. Vérifier le système
    if DCUO.AmbientMusic then
        print("✓ DCUO.AmbientMusic loaded")
        print("  - Play:", DCUO.AmbientMusic.Play ~= nil)
        print("  - Stop:", DCUO.AmbientMusic.Stop ~= nil)
        print("  - SetVolume:", DCUO.AmbientMusic.SetVolume ~= nil)
        print("  - Config.Enabled:", DCUO.AmbientMusic.Config.Enabled)
        print("  - Config.Volume:", DCUO.AmbientMusic.Config.Volume)
    else
        print("✗ DCUO.AmbientMusic NOT loaded!")
    end
    
    print("")
    
    -- 2. Vérifier les fichiers
    print("Checking sound files:")
    local sounds = {
        "sound/dcuo/ambient/gotham.mp3",
        "sound/dcuo/ambient/metropolis.mp3",
        "sound/dcuo/ambient/combat.mp3"
    }
    
    local allPresent = true
    for _, path in ipairs(sounds) do
        local exists = file.Exists(path, "GAME")
        print("  " .. (exists and "✓" or "✗") .. " " .. path)
        if not exists then allPresent = false end
    end
    
    print("")
    
    -- 3. Vérifier les CVars
    print("GMod Sound Settings:")
    print("  snd_musicvolume:", GetConVar("snd_musicvolume"):GetFloat())
    print("  volume:", GetConVar("volume"):GetFloat())
    print("  snd_mixahead:", GetConVar("snd_mixahead"):GetFloat())
    
    print("")
    
    -- 4. Résumé
    if allPresent and DCUO.AmbientMusic and DCUO.AmbientMusic.Play then
        print("✓ SYSTEM READY - Try: lua_run_cl DCUO.AmbientMusic.Play('dcuo/ambient/metropolis.mp3', 0.5)")
        
        if GetConVar("snd_musicvolume"):GetFloat() < 0.1 then
            print("⚠ WARNING: snd_musicvolume is too low! Type: snd_musicvolume 1")
        end
    else
        print("✗ SYSTEM NOT READY")
        if not allPresent then
            print("  → Missing sound files! Resubscribe to Workshop addon")
        end
        if not DCUO.AmbientMusic or not DCUO.AmbientMusic.Play then
            print("  → Music system not loaded! Check console for Lua errors")
        end
    end
    
    print("")
    print("=== END DIAGNOSTIC ===")
end)

print("[DCUO Music] Auto-play system loaded")

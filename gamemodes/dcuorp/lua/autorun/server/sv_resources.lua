--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Ressources à Télécharger
    Fichiers que les clients doivent télécharger
═══════════════════════════════════════════════════════════════════════
--]]

if CLIENT then return end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    MUSIQUES D'AMBIANCE                            ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Les joueurs téléchargeront automatiquement ces fichiers en rejoignant
resource.AddFile("sound/dcuo/ambient/metropolis.mp3")
resource.AddFile("sound/dcuo/ambient/gotham.mp3")
resource.AddFile("sound/dcuo/ambient/combat.mp3")

-- Ajoutez vos nouvelles musiques ici :
-- resource.AddFile("sound/dcuo/ambient/votre_musique.mp3")

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    SONS UI                                        ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Si vous avez des sons UI custom
-- resource.AddFile("sound/dcuo/ui/button_click.wav")
-- resource.AddFile("sound/dcuo/ui/menu_open.wav")

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    MATERIALS (IMAGES/LOGOS)                       ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Logos et icônes
-- resource.AddFile("materials/dcuo/icons/job_batman.png")
-- resource.AddFile("materials/dcuo/icons/job_superman.png")
-- resource.AddFile("materials/dcuo/icons/power_flight.png")

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    MODELS                                         ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Si vous avez des models custom (pas HL2)
-- resource.AddFile("models/dcuo/batman.mdl")
-- resource.AddFile("models/dcuo/batman.vvd")
-- resource.AddFile("models/dcuo/batman.vtx")
-- resource.AddFile("models/dcuo/batman.phy")

print("[DCUO] Ressources enregistrées - Les clients téléchargeront les fichiers")

--[[
    ⚠️ IMPORTANT :
    
    1. Taille limite : ~150 MB total via resource.AddFile
    2. Si plus : utilisez FastDL (voir GUIDE_FASTDL.md)
    3. Format audio recommandé : MP3 128 kbps
    4. Compressez vos fichiers au maximum
    
    Téléchargement :
    - Le joueur voit "Downloading X files..." en rejoignant
    - Les fichiers sont cachés localement après le premier téléchargement
    - Rechargement uniquement si fichier modifié sur le serveur
--]]

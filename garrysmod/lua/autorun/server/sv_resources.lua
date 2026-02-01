--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Ressources Workshop
    
    ⚠️ CE FICHIER N'EST PLUS UTILISÉ !
    
    Les ressources sont maintenant gérées via Steam Workshop.
    Voir : config/sh_workshop.lua dans le gamemode
    
═══════════════════════════════════════════════════════════════════════
--]]

if CLIENT then return end

print("═══════════════════════════════════════════════════════════")
print("[DCUO-RP] ⚠️ sv_resources.lua est obsolète")
print("[DCUO-RP] Les ressources sont gérées par Steam Workshop")
print("[DCUO-RP] Voir : gamemodes/dcuorp/config/sh_workshop.lua")
print("═══════════════════════════════════════════════════════════")

-- NOTE : Ce fichier peut être supprimé après configuration du Workshop
-- Il est conservé uniquement comme fallback si Workshop ID = "0"

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

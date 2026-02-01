--[[
═══════════════════════════════════════════════════════════════════
    DCUO-RP - Configuration Workshop
═══════════════════════════════════════════════════════════════════
--]]

DCUO = DCUO or {}
DCUO.Workshop = {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    WORKSHOP ID                                    ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- IMPORTANT : Après avoir publié l'addon sur le Workshop avec gm_publish,
--             remplacez "0" par l'ID de votre addon Workshop

DCUO.Workshop.ContentID = "3657643635"  -- ID de votre Content Pack

-- SWEPs Workshop requis (remplacez par les vrais IDs)
DCUO.Workshop.SWEPs = {
    Flash = "0",        -- Flash Speedster (tfsr_speedster + tfsr_tranquilizer)
    Superman = "0",     -- Superman SWEP (weapon_superman)
    Shield = "0",       -- Shield Activator (weapon_shield_activator)
    Batman = "0",       -- Batman SWEP (sswep_batman)
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CONFIGURATION AUTO                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

if SERVER then
    -- Ajouter le Content Pack
    if DCUO.Workshop.ContentID ~= "0" then
        resource.AddWorkshop(DCUO.Workshop.ContentID)
        print("[DCUO-RP] Content Pack ajouté : " .. DCUO.Workshop.ContentID)
    else
        print("[DCUO-RP] ⚠ Content Pack non configuré!")
    end
    
    -- Ajouter les SWEPs Workshop
    local swepsAdded = 0
    for name, id in pairs(DCUO.Workshop.SWEPs) do
        if id ~= "0" then
            resource.AddWorkshop(id)
            print("[DCUO-RP] SWEP ajouté : " .. name .. " (" .. id .. ")")
            swepsAdded = swepsAdded + 1
        end
    end
    
    if swepsAdded == 0 then
        print("[DCUO-RP] ⚠ ATTENTION : Aucun SWEP Workshop configuré!")
        print("[DCUO-RP] Voir : WORKSHOP_SWEPS_REQUIS.txt")
    else
        print("[DCUO-RP] " .. swepsAdded .. " SWEPs Workshop configurés")
    end
    
    -- Fallback pour développement local
    if DCUO.Workshop.ContentID == "0" then
        print("[DCUO-RP] Mode développement : utilisation des fichiers locaux")
        local files = {
            "sound/dcuo/ambient/metropolis.mp3",
            "sound/dcuo/ambient/gotham.mp3",
            "sound/dcuo/ambient/combat.mp3"
        }
        for _, f in ipairs(files) do
            if file.Exists(f, "GAME") then
                resource.AddFile(f)
            end
        end
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    VÉRIFICATION CLIENT                            ║
-- ╚═══════════════════════════════════════════════════════════════════╝

if CLIENT then
    hook.Add("Initialize", "DCUO:CheckWorkshopContent", function()
        timer.Simple(5, function()
            local missingFiles = {}
            
            -- Vérifier les musiques
            local musicFiles = {
                "sound/dcuo/ambient/metropolis.mp3",
                "sound/dcuo/ambient/gotham.mp3",
                "sound/dcuo/ambient/combat.mp3"
            }
            
            for _, f in ipairs(musicFiles) do
                if not file.Exists(f, "GAME") then
                    table.insert(missingFiles, f)
                end
            end
            
            if #missingFiles > 0 then
                print("[DCUO-RP] ⚠ FICHIERS MANQUANTS :")
                for _, f in ipairs(missingFiles) do
                    print("  ✗ " .. f)
                end
                print("[DCUO-RP] Souscrivez à l'addon Workshop du serveur!")
            else
                print("[DCUO-RP] ✓ Tous les fichiers Workshop sont présents")
            end
        end)
    end)
end

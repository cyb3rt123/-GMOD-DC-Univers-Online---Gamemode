--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Configuration des Playermodels
    Définir les models pour chaque job
═══════════════════════════════════════════════════════════════════════
--]]

DCUO.Config = DCUO.Config or {}
DCUO.Config.Playermodels = DCUO.Config.Playermodels or {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    MODELS PAR JOB                                 ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- RECRUE (défaut)
DCUO.Config.Playermodels["Recrue"] = {
    "models/player/Group01/male_01.mdl",
    "models/player/Group01/male_02.mdl",
    "models/player/Group01/male_03.mdl",
    "models/player/Group01/male_04.mdl",
    "models/player/Group01/male_05.mdl",
    "models/player/Group01/male_06.mdl",
    "models/player/Group01/male_07.mdl",
    "models/player/Group01/male_08.mdl",
    "models/player/Group01/male_09.mdl",
    "models/player/Group01/female_01.mdl",
    "models/player/Group01/female_02.mdl",
    "models/player/Group01/female_03.mdl",
    "models/player/Group01/female_04.mdl",
    "models/player/Group01/female_05.mdl",
    "models/player/Group01/female_06.mdl",
}

-- FLASH
-- NOTE: Vous devrez ajouter vos propres models de super-héros
-- Ces chemins sont des exemples et doivent être remplacés par vos vrais addons
DCUO.Config.Playermodels["Flash"] = {
    "models/player/flash.mdl",  -- EXEMPLE - Remplacer par votre addon
}

-- BATMAN
DCUO.Config.Playermodels["Batman"] = {
    "models/player/bobert/aobm.mdl",
}

-- SUPERMAN
DCUO.Config.Playermodels["Superman"] = {
    "models/kryptonite/bvs_superman/inj_superman.mdl",
}

-- WONDER WOMAN
DCUO.Config.Playermodels["WonderWoman"] = {
    "models/player/wonderwoman.mdl",  -- EXEMPLE - Remplacer par votre addon
}

-- GREEN LANTERN
DCUO.Config.Playermodels["GreenLantern"] = {
    "models/player/greenlantern.mdl",  -- EXEMPLE - Remplacer par votre addon
}

-- JOKER
DCUO.Config.Playermodels["Joker"] = {
    "models/slow/arkham_cityum/jokcl/slow.mdl",
}

-- LEX LUTHOR
DCUO.Config.Playermodels["LexLuthor"] = {
    "models/player/lexluthor.mdl",  -- EXEMPLE - Remplacer par votre addon
}

-- HARLEY QUINN
DCUO.Config.Playermodels["Harley"] = {
    "models/player/harley.mdl",  -- EXEMPLE - Remplacer par votre addon
}

-- DEATHSTROKE
DCUO.Config.Playermodels["Deathstroke"] = {
    "models/player/deathstroke.mdl",  -- EXEMPLE - Remplacer par votre addon
}

-- DOOMSDAY (Boss jouable)
DCUO.Config.Playermodels["Doomsday"] = {
    "models/player/captainpawn/doomsday.mdl",
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    ARMS (VIEWMODELS DES MAINS)                    ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Arms par défaut GMod (utilisé si pas de arms spécifiques)
DCUO.Config.DefaultArms = "models/weapons/c_arms_citizen.mdl"

-- Arms personnalisés par job
DCUO.Config.JobArms = {}

-- Batman
DCUO.Config.JobArms["Batman"] = "models/weapons/aobm/aobm_arms.mdl"

-- Doomsday
DCUO.Config.JobArms["Doomsday"] = "models/weapons/c_doomsday_arms.mdl"

-- Joker - Utilise les bras par défaut GMod
DCUO.Config.JobArms["Joker"] = "models/weapons/c_arms_citizen.mdl"

-- Superman - Utilise les bras par défaut GMod
DCUO.Config.JobArms["Superman"] = "models/weapons/c_arms_citizen.mdl"

-- Flash - Utilise les bras par défaut GMod
DCUO.Config.JobArms["Flash"] = "models/weapons/c_arms_citizen.mdl"

-- Wonder Woman - Utilise les bras par défaut GMod
DCUO.Config.JobArms["WonderWoman"] = "models/weapons/c_arms_citizen.mdl"

-- Green Lantern - Utilise les bras par défaut GMod
DCUO.Config.JobArms["GreenLantern"] = "models/weapons/c_arms_citizen.mdl"

-- Lex Luthor - Utilise les bras par défaut GMod
DCUO.Config.JobArms["LexLuthor"] = "models/weapons/c_arms_citizen.mdl"

-- Harley Quinn - Utilise les bras par défaut GMod
DCUO.Config.JobArms["Harley"] = "models/weapons/c_arms_citizen.mdl"

-- Deathstroke - Utilise les bras par défaut GMod
DCUO.Config.JobArms["Deathstroke"] = "models/weapons/c_arms_citizen.mdl"

-- Recrue - Utilise les bras par défaut GMod
DCUO.Config.JobArms["Recrue"] = "models/weapons/c_arms_citizen.mdl"

--[[
═══════════════════════════════════════════════════════════════════════
    IMPORTANT: MODELS PAR DÉFAUT
    
    Les models ci-dessus sont des EXEMPLES et utilisent des chemins
    fictifs. Pour utiliser ce gamemode, vous devez:
    
    1. Installer des addons de playermodels DC Comics depuis le Workshop
    2. Remplacer les chemins ci-dessus par les vrais chemins
    3. Ou utiliser les models par défaut de GMod pour tester
    
    Exemples d'addons Workshop:
    - DC Comics Playermodels
    - Superhero Playermodels
    - Marvel & DC Pack
    
    Pour trouver le chemin d'un model:
    1. Spawner le model en jeu
    2. Regarder le model dans la console avec "getpos"
    3. Le chemin apparaîtra dans la console
═══════════════════════════════════════════════════════════════════════
--]]

-- Alternative: Utiliser les models par défaut de GMod pour tester
if not file.Exists("models/player/flash.mdl", "GAME") then
    DCUO.Log("WARNING: Custom playermodels not found, using default GMod models", "WARNING")
    
    -- Remplacer par des models GMod par défaut
    local defaultMales = {
        "models/player/Group01/male_01.mdl",
        "models/player/Group01/male_02.mdl",
        "models/player/Group01/male_03.mdl",
        "models/player/Group01/male_04.mdl",
        "models/player/Group01/male_05.mdl",
        "models/player/Group01/male_06.mdl",
        "models/player/Group01/male_07.mdl",
        "models/player/Group01/male_08.mdl",
        "models/player/Group01/male_09.mdl",
    }
    
    DCUO.Config.Playermodels["Flash"] = defaultMales
    DCUO.Config.Playermodels["Batman"] = defaultMales
    DCUO.Config.Playermodels["Superman"] = defaultMales
    DCUO.Config.Playermodels["WonderWoman"] = defaultMales
    DCUO.Config.Playermodels["GreenLantern"] = defaultMales
    DCUO.Config.Playermodels["Joker"] = defaultMales
    DCUO.Config.Playermodels["LexLuthor"] = defaultMales
    DCUO.Config.Playermodels["Harley"] = defaultMales
    DCUO.Config.Playermodels["Deathstroke"] = defaultMales
end

DCUO.Log("Playermodels config loaded", "SUCCESS")

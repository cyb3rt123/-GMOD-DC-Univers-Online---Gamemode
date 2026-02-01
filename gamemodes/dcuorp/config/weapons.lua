-- ██╗    ██╗███████╗ █████╗ ██████╗  ██████╗ ███╗   ██╗███████╗
-- ██║    ██║██╔════╝██╔══██╗██╔══██╗██╔═══██╗████╗  ██║██╔════╝
-- ██║ █╗ ██║█████╗  ███████║██████╔╝██║   ██║██╔██╗ ██║███████╗
-- ██║███╗██║██╔══╝  ██╔══██║██╔═══╝ ██║   ██║██║╚██╗██║╚════██║
-- ╚███╔███╔╝███████╗██║  ██║██║     ╚██████╔╝██║ ╚████║███████║
--  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═══╝╚══════╝
-- ATTRIBUTION DES ARMES PAR JOB
-- Ajoute les weapons[] à chaque job

-- Vérifier que DCUO.Jobs.List existe
if not DCUO.Jobs or not DCUO.Jobs.List then
    DCUO.Log("WARNING: Cannot load weapons config, DCUO.Jobs.List not initialized yet", "WARNING")
    return
end

-- Flash - Super vitesse + Éclair
DCUO.Jobs.List["Flash"].weapons = {
    "weapon_dcuo_lightning"
}

-- Superman - Vision thermique + Souffle glacial
DCUO.Jobs.List["Superman"].weapons = {
    "weapon_dcuo_heat_vision",
    "weapon_dcuo_freeze_breath"
}

-- Batman - Batarangs
DCUO.Jobs.List["Batman"].weapons = {
    "weapon_dcuo_batarang"
}

-- Wonder Woman - Lasso de la vérité
DCUO.Jobs.List["WonderWoman"].weapons = {
    "weapon_dcuo_lasso"
}

-- Green Lantern - Anneau
DCUO.Jobs.List["GreenLantern"].weapons = {
    "weapon_dcuo_green_lantern"
}

-- Joker - Batarangs (version Joker)
DCUO.Jobs.List["Joker"].weapons = {
    "weapon_dcuo_batarang"
}

-- Harley Quinn - Batarangs
DCUO.Jobs.List["Harley"].weapons = {
    "weapon_dcuo_batarang"
}

-- Lex Luthor - Anneau kryptonite (comme Green Lantern)
DCUO.Jobs.List["LexLuthor"].weapons = {
    "weapon_dcuo_green_lantern"
}

-- Deathstroke - Batarangs
DCUO.Jobs.List["Deathstroke"].weapons = {
    "weapon_dcuo_batarang"
}

-- Doomsday - Pas d'armes (combat au corps à corps)
DCUO.Jobs.List["Doomsday"].weapons = {}

DCUO.Log("Armes SWEP configurées pour tous les jobs")

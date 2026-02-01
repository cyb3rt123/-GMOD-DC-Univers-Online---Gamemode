--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Pouvoirs (Shared)
    Définition des super-pouvoirs avec SWEPs du Workshop
═══════════════════════════════════════════════════════════════════════
--]]

DCUO.Powers = DCUO.Powers or {}
DCUO.Powers.List = DCUO.Powers.List or {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║              CORRESPONDANCE POUVOIRS → SWEPs WORKSHOP             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Powers.WeaponMap = {
    -- SWEPs Workshop
    ["speedster"] = "tfsr_speedster",           -- Flash - Course rapide
    ["tranquilizer"] = "tfsr_tranquilizer",     -- Flash - Tranquilisant
    ["superman"] = "weapon_superman",            -- Superman
    ["shield"] = "dcuo_shield_wrapper",         -- Bouclier avec cooldown
    ["batman"] = "sswep_batman",                -- Batman
    
    -- SWEP Custom (Vol uniquement)
    ["flight"] = "dcuo_flight",                 -- Vol
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    DÉFINITION DES POUVOIRS                        ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    DÉFINITION DES POUVOIRS                        ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- ═══ VOL ═══
DCUO.Powers.List["flight"] = {
    id = "flight",
    name = "Vol",
    description = "Vous permet de voler dans les airs",
    cooldown = 0,
    duration = 0,
    color = Color(52, 152, 219),
}

-- ═══ FLASH - SPEEDSTER ═══
DCUO.Powers.List["speedster"] = {
    id = "speedster",
    name = "Super Vitesse",
    description = "Courez à une vitesse supersonique",
    cooldown = 0,
    duration = 0,
    color = Color(220, 20, 20),
}

-- ═══ FLASH - TRANQUILISANT ═══
DCUO.Powers.List["tranquilizer"] = {
    id = "tranquilizer",
    name = "Tranquilisant",
    description = "Endormez vos ennemis avec des fléchettes",
    cooldown = 5,
    duration = 0,
    color = Color(241, 196, 15),
}

-- ═══ SUPERMAN ═══
DCUO.Powers.List["superman"] = {
    id = "superman",
    name = "Pouvoirs de Superman",
    description = "Force surhumaine, vision laser, vol",
    cooldown = 0,
    duration = 0,
    color = Color(192, 57, 43),
}

-- ═══ BOUCLIER D'ÉNERGIE ═══
DCUO.Powers.List["shield"] = {
    id = "shield",
    name = "Bouclier d'Énergie",
    description = "Déploie un bouclier protecteur (10s max, 1min cooldown)",
    cooldown = 60,
    duration = 10,
    color = Color(155, 89, 182),
}

-- ═══ BATMAN ═══
DCUO.Powers.List["batman"] = {
    id = "batman",
    name = "Arsenal de Batman",
    description = "Gadgets et équipement tactique de Batman",
    cooldown = 0,
    duration = 0,
    color = Color(30, 30, 30),
}

-- ═══ VISION THERMIQUE ═══
DCUO.Powers.List["heat_vision"] = {
    id = "heat_vision",
    name = "Vision Thermique",
    description = "Tirez des rayons de chaleur de vos yeux",
    cooldown = 8,
    duration = 0.5,
    key = MOUSE_LEFT,
    icon = "icon16/bomb.png",
    effect = "heat_beam",
    sound = "weapons/physcannon/energy_sing_explosion2.wav",
    damage = 50,
    range = 2000,
}

-- ═══ SOUFFLE GLACIAL ═══
DCUO.Powers.List["freeze_breath"] = {
    id = "freeze_breath",
    name = "Souffle Glacial",
    description = "Gelez vos ennemis",
    cooldown = 12,
    duration = 3,
    key = MOUSE_RIGHT,
    icon = "icon16/weather_snow.png",
    effect = "freeze_effect",
    sound = "ambient/wind/wind_rooftop1.wav",
    freezeDuration = 5,
}

-- ═══ SUPER FORCE ═══
DCUO.Powers.List["super_strength"] = {
    id = "super_strength",
    name = "Super Force",
    description = "Force surhumaine",
    cooldown = 15,
    duration = 10,
    key = KEY_F,
    icon = "icon16/user_red.png",
    effect = "strength_aura",
    sound = "physics/metal/metal_box_impact_hard3.wav",
    damageMultiplier = 3,
}

-- ═══ CONSTRUCTIONS D'ÉNERGIE ═══
DCUO.Powers.List["energy_construct"] = {
    id = "energy_construct",
    name = "Construction d'Énergie",
    description = "Créez des objets avec votre anneau",
    cooldown = 10,
    duration = 15,
    key = KEY_E,
    icon = "icon16/lightbulb.png",
    effect = "green_energy",
    sound = "buttons/button17.wav",
}

-- ═══ BOUCLIER D'ÉNERGIE ═══
DCUO.Powers.List["energy_shield"] = {
    id = "energy_shield",
    name = "Bouclier d'Énergie",
    description = "Protégez-vous avec un bouclier",
    cooldown = 20,
    duration = 8,
    key = KEY_Q,
    icon = "icon16/shield.png",
    effect = "shield_bubble",
    sound = "buttons/button15.wav",
    armorBonus = 100,
}

-- ═══ GRAPPIN ═══
DCUO.Powers.List["grappling_hook"] = {
    id = "grappling_hook",
    name = "Grappin",
    description = "Utilisez votre grappin pour vous déplacer",
    cooldown = 5,
    duration = 0.5,
    key = KEY_G,
    icon = "icon16/arrow_up.png",
    effect = "grapple_rope",
    sound = "weapons/357/357_reload1.wav",
    range = 1500,
}

-- ═══ BOMBE FUMIGÈNE ═══
DCUO.Powers.List["smoke_bomb"] = {
    id = "smoke_bomb",
    name = "Bombe Fumigène",
    description = "Disparaissez dans un nuage de fumée",
    cooldown = 15,
    duration = 5,
    key = KEY_R,
    icon = "icon16/weather_clouds.png",
    effect = "smoke_cloud",
    sound = "ambient/gas/steam2.wav",
    invisibility = true,
}

-- ═══ VISION DE DÉTECTIVE ═══
DCUO.Powers.List["detective_vision"] = {
    id = "detective_vision",
    name = "Vision de Détective",
    description = "Voyez à travers les murs",
    cooldown = 30,
    duration = 10,
    key = KEY_V,
    icon = "icon16/eye.png",
    effect = "detective_overlay",
    sound = "buttons/button14.wav",
}

-- ═══ PUNCH ÉCLAIR ═══
DCUO.Powers.List["speed_punch"] = {
    id = "speed_punch",
    name = "Punch Éclair",
    description = "Frappez à vitesse supersonique",
    cooldown = 8,
    duration = 0.3,
    key = MOUSE_LEFT,
    icon = "icon16/lightning.png",
    effect = "speed_impact",
    sound = "physics/flesh/flesh_impact_hard6.wav",
    damage = 40,
    hits = 5,
}

-- ═══ TORNADE ═══
DCUO.Powers.List["tornado"] = {
    id = "tornado",
    name = "Tornade",
    description = "Créez une tornade dévastatrice",
    cooldown = 20,
    duration = 8,
    key = KEY_T,
    icon = "icon16/weather_clouds_dark.png",
    effect = "tornado_vortex",
    sound = "ambient/wind/wind_rooftop1.wav",
    radius = 300,
    damage = 10,  -- Par seconde
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONCTIONS UTILITAIRES                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Powers.Get(powerID)
    return DCUO.Powers.List[powerID]
end

function DCUO.Powers.GetWeapon(powerID)
    return DCUO.Powers.WeaponMap[powerID]
end

function DCUO.Powers.GetAll()
    return DCUO.Powers.List
end

function DCUO.Powers.HasPower(ply, powerID)
    if not IsValid(ply) or not ply.DCUOData then return false end
    
    local job = DCUO.Jobs.Get(ply.DCUOData.job)
    if not job or not job.powers then return false end
    
    return table.HasValue(job.powers, powerID)
end

DCUO.Log("Powers system loaded (" .. table.Count(DCUO.Powers.List) .. " powers)", "SUCCESS")

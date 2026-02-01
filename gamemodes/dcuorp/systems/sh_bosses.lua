--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Boss (Shared)
    Définition des boss et configuration
═══════════════════════════════════════════════════════════════════════
--]]

DCUO.Bosses = DCUO.Bosses or {}
DCUO.Bosses.List = {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CONFIGURATION BOSS                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Bosses.Config = {
    SpawnInterval = 600,        -- Temps entre chaque spawn de boss (10 minutes)
    RewardRadius = 500,         -- Rayon pour recevoir XP
    HUDRadius = 800,            -- Rayon pour voir la barre de boss
    XPReward = 500,             -- XP de base pour tuer un boss
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    LISTE DES BOSS                                 ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Bosses.List["doomsday"] = {
    name = "Doomsday",
    description = "Le destructeur de mondes",
    model = "models/player/charple.mdl",
    health = 5000,
    level = 30,
    class = "npc_combine_s",
    weapon = "weapon_ar2",
    xpReward = 1000,
    color = Color(100, 0, 0),
    scale = 1.5,
}

DCUO.Bosses.List["darkseid"] = {
    name = "Darkseid",
    description = "Le tyran d'Apokolips",
    model = "models/player/police.mdl",
    health = 8000,
    level = 40,
    class = "npc_combine_s",
    weapon = "weapon_ar2",
    xpReward = 1500,
    color = Color(50, 50, 100),
    scale = 1.7,
}

DCUO.Bosses.List["brainiac"] = {
    name = "Brainiac",
    description = "L'intelligence artificielle maléfique",
    model = "models/player/skeleton.mdl",
    health = 6000,
    level = 25,
    class = "npc_metropolice",
    weapon = "weapon_stunstick",
    xpReward = 1200,
    color = Color(0, 255, 0),
    scale = 1.6,
}

DCUO.Bosses.List["sinestro"] = {
    name = "Sinestro",
    description = "Le porteur de l'anneau jaune",
    model = "models/player/combine_super_soldier.mdl",
    health = 4500,
    level = 20,
    class = "npc_combine_s",
    weapon = "weapon_smg1",
    xpReward = 900,
    color = Color(255, 255, 0),
    scale = 1.4,
}

DCUO.Bosses.List["ares"] = {
    name = "Ares",
    description = "Le Dieu de la Guerre",
    model = "models/player/zombie_soldier.mdl",
    health = 7000,
    level = 35,
    class = "npc_combine_s",
    weapon = "weapon_ar2",
    xpReward = 1300,
    color = Color(150, 0, 0),
    scale = 1.8,
}

DCUO.Log("Boss definitions loaded - " .. table.Count(DCUO.Bosses.List) .. " boss types", "SUCCESS")

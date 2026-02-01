--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système d'Auras (Shared)
    Auras achetables avec effets visuels natifs GMod
═══════════════════════════════════════════════════════════════════════
--]]

DCUO.Auras = DCUO.Auras or {}
DCUO.Auras.List = {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    LISTE DES AURAS                                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Aura par défaut (aucune)
DCUO.Auras.List["none"] = {
    name = "Aucune Aura",
    description = "Pas d'effet visuel",
    cost = 0,
    level = 1,
    effect = "none",
    color = Color(255, 255, 255),
}

-- ⚡ AURAS ÉLECTRIQUES
DCUO.Auras.List["electric_blue"] = {
    name = "Foudre Bleue",
    description = "Éclairs électriques bleus crépitant autour de vous",
    cost = 500,
    level = 5,
    effect = "electric",
    color = Color(50, 150, 255),
    particle = "electrical_arc_01",
}

DCUO.Auras.List["electric_yellow"] = {
    name = "Foudre Dorée",
    description = "Éclairs dorés digne de Zeus",
    cost = 1000,
    level = 10,
    effect = "electric",
    color = Color(255, 215, 0),
    particle = "electrical_arc_01",
}

DCUO.Auras.List["electric_red"] = {
    name = "Foudre Écarlate",
    description = "Éclairs rouges de puissance brute",
    cost = 1500,
    level = 15,
    effect = "electric",
    color = Color(255, 50, 50),
    particle = "electrical_arc_01",
}

-- 🔥 AURAS DE FEU
DCUO.Auras.List["fire_orange"] = {
    name = "Flammes Ardentes",
    description = "Flammes oranges dansant autour de vous",
    cost = 750,
    level = 7,
    effect = "fire",
    color = Color(255, 150, 0),
    particle = "fire_small_01",
}

DCUO.Auras.List["fire_blue"] = {
    name = "Flammes Mystiques",
    description = "Flammes bleues froides et mystérieuses",
    cost = 1200,
    level = 12,
    effect = "fire",
    color = Color(100, 150, 255),
    particle = "fire_small_01",
}

DCUO.Auras.List["fire_green"] = {
    name = "Flammes Toxiques",
    description = "Flammes vertes toxiques",
    cost = 1800,
    level = 18,
    effect = "fire",
    color = Color(50, 255, 50),
    particle = "fire_small_01",
}

-- 💨 AURAS D'ÉNERGIE
DCUO.Auras.List["energy_white"] = {
    name = "Aura Divine",
    description = "Lueur blanche pure et divine",
    cost = 1000,
    level = 10,
    effect = "glow",
    color = Color(255, 255, 255),
    brightness = 3,
}

DCUO.Auras.List["energy_purple"] = {
    name = "Aura Cosmique",
    description = "Énergie violette cosmique",
    cost = 1500,
    level = 15,
    effect = "glow",
    color = Color(150, 50, 255),
    brightness = 4,
}

DCUO.Auras.List["energy_cyan"] = {
    name = "Aura Glaciale",
    description = "Énergie cyan glacée",
    cost = 1300,
    level = 13,
    effect = "glow",
    color = Color(0, 255, 255),
    brightness = 3,
}

-- ✨ AURAS DE PARTICULES
DCUO.Auras.List["sparkles_gold"] = {
    name = "Étincelles Dorées",
    description = "Particules dorées scintillantes",
    cost = 2000,
    level = 20,
    effect = "sparkles",
    color = Color(255, 215, 0),
    particle = "golden_sparkles",
}

DCUO.Auras.List["sparkles_rainbow"] = {
    name = "Étincelles Arc-en-ciel",
    description = "Particules multicolores magiques",
    cost = 3000,
    level = 25,
    effect = "sparkles",
    color = Color(255, 100, 255),
    particle = "rainbow_sparkles",
}

-- 💀 AURAS SOMBRES
DCUO.Auras.List["dark_smoke"] = {
    name = "Fumée Noire",
    description = "Fumée sombre et menaçante",
    cost = 800,
    level = 8,
    effect = "smoke",
    color = Color(50, 50, 50),
    particle = "smoke_01",
}

DCUO.Auras.List["dark_purple"] = {
    name = "Ténèbres Pourpres",
    description = "Énergie sombre violette",
    cost = 1600,
    level = 16,
    effect = "glow",
    color = Color(100, 0, 100),
    brightness = 2,
}

-- 🌟 AURAS LÉGENDAIRES
DCUO.Auras.List["legendary_hero"] = {
    name = "Aura du Héros Légendaire",
    description = "Aura dorée brillante des héros de légende",
    cost = 5000,
    level = 30,
    effect = "legendary",
    color = Color(255, 215, 0),
    particle = "golden_burst",
    brightness = 5,
}

DCUO.Auras.List["legendary_villain"] = {
    name = "Aura du Vilain Légendaire",
    description = "Aura rouge sombre des vilains redoutés",
    cost = 5000,
    level = 30,
    effect = "legendary",
    color = Color(150, 0, 0),
    particle = "dark_burst",
    brightness = 5,
}

DCUO.Auras.List["legendary_cosmic"] = {
    name = "Aura Cosmique Ultime",
    description = "Énergie cosmique pure - réservé aux plus puissants",
    cost = 10000,
    level = 40,
    effect = "legendary",
    color = Color(100, 50, 255),
    particle = "cosmic_burst",
    brightness = 6,
}

-- 🎨 AURAS SPÉCIALES
DCUO.Auras.List["kryptonite_green"] = {
    name = "Radiation Kryptonite",
    description = "Lueur verte de kryptonite radioactive",
    cost = 2500,
    level = 22,
    effect = "glow",
    color = Color(0, 255, 0),
    brightness = 4,
}

DCUO.Auras.List["speed_force"] = {
    name = "Speed Force",
    description = "Éclairs jaunes de la Speed Force",
    cost = 3500,
    level = 28,
    effect = "electric",
    color = Color(255, 255, 0),
    particle = "electrical_arc_01",
}

DCUO.Auras.List["lantern_green"] = {
    name = "Volonté de Green Lantern",
    description = "Énergie verte de volonté",
    cost = 3000,
    level = 25,
    effect = "glow",
    color = Color(0, 255, 0),
    brightness = 5,
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONCTIONS UTILITAIRES                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Obtenir une aura par ID
function DCUO.Auras.Get(id)
    return DCUO.Auras.List[id]
end

-- Vérifier si un joueur peut acheter une aura
function DCUO.Auras.CanBuy(ply, auraId)
    if not IsValid(ply) or not ply.DCUOData then return false end
    
    local aura = DCUO.Auras.Get(auraId)
    if not aura then return false end
    
    -- Vérifier le niveau
    if ply.DCUOData.level < aura.level then
        return false, "Niveau " .. aura.level .. " requis"
    end
    
    -- Vérifier l'XP
    if ply.DCUOData.xp < aura.cost then
        return false, "Pas assez d'XP (" .. aura.cost .. " requis)"
    end
    
    -- Vérifier si déjà possédée
    if ply.DCUOData.auras and table.HasValue(ply.DCUOData.auras, auraId) then
        return false, "Vous possédez déjà cette aura"
    end
    
    return true
end

DCUO.Log("Auras system loaded - " .. table.Count(DCUO.Auras.List) .. " auras disponibles", "SUCCESS")

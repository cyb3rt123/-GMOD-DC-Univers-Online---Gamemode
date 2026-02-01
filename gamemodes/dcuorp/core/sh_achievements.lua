--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Succès (Shared)
    Définitions et données des succès
═══════════════════════════════════════════════════════════════════════
--]]

DCUO.Achievements = DCUO.Achievements or {}
DCUO.Achievements.List = {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CATÉGORIES DE SUCCÈS                           ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Achievements.Categories = {
    {id = "progression", name = "Progression", icon = "★", color = Color(255, 215, 0)},
    {id = "combat", name = "Combat", icon = "⚔", color = Color(231, 76, 60)},
    {id = "exploration", name = "Exploration", icon = "🗺", color = Color(52, 152, 219)},
    {id = "social", name = "Social", icon = "👥", color = Color(46, 204, 113)},
    {id = "missions", name = "Missions", icon = "📋", color = Color(155, 89, 182)},
    {id = "collection", name = "Collection", icon = "💎", color = Color(241, 196, 15)},
    {id = "secret", name = "Secrets", icon = "🔐", color = Color(149, 165, 166)},
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    DÉFINITION DES SUCCÈS                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- PROGRESSION
table.insert(DCUO.Achievements.List, {
    id = "level_10",
    category = "progression",
    name = "Héros en Devenir",
    description = "Atteindre le niveau 10",
    icon = "🌟",
    points = 10,
    reward = {xp = 500},
    requirement = {type = "level", value = 10},
})

table.insert(DCUO.Achievements.List, {
    id = "level_25",
    category = "progression",
    name = "Défenseur Aguerri",
    description = "Atteindre le niveau 25",
    icon = "⭐",
    points = 25,
    reward = {xp = 1000},
    requirement = {type = "level", value = 25},
})

table.insert(DCUO.Achievements.List, {
    id = "level_50",
    category = "progression",
    name = "Champion Légendaire",
    description = "Atteindre le niveau 50",
    icon = "💫",
    points = 50,
    reward = {xp = 2500},
    requirement = {type = "level", value = 50},
})

-- COMBAT
table.insert(DCUO.Achievements.List, {
    id = "first_kill",
    category = "combat",
    name = "Premier Sang",
    description = "Éliminer votre premier adversaire",
    icon = "🗡",
    points = 5,
    reward = {xp = 100},
    requirement = {type = "kills", value = 1},
})

table.insert(DCUO.Achievements.List, {
    id = "kills_100",
    category = "combat",
    name = "Guerrier Redoutable",
    description = "Éliminer 100 adversaires",
    icon = "⚔",
    points = 25,
    reward = {xp = 1000},
    requirement = {type = "kills", value = 100},
})

table.insert(DCUO.Achievements.List, {
    id = "kills_500",
    category = "combat",
    name = "Légende Vivante",
    description = "Éliminer 500 adversaires",
    icon = "🏆",
    points = 50,
    reward = {xp = 5000},
    requirement = {type = "kills", value = 500},
})

table.insert(DCUO.Achievements.List, {
    id = "boss_first",
    category = "combat",
    name = "Tueur de Boss",
    description = "Vaincre votre premier boss",
    icon = "👹",
    points = 15,
    reward = {xp = 750},
    requirement = {type = "boss_kills", value = 1},
})

table.insert(DCUO.Achievements.List, {
    id = "boss_10",
    category = "combat",
    name = "Chasseur de Titans",
    description = "Vaincre 10 boss",
    icon = "🐉",
    points = 35,
    reward = {xp = 2000},
    requirement = {type = "boss_kills", value = 10},
})

-- SOCIAL
table.insert(DCUO.Achievements.List, {
    id = "create_guild",
    category = "social",
    name = "Fondateur",
    description = "Créer une guilde",
    icon = "🏛",
    points = 20,
    reward = {xp = 1000},
    requirement = {type = "create_guild", value = 1},
})

table.insert(DCUO.Achievements.List, {
    id = "join_guild",
    category = "social",
    name = "Membre Loyal",
    description = "Rejoindre une guilde",
    icon = "🤝",
    points = 10,
    reward = {xp = 500},
    requirement = {type = "join_guild", value = 1},
})

table.insert(DCUO.Achievements.List, {
    id = "friends_5",
    category = "social",
    name = "Populaire",
    description = "Avoir 5 amis",
    icon = "👥",
    points = 10,
    reward = {xp = 500},
    requirement = {type = "friends", value = 5},
})

table.insert(DCUO.Achievements.List, {
    id = "playtime_10h",
    category = "social",
    name = "Dévouement",
    description = "Jouer pendant 10 heures",
    icon = "⏰",
    points = 15,
    reward = {xp = 750},
    requirement = {type = "playtime", value = 36000}, -- 10h en secondes
})

-- MISSIONS
table.insert(DCUO.Achievements.List, {
    id = "mission_first",
    category = "missions",
    name = "Première Mission",
    description = "Compléter votre première mission",
    icon = "📝",
    points = 5,
    reward = {xp = 100},
    requirement = {type = "missions", value = 1},
})

table.insert(DCUO.Achievements.List, {
    id = "mission_25",
    category = "missions",
    name = "Enquêteur Dévoué",
    description = "Compléter 25 missions",
    icon = "📋",
    points = 20,
    reward = {xp = 1000},
    requirement = {type = "missions", value = 25},
})

table.insert(DCUO.Achievements.List, {
    id = "mission_100",
    category = "missions",
    name = "Maître des Missions",
    description = "Compléter 100 missions",
    icon = "📚",
    points = 50,
    reward = {xp = 5000},
    requirement = {type = "missions", value = 100},
})

-- COLLECTION
table.insert(DCUO.Achievements.List, {
    id = "aura_first",
    category = "collection",
    name = "Collectionneur d'Auras",
    description = "Débloquer votre première aura",
    icon = "✨",
    points = 10,
    reward = {xp = 500},
    requirement = {type = "auras", value = 1},
})

table.insert(DCUO.Achievements.List, {
    id = "aura_all",
    category = "collection",
    name = "Maître des Auras",
    description = "Débloquer toutes les auras",
    icon = "🌟",
    points = 75,
    reward = {xp = 10000},
    requirement = {type = "auras", value = 999}, -- À ajuster selon le nombre d'auras
})

-- SECRETS
table.insert(DCUO.Achievements.List, {
    id = "secret_death_100",
    category = "secret",
    name = "Immortel... ou Pas",
    description = "Mourir 100 fois",
    icon = "💀",
    points = 10,
    reward = {xp = 500},
    requirement = {type = "deaths", value = 100},
    hidden = true, -- Caché jusqu'à débloqué
})

table.insert(DCUO.Achievements.List, {
    id = "secret_fall",
    category = "secret",
    name = "Vol Raté",
    description = "Mourir de chute 50 fois",
    icon = "🪂",
    points = 15,
    reward = {xp = 750},
    requirement = {type = "fall_deaths", value = 50},
    hidden = true,
})

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONCTIONS UTILITAIRES                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Achievements.Get(achievementID)
    for _, achievement in ipairs(DCUO.Achievements.List) do
        if achievement.id == achievementID then
            return achievement
        end
    end
    return nil
end

function DCUO.Achievements.GetByCategory(categoryID)
    local achievements = {}
    for _, achievement in ipairs(DCUO.Achievements.List) do
        if achievement.category == categoryID then
            table.insert(achievements, achievement)
        end
    end
    return achievements
end

function DCUO.Achievements.GetCategory(categoryID)
    for _, category in ipairs(DCUO.Achievements.Categories) do
        if category.id == categoryID then
            return category
        end
    end
    return nil
end

function DCUO.Achievements.CountTotal()
    return #DCUO.Achievements.List
end

function DCUO.Achievements.CountByCategory(categoryID)
    local count = 0
    for _, achievement in ipairs(DCUO.Achievements.List) do
        if achievement.category == categoryID then
            count = count + 1
        end
    end
    return count
end

function DCUO.Achievements.GetTotalPoints()
    local total = 0
    for _, achievement in ipairs(DCUO.Achievements.List) do
        total = total + (achievement.points or 0)
    end
    return total
end

DCUO.Log("Achievements System (Shared) Loaded - " .. #DCUO.Achievements.List .. " achievements", "SUCCESS")

--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Missions (Shared)
    Définition des missions et événements
═══════════════════════════════════════════════════════════════════════
--]]

DCUO.Missions = DCUO.Missions or {}
DCUO.Missions.List = DCUO.Missions.List or {}
DCUO.Missions.Active = DCUO.Missions.Active or {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    TYPES DE MISSIONS                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Missions.Types = {
    KILL = "kill",              -- Tuer des ennemis
    COLLECT = "collect",        -- Collecter des objets
    RESCUE = "rescue",          -- Sauver des civils
    DEFEND = "defend",          -- Défendre une zone
    ESCORT = "escort",          -- Escorter un NPC
    BOSS = "boss",              -- Combattre un boss
    EXPLORE = "explore",        -- Explorer une zone
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    MISSIONS HÉROS                                 ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Missions.List["hero_rescue_civils"] = {
    id = "hero_rescue_civils",
    name = "Sauvetage de Civils",
    description = "Des civils sont en danger! Sauvez-les!",
    type = DCUO.Missions.Types.RESCUE,
    faction = {"Hero", "Neutral"},
    levelRequired = 1,
    minLevel = 1,
    maxPlayers = 4,
    rewards = {
        xp = 100,
        items = {},
    },
    xpReward = 100,
    objectives = {
        {
            type = "rescue",
            count = 5,
            current = 0,
            description = "Sauver 5 civils",
        }
    },
    spawnLocations = {
        -- Sera défini selon la map
    },
    duration = 600,  -- 10 minutes
}

DCUO.Missions.List["hero_stop_robbery"] = {
    id = "hero_stop_robbery",
    name = "Arrêter un Braquage",
    description = "Une banque est attaquée! Arrêtez les criminels!",
    type = DCUO.Missions.Types.KILL,
    faction = {"Hero"},
    levelRequired = 3,
    minLevel = 3,
    maxPlayers = 2,
    rewards = {
        xp = 150,
    },
    xpReward = 150,
    objectives = {
        {
            type = "kill",
            count = 10,
            current = 0,
            description = "Neutraliser 10 criminels",
            enemyClass = "npc_combine_s",
            enemyName = "Criminel",
        }
    },
    duration = 480,
}

DCUO.Missions.List["hero_alien_invasion"] = {
    id = "hero_alien_invasion",
    name = "Invasion Alien",
    description = "Des envahisseurs aliens attaquent la ville!",
    type = DCUO.Missions.Types.DEFEND,
    faction = {"Hero"},
    levelRequired = 10,
    minLevel = 10,
    maxPlayers = 8,
    rewards = {
        xp = 500,
    },
    xpReward = 500,
    objectives = {
        {
            type = "defend",
            count = 1,
            current = 0,
            description = "Défendre la zone pendant 5 minutes",
        },
        {
            type = "kill",
            count = 20,
            current = 0,
            description = "Éliminer 20 aliens",
            enemyClass = "npc_antlion",
            enemyName = "Alien Envahisseur",
        }
    },
    duration = 600,
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    MISSIONS VILAINS                               ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Missions.List["villain_robbery"] = {
    id = "villain_robbery",
    name = "Braquage de Banque",
    description = "Braquez la banque et volez l'argent!",
    type = DCUO.Missions.Types.COLLECT,
    faction = {"Villain"},
    minLevel = 1,
    maxPlayers = 4,
    rewards = {
        xp = 120,
    },
    objectives = {
        {
            type = "collect",
            count = 3,
            current = 0,
            description = "Voler 3 sacs d'argent",
            itemClass = "money_bag",
        }
    },
    duration = 600,
}

DCUO.Missions.List["villain_chaos"] = {
    id = "villain_chaos",
    name = "Semer le Chaos",
    description = "Détruisez tout sur votre passage!",
    type = DCUO.Missions.Types.KILL,
    faction = {"Villain"},
    levelRequired = 5,
    minLevel = 5,
    maxPlayers = 3,
    rewards = {
        xp = 200,
    },
    xpReward = 200,
    objectives = {
        {
            type = "kill",
            count = 15,
            current = 0,
            description = "Éliminer 15 forces de l'ordre",
            enemyClass = "npc_combine_s",
            enemyName = "Officier de Police",
        }
    },
    duration = 480,
}

DCUO.Missions.List["villain_weapon_steal"] = {
    id = "villain_weapon_steal",
    name = "Vol d'Armes Expérimentales",
    description = "Volez les armes du gouvernement!",
    type = DCUO.Missions.Types.COLLECT,
    faction = {"Villain"},
    levelRequired = 15,
    minLevel = 15,
    maxPlayers = 5,
    rewards = {
        xp = 600,
    },
    xpReward = 600,
    objectives = {
        {
            type = "collect",
            count = 5,
            current = 0,
            description = "Voler 5 armes expérimentales",
            itemClass = "experimental_weapon",
        },
        {
            type = "kill",
            count = 10,
            current = 0,
            description = "Éliminer 10 gardes",
            enemyClass = "npc_combine_s",
            enemyName = "Garde Armé",
        }
    },
    duration = 720,
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    MISSIONS NIVEAU MOYEN                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Missions.List["hero_patrol_city"] = {
    id = "hero_patrol_city",
    name = "Patrouille Urbaine",
    description = "Patrouiller la ville et neutraliser les menaces",
    type = DCUO.Missions.Types.KILL,
    faction = {"Hero"},
    levelRequired = 8,
    maxPlayers = 3,
    xpReward = 350,
    rewards = { xp = 350 },
    objectives = {
        {
            type = "kill",
            count = 12,
            current = 0,
            description = "Neutraliser 12 voyous",
            enemyClass = "npc_hoodie_male_02_e",
            enemyName = "Voyou",
        }
    },
    duration = 500,
}

DCUO.Missions.List["villain_smuggling"] = {
    id = "villain_smuggling",
    name = "Contrebande",
    description = "Escorter la marchandise illégale",
    type = DCUO.Missions.Types.ESCORT,
    faction = {"Villain"},
    levelRequired = 12,
    maxPlayers = 4,
    xpReward = 450,
    rewards = { xp = 450 },
    objectives = {
        {
            type = "escort",
            count = 1,
            current = 0,
            description = "Protéger le camion de contrebande",
        },
        {
            type = "kill",
            count = 8,
            current = 0,
            description = "Éliminer 8 policiers",
            enemyClass = "npc_combine_s",
            enemyName = "Policier",
        }
    },
    duration = 600,
}

DCUO.Missions.List["hero_hostage_rescue"] = {
    id = "hero_hostage_rescue",
    name = "Sauvetage d'Otages",
    description = "Des otages sont retenus! Libérez-les!",
    type = DCUO.Missions.Types.RESCUE,
    faction = {"Hero"},
    levelRequired = 18,
    maxPlayers = 5,
    xpReward = 800,
    rewards = { xp = 800 },
    objectives = {
        {
            type = "rescue",
            count = 8,
            current = 0,
            description = "Libérer 8 otages",
        },
        {
            type = "kill",
            count = 15,
            current = 0,
            description = "Neutraliser 15 preneurs d'otages",
            enemyClass = "npc_combine_s",
            enemyName = "Preneur d'Otage",
        }
    },
    duration = 750,
}

DCUO.Missions.List["villain_gang_war"] = {
    id = "villain_gang_war",
    name = "Guerre des Gangs",
    description = "Éliminez le gang rival!",
    type = DCUO.Missions.Types.KILL,
    faction = {"Villain"},
    levelRequired = 20,
    maxPlayers = 6,
    xpReward = 900,
    rewards = { xp = 900 },
    objectives = {
        {
            type = "kill",
            count = 25,
            current = 0,
            description = "Éliminer 25 membres du gang rival",
            enemyClass = "npc_combine_s",
            enemyName = "Membre de Gang",
        }
    },
    duration = 800,
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    BOSS BATTLES                                   ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Missions.List["boss_doomsday"] = {
    id = "boss_doomsday",
    name = "Arrêter Doomsday",
    description = "Doomsday détruit tout! Arrêtez-le!",
    type = DCUO.Missions.Types.BOSS,
    faction = {"Hero"},
    minLevel = 25,
    maxPlayers = 10,
    rewards = {
        xp = 2000,
    },
    objectives = {
        {
            type = "kill_boss",
            count = 1,
            current = 0,
            description = "Vaincre Doomsday",
            bossClass = "nmodels/player/captainpawn/doomsday.mdl",
        }
    },
    duration = 900,
}

DCUO.Missions.List["boss_darkseid"] = {
    id = "boss_darkseid",
    name = "L'Invasion de Darkseid",
    description = "Darkseid menace la Terre!",
    type = DCUO.Missions.Types.BOSS,
    faction = {"Hero", "Villain"},  -- Tous peuvent participer
    minLevel = 40,
    maxPlayers = 15,
    rewards = {
        xp = 5000,
    },
    objectives = {
        {
            type = "kill_boss",
            count = 1,
            current = 0,
            description = "Vaincre Darkseid",
            bossClass = "npc_strider",
        }
    },
    duration = 1200,
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONCTIONS MISSIONS                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Récupérer une mission
function DCUO.Missions.Get(missionID)
    return DCUO.Missions.List[missionID]
end

-- Récupérer toutes les missions
function DCUO.Missions.GetAll()
    return DCUO.Missions.List
end

-- Récupérer les missions pour une faction
function DCUO.Missions.GetByFaction(faction)
    local missions = {}
    
    for id, mission in pairs(DCUO.Missions.List) do
        if table.HasValue(mission.faction, faction) then
            missions[id] = mission
        end
    end
    
    return missions
end

-- Récupérer les missions disponibles pour un joueur
function DCUO.Missions.GetAvailable(ply)
    if not IsValid(ply) or not ply.DCUOData then return {} end
    
    local missions = {}
    local data = ply.DCUOData
    
    for id, mission in pairs(DCUO.Missions.List) do
        -- Vérifier la faction
        if table.HasValue(mission.faction, data.faction) then
            -- Vérifier le niveau
            if data.level >= mission.minLevel then
                -- Vérifier si déjà complétée
                if not table.HasValue(data.missions or {}, id) then
                    missions[id] = mission
                end
            end
        end
    end
    
    return missions
end

DCUO.Log("Missions system loaded (" .. table.Count(DCUO.Missions.List) .. " missions)", "SUCCESS")

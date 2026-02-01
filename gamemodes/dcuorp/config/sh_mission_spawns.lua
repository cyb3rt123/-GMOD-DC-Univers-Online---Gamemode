--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Configuration des Points de Spawn de Missions
    Définir les positions potentielles où les missions peuvent spawner
═══════════════════════════════════════════════════════════════════════
--]]

DCUO.Config = DCUO.Config or {}
DCUO.Config.MissionSpawns = DCUO.Config.MissionSpawns or {}

--[[
    Format des spawn points:
    {
        pos = Vector(x, y, z),          -- Position du spawn
        ang = Angle(pitch, yaw, roll),  -- Angle (optionnel)
        radius = 500,                    -- Rayon d'interaction (optionnel, par défaut 500)
        name = "Nom du point",          -- Nom descriptif (optionnel)
        types = {"combat", "collect"},  -- Types de missions autorisés (optionnel, par défaut tous)
    }
    
    Comment ajouter un point:
    1. Allez à l'emplacement souhaité en jeu
    2. Ouvrez le menu admin (F5)
    3. Cliquez sur "COPIER POSITION" dans l'onglet Missions
    4. Collez ici et formatez selon l'exemple ci-dessous
--]]

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    SPAWN POINTS - MÉTROPOLIS                      ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Config.MissionSpawns["metropolis_center"] = {
    pos = Vector(0, 0, 0),
    ang = Angle(0, 0, 0),
    radius = 600,
    name = "Centre de Métropolis",
    types = {"combat", "collect", "defend"},
}

DCUO.Config.MissionSpawns["metropolis_park"] = {
    pos = Vector(-3948.66, 10153.59, -178.03),
    ang = Angle(0, 90, 0),
    radius = 400,
    name = "Parc Central",
    types = {"collect", "escort"},
}

DCUO.Config.MissionSpawns["metropolis_docks"] = {
    pos = Vector(-1000, 0, 0),
    ang = Angle(0, 180, 0),
    radius = 800,
    name = "Docks de Métropolis",
    types = {"combat", "defend"},
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    SPAWN POINTS - GOTHAM                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Config.MissionSpawns["gotham_alley"] = {
    pos = Vector(1000, -1000, 0),
    ang = Angle(0, 270, 0),
    radius = 300,
    name = "Ruelle de Crime Alley",
    types = {"combat"},
}

DCUO.Config.MissionSpawns["gotham_rooftop"] = {
    pos = Vector(1500, -500, 500),
    ang = Angle(0, 0, 0),
    radius = 400,
    name = "Toits de Gotham",
    types = {"collect", "scout"},
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    SPAWN POINTS - ZONES NEUTRES                   ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Config.MissionSpawns["neutral_warehouse"] = {
    pos = Vector(-500, -500, 0),
    ang = Angle(0, 45, 0),
    radius = 500,
    name = "Entrepôt Abandonné",
    types = {"combat", "collect"},
}

DCUO.Config.MissionSpawns["neutral_bridge"] = {
    pos = Vector(0, 1000, 100),
    ang = Angle(0, 90, 0),
    radius = 350,
    name = "Pont Principal",
    types = {"defend", "escort"},
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONCTIONS UTILITAIRES                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Obtenir un spawn aléatoire selon le type de mission
function DCUO.Config.GetRandomSpawn(missionType)
    local validSpawns = {}
    
    for spawnID, spawn in pairs(DCUO.Config.MissionSpawns) do
        -- Si pas de types définis OU si le type de mission est dans la liste
        if not spawn.types or table.HasValue(spawn.types, missionType) then
            table.insert(validSpawns, spawn)
        end
    end
    
    if #validSpawns == 0 then
        -- Fallback: utiliser le premier spawn disponible
        for _, spawn in pairs(DCUO.Config.MissionSpawns) do
            return spawn
        end
        return nil
    end
    
    return table.Random(validSpawns)
end

-- Obtenir le spawn le plus proche d'une position
function DCUO.Config.GetClosestSpawn(pos, missionType)
    local closest = nil
    local closestDist = math.huge
    
    for spawnID, spawn in pairs(DCUO.Config.MissionSpawns) do
        if not spawn.types or not missionType or table.HasValue(spawn.types, missionType) then
            local dist = pos:Distance(spawn.pos)
            if dist < closestDist then
                closest = spawn
                closestDist = dist
            end
        end
    end
    
    return closest, closestDist
end

-- Obtenir tous les spawns
function DCUO.Config.GetAllSpawns()
    return DCUO.Config.MissionSpawns
end

DCUO.Log("Mission spawns config loaded (" .. table.Count(DCUO.Config.MissionSpawns) .. " points)", "SUCCESS")

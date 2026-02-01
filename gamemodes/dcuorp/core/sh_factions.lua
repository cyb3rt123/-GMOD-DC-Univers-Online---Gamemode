--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Factions
    Gestion des factions (Héros, Vilains, Neutres)
═══════════════════════════════════════════════════════════════════════
--]]

DCUO.Factions = DCUO.Factions or {}
DCUO.Factions.List = DCUO.Factions.List or {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    DÉFINITION DES FACTIONS                        ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Factions.List["Hero"] = {
    name = "Héros",
    description = "Protégez les innocents et combattez le mal",
    color = DCUO.Colors.Hero,
    icon = "icon16/star.png",
    spawnPoints = DCUO.Config.SpawnPoints.Hero or {},
}

DCUO.Factions.List["Villain"] = {
    name = "Vilain",
    description = "Semez le chaos et dominez le monde",
    color = DCUO.Colors.Villain,
    icon = "icon16/bomb.png",
    spawnPoints = DCUO.Config.SpawnPoints.Villain or {},
}

DCUO.Factions.List["Neutral"] = {
    name = "Neutre",
    description = "Suivez votre propre chemin",
    color = DCUO.Colors.Neutral,
    icon = "icon16/user.png",
    spawnPoints = DCUO.Config.SpawnPoints.Neutral or {},
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONCTIONS FACTIONS                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Récupérer une faction
function DCUO.Factions.Get(factionID)
    return DCUO.Factions.List[factionID]
end

-- Récupérer toutes les factions
function DCUO.Factions.GetAll()
    return DCUO.Factions.List
end

-- Vérifier si deux joueurs sont alliés
function DCUO.Factions.AreAllies(ply1, ply2)
    if not IsValid(ply1) or not IsValid(ply2) then return false end
    if not ply1.DCUOData or not ply2.DCUOData then return false end
    
    local faction1 = ply1.DCUOData.faction
    local faction2 = ply2.DCUOData.faction
    
    -- Les neutres ne sont alliés avec personne (sauf eux-mêmes)
    if faction1 == "Neutral" or faction2 == "Neutral" then
        return faction1 == faction2
    end
    
    -- Héros et vilains sont ennemis
    return faction1 == faction2
end

-- Vérifier si deux joueurs sont ennemis
function DCUO.Factions.AreEnemies(ply1, ply2)
    if not IsValid(ply1) or not IsValid(ply2) then return false end
    if not ply1.DCUOData or not ply2.DCUOData then return false end
    
    local faction1 = ply1.DCUOData.faction
    local faction2 = ply2.DCUOData.faction
    
    -- Les neutres ne sont pas automatiquement ennemis
    if faction1 == "Neutral" or faction2 == "Neutral" then
        return false
    end
    
    -- Héros vs Vilains
    return (faction1 == "Hero" and faction2 == "Villain") or
           (faction1 == "Villain" and faction2 == "Hero")
end

DCUO.Log("Factions system loaded", "SUCCESS")

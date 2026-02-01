--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Stamina (Shared)
    Stamina pour utiliser les pouvoirs
═══════════════════════════════════════════════════════════════════════
--]]

DCUO.Stamina = DCUO.Stamina or {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CONFIGURATION STAMINA                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Stamina.Config = {
    MaxStamina = 100,           -- Stamina maximum
    RegenRate = 5,              -- Stamina regénérée par seconde
    RegenDelay = 2,             -- Délai avant régénération après utilisation (secondes)
    
    -- Coûts des pouvoirs (sera dans sh_powers.lua aussi)
    PowerCosts = {
        flight = 0,             -- Vol passif
        super_speed = 0,        -- Vitesse passive
        heat_vision = 15,       -- Vision thermique
        freeze_breath = 10,     -- Souffle glacial
        super_strength = 20,    -- Force surhumaine
        invisibility = 25,      -- Invisibilité
        telekinesis = 15,       -- Télékinésie
        regeneration = 0,       -- Régénération passive
        electricity = 12,       -- Électricité
        shield = 30,            -- Bouclier
        teleportation = 35,     -- Téléportation
        mind_control = 40,      -- Contrôle mental
    }
}

DCUO.Log("Stamina system config loaded", "SUCCESS")

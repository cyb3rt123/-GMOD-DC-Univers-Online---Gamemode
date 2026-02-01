--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système d'Expérience (Shared)
    Gestion de l'XP et des niveaux
═══════════════════════════════════════════════════════════════════════
--]]

DCUO.XP = DCUO.XP or {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CALCUL D'XP                                    ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Calculer l'XP nécessaire pour atteindre un niveau
function DCUO.XP.CalculateXPNeeded(level)
    if level >= DCUO.Config.MaxLevel then
        return 999999999  -- Niveau max atteint
    end
    
    local baseXP = DCUO.Config.XP.BaseXP or 100
    local multiplier = DCUO.Config.XP.Multiplier or 1.5
    
    return math.floor(baseXP * math.pow(level, multiplier))
end

-- Calculer le pourcentage de progression
function DCUO.XP.GetProgressPercent(ply)
    if not IsValid(ply) or not ply.DCUOData then return 0 end
    
    local data = ply.DCUOData
    if data.level >= DCUO.Config.MaxLevel then
        return 100
    end
    
    local maxXP = data.maxXP or DCUO.XP.CalculateXPNeeded(data.level)
    if maxXP <= 0 then return 0 end
    
    return math.Clamp((data.xp / maxXP) * 100, 0, 100)
end

-- Calculer le niveau basé sur l'XP totale
function DCUO.XP.CalculateLevel(totalXP)
    local level = 1
    
    while level < DCUO.Config.MaxLevel do
        local xpNeeded = DCUO.XP.CalculateXPNeeded(level)
        if totalXP < xpNeeded then
            break
        end
        level = level + 1
    end
    
    return level
end

DCUO.Log("XP system (shared) loaded", "SUCCESS")

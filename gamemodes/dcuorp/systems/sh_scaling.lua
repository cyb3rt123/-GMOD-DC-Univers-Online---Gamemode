-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                       LEVEL SCALING SYSTEM                        ║
-- ║     Plus le niveau est élevé, plus vie et dégâts augmentent      ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Scaling = DCUO.Scaling or {}

-- Configuration du scaling
DCUO.Scaling.Config = {
    -- SANTÉ (Health)
    -- Formule : BaseHealth + (Level * HealthPerLevel)
    BaseHealth = 100,           -- HP de base au niveau 1
    HealthPerLevel = 5,         -- +5 HP par niveau (niveau 50 = 100 + 250 = 350 HP)
    MaxHealth = 400,            -- Limite maximum de santé
    
    -- DÉGÂTS (Damage)
    -- Formule : BaseDamage * (1 + (Level * DamageMultiplier))
    BaseDamageMultiplier = 1.0, -- Multiplicateur de base
    DamagePerLevel = 0.01,      -- +1% de dégâts par niveau (niveau 50 = +50%)
    MaxDamageBonus = 0.75,      -- Maximum +75% de dégâts
    
    -- RÉGÉNÉRATION
    -- Plus le niveau est élevé, plus la regen est rapide
    BaseRegenAmount = 5,        -- HP régénérés de base
    RegenPerLevel = 0.1,        -- +0.1 HP de regen par niveau
    
    -- STAMINA (optionnel)
    -- Plus de stamina aux niveaux élevés
    BaseStamina = 100,
    StaminaPerLevel = 1,        -- +1 stamina par niveau (niveau 50 = 150 stamina)
    MaxStamina = 200,
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     FONCTIONS DE CALCUL                           ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Calculer la santé maximum selon le niveau
function DCUO.Scaling.GetMaxHealth(level)
    level = math.Clamp(level or 1, 1, DCUO.Config.MaxLevel)
    
    local health = DCUO.Scaling.Config.BaseHealth + (level * DCUO.Scaling.Config.HealthPerLevel)
    return math.min(health, DCUO.Scaling.Config.MaxHealth)
end

-- Calculer le multiplicateur de dégâts selon le niveau
function DCUO.Scaling.GetDamageMultiplier(level)
    level = math.Clamp(level or 1, 1, DCUO.Config.MaxLevel)
    
    local bonus = level * DCUO.Scaling.Config.DamagePerLevel
    bonus = math.min(bonus, DCUO.Scaling.Config.MaxDamageBonus)
    
    return DCUO.Scaling.Config.BaseDamageMultiplier + bonus
end

-- Appliquer le scaling aux dégâts
function DCUO.Scaling.ScaleDamage(baseDamage, attackerLevel)
    attackerLevel = attackerLevel or 1
    local multiplier = DCUO.Scaling.GetDamageMultiplier(attackerLevel)
    
    return baseDamage * multiplier
end

-- Calculer la régénération selon le niveau
function DCUO.Scaling.GetRegenAmount(level)
    level = math.Clamp(level or 1, 1, DCUO.Config.MaxLevel)
    
    return DCUO.Scaling.Config.BaseRegenAmount + (level * DCUO.Scaling.Config.RegenPerLevel)
end

-- Calculer la stamina maximum selon le niveau
function DCUO.Scaling.GetMaxStamina(level)
    level = math.Clamp(level or 1, 1, DCUO.Config.MaxLevel)
    
    local stamina = DCUO.Scaling.Config.BaseStamina + (level * DCUO.Scaling.Config.StaminaPerLevel)
    return math.min(stamina, DCUO.Scaling.Config.MaxStamina)
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     FONCTIONS UTILITAIRES                         ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Afficher les stats d'un niveau
function DCUO.Scaling.GetLevelStats(level)
    return {
        Level = level,
        MaxHealth = DCUO.Scaling.GetMaxHealth(level),
        DamageMultiplier = DCUO.Scaling.GetDamageMultiplier(level),
        DamagePercent = math.Round(DCUO.Scaling.GetDamageMultiplier(level) * 100 - 100, 1),
        RegenAmount = math.Round(DCUO.Scaling.GetRegenAmount(level), 1),
        MaxStamina = DCUO.Scaling.GetMaxStamina(level),
    }
end

-- Exemples de progression (pour debug)
if SERVER then
    concommand.Add("dcuo_show_scaling", function(ply)
        if not ply:IsSuperAdmin() then return end
        
        print("\n=== DCUO SCALING PROGRESSION ===")
        for i = 1, DCUO.Config.MaxLevel, 5 do
            local stats = DCUO.Scaling.GetLevelStats(i)
            print(string.format(
                "Level %d: HP=%d, DMG=+%d%%, Regen=%.1f HP/2s, Stamina=%d",
                stats.Level,
                stats.MaxHealth,
                stats.DamagePercent,
                stats.RegenAmount,
                stats.MaxStamina
            ))
        end
        print("================================\n")
    end)
end

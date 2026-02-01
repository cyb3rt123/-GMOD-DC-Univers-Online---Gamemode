-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                   LEVEL SCALING SERVER LOGIC                      ║
-- ║           Applique le scaling lors du spawn et level up          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

if CLIENT then return end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     APPLIQUER LE SCALING                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Appliquer la santé selon le niveau
function DCUO.Scaling.ApplyHealthScaling(ply)
    if not IsValid(ply) then return end
    
    local level = ply:GetNWInt("DCUO_Level", 1)
    local maxHealth = DCUO.Scaling.GetMaxHealth(level)
    
    ply:SetMaxHealth(maxHealth)
    ply:SetHealth(maxHealth)
    
    DCUO.Log(string.format("%s health scaled to %d (Level %d)", ply:Nick(), maxHealth, level), "INFO")
end

-- Appliquer la stamina selon le niveau
function DCUO.Scaling.ApplyStaminaScaling(ply)
    if not IsValid(ply) then return end
    if not DCUO.Stamina then return end -- Si le système existe
    
    local level = ply:GetNWInt("DCUO_Level", 1)
    local maxStamina = DCUO.Scaling.GetMaxStamina(level)
    
    -- Mettre à jour la config locale du joueur
    ply.DCUO_MaxStamina = maxStamina
    ply:SetNWInt("DCUO_Stamina", maxStamina)
end

-- Appliquer tout le scaling
function DCUO.Scaling.ApplyScaling(ply)
    DCUO.Scaling.ApplyHealthScaling(ply)
    DCUO.Scaling.ApplyStaminaScaling(ply)
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                          HOOKS                                    ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Appliquer le scaling au spawn
hook.Add("PlayerSpawn", "DCUO_Scaling_OnSpawn", function(ply)
    timer.Simple(0.1, function()
        if IsValid(ply) then
            DCUO.Scaling.ApplyScaling(ply)
        end
    end)
end)

-- Appliquer le scaling au level up
hook.Add("DCUO_PlayerLevelUp", "DCUO_Scaling_OnLevelUp", function(ply, newLevel, oldLevel)
    DCUO.Scaling.ApplyScaling(ply)
    
    -- Notifier le joueur
    local stats = DCUO.Scaling.GetLevelStats(newLevel)
    DCUO.Notify(ply, string.format(
        "Nouveau niveau ! HP: %d | Dégâts: +%d%% | Stamina: %d",
        stats.MaxHealth,
        stats.DamagePercent,
        stats.MaxStamina
    ), DCUO.Colors.Success)
end)

-- Modifier les dégâts selon le niveau de l'attaquant
hook.Add("EntityTakeDamage", "DCUO_Scaling_Damage", function(target, dmginfo)
    local attacker = dmginfo:GetAttacker()
    
    -- Vérifier si l'attaquant est un joueur
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    
    -- Récupérer le niveau de l'attaquant
    local attackerLevel = attacker:GetNWInt("DCUO_Level", 1)
    
    -- Appliquer le scaling aux dégâts
    local baseDamage = dmginfo:GetDamage()
    local scaledDamage = DCUO.Scaling.ScaleDamage(baseDamage, attackerLevel)
    
    dmginfo:SetDamage(scaledDamage)
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     RÉGÉNÉRATION SCALÉE                           ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Modifier la régénération selon le niveau (si le système existe)
if DCUO.Stamina then
    -- Remplacer le timer de regen standard par un scalé
    timer.Remove("DCUO_Stamina_HealthRegen") -- Supprimer l'ancien
    
    timer.Create("DCUO_Scaling_HealthRegen", 2, 0, function()
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:Alive() then
                -- Vérifier le délai de combat
                local lastDamage = ply.DCUO_LastDamageTaken or 0
                if CurTime() - lastDamage < 5 then continue end
                
                -- Calculer la regen selon le niveau
                local level = ply:GetNWInt("DCUO_Level", 1)
                local regenAmount = DCUO.Scaling.GetRegenAmount(level)
                
                -- Appliquer la regen
                local currentHealth = ply:Health()
                local maxHealth = ply:GetMaxHealth()
                
                if currentHealth < maxHealth then
                    ply:SetHealth(math.min(currentHealth + regenAmount, maxHealth))
                end
            end
        end
    end)
end

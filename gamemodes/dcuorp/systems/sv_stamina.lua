--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Stamina (Serveur)
    Gestion stamina et régénération
═══════════════════════════════════════════════════════════════════════
--]]

if CLIENT then return end

DCUO.Stamina = DCUO.Stamina or {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    INITIALISER STAMINA                            ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Stamina.Initialize(ply)
    if not IsValid(ply) then return end
    
    ply:SetNWInt("DCUO_Stamina", DCUO.Stamina.Config.MaxStamina)
    ply:SetNWInt("DCUO_MaxStamina", DCUO.Stamina.Config.MaxStamina)
    ply.LastStaminaUse = 0
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    UTILISER STAMINA                               ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Stamina.Use(ply, amount)
    if not IsValid(ply) then return false end
    
    local current = ply:GetNWInt("DCUO_Stamina", 0)
    
    if current < amount then
        return false -- Pas assez de stamina
    end
    
    ply:SetNWInt("DCUO_Stamina", math.max(0, current - amount))
    ply.LastStaminaUse = CurTime()
    
    return true
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    VÉRIFIER STAMINA                               ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Stamina.Has(ply, amount)
    if not IsValid(ply) then return false end
    return ply:GetNWInt("DCUO_Stamina", 0) >= amount
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    RÉGÉNÉRATION STAMINA                           ║
-- ╚═══════════════════════════════════════════════════════════════════╝

timer.Create("DCUO_StaminaRegen", 0.5, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() then
            local current = ply:GetNWInt("DCUO_Stamina", 0)
            local max = ply:GetNWInt("DCUO_MaxStamina", DCUO.Stamina.Config.MaxStamina)
            
            -- Vérifier délai de régénération
            if current < max then
                local lastUse = ply.LastStaminaUse or 0
                if CurTime() - lastUse >= DCUO.Stamina.Config.RegenDelay then
                    -- Régénérer
                    local regenAmount = DCUO.Stamina.Config.RegenRate * 0.5 -- 0.5s tick
                    ply:SetNWInt("DCUO_Stamina", math.min(max, current + regenAmount))
                end
            end
        end
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    RÉGÉNÉRATION SANTÉ                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

timer.Create("DCUO_HealthRegen", 2, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() then
            local health = ply:Health()
            local maxHealth = ply:GetMaxHealth()
            
            -- Régénérer si pas en combat
            local lastDamage = ply.DCUO_LastDamageTaken or 0
            if health < maxHealth and CurTime() - lastDamage > 5 then
                ply:SetHealth(math.min(maxHealth, health + 5))
            end
        end
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    HOOKS                                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("PlayerSpawn", "DCUO:InitStamina", function(ply)
    timer.Simple(0.1, function()
        if IsValid(ply) then
            DCUO.Stamina.Initialize(ply)
        end
    end)
end)

hook.Add("EntityTakeDamage", "DCUO:TrackDamage", function(target, dmg)
    if target:IsPlayer() then
        target.DCUO_LastDamageTaken = CurTime()
    end
end)

DCUO.Log("Stamina server system loaded", "SUCCESS")

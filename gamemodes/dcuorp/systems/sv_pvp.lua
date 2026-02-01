--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système PvP
    Règles de combat entre joueurs
═══════════════════════════════════════════════════════════════════════
--]]

if CLIENT then return end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    RÈGLES PVP                                     ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("PlayerShouldTakeDamage", "DCUO:PvPRules", function(target, attacker)
    -- Si ce n'est pas un joueur qui attaque, autoriser
    if not IsValid(attacker) or not attacker:IsPlayer() then
        return true
    end
    
    -- Si la cible n'est pas un joueur, autoriser
    if not IsValid(target) or not target:IsPlayer() then
        return true
    end
    
    -- Si même faction = Héros, bloquer
    if attacker.DCUOData and target.DCUOData then
        local attackerFaction = attacker.DCUOData.faction
        local targetFaction = target.DCUOData.faction
        
        -- Héros ne peuvent pas s'attaquer entre eux
        if attackerFaction == "Hero" and targetFaction == "Hero" then
            if math.random(1, 30) == 1 then -- Message occasionnel pour éviter spam
                DCUO.Notify(attacker, "Vous ne pouvez pas attaquer un autre héros !", DCUO.Colors.Error)
            end
            return false
        end
        
        -- Vilains peuvent s'attaquer entre eux (compétition)
        -- Héros vs Vilains : autorisé
        -- Neutres : peuvent attaquer et être attaqués
    end
    
    return true
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    PROTECTION SPAWN                               ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("PlayerSpawn", "DCUO:SpawnProtection", function(ply)
    -- Protection de 5 secondes au spawn
    ply.SpawnProtection = true
    
    timer.Simple(5, function()
        if IsValid(ply) then
            ply.SpawnProtection = false
        end
    end)
end)

hook.Add("EntityTakeDamage", "DCUO:SpawnProtectionCheck", function(target, dmg)
    if target:IsPlayer() and target.SpawnProtection then
        -- Annuler dégâts pendant protection
        dmg:ScaleDamage(0)
        return true
    end
end)

DCUO.Log("PvP rules system loaded", "SUCCESS")

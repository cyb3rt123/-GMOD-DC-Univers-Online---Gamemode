--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Pouvoirs (Server)
    Gestion serveur des pouvoirs et cooldowns
═══════════════════════════════════════════════════════════════════════
--]]

if CLIENT then return end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    ACTIVER UN POUVOIR                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Powers.Activate(ply, powerID)
    if not IsValid(ply) then return false end
    
    local power = DCUO.Powers.Get(powerID)
    if not power then
        DCUO.Log("Power " .. powerID .. " not found", "ERROR")
        return false
    end
    
    -- Vérifier si le joueur a ce pouvoir
    if not DCUO.Powers.HasPower(ply, powerID) then
        DCUO.Notify(ply, "Vous n'avez pas ce pouvoir", DCUO.Colors.Error)
        return false
    end
    
    -- Vérifier la stamina (si le système existe)
    if DCUO.Stamina and DCUO.Stamina.Config.PowerCosts[powerID] then
        local staminaCost = DCUO.Stamina.Config.PowerCosts[powerID]
        if not DCUO.Stamina.Has(ply, staminaCost) then
            DCUO.Notify(ply, "Stamina insuffisante !", DCUO.Colors.Warning)
            return false
        end
    end
    
    -- Vérifier le cooldown
    ply.DCUOCooldowns = ply.DCUOCooldowns or {}
    if ply.DCUOCooldowns[powerID] and ply.DCUOCooldowns[powerID] > CurTime() then
        local remaining = math.ceil(ply.DCUOCooldowns[powerID] - CurTime())
        DCUO.Notify(ply, string.format(DCUO.Config.Messages.PowerCooldown, remaining), DCUO.Colors.Warning)
        return false
    end
    
    -- Activer le pouvoir selon son type
    local success = false
    
    if powerID == "flight" then
        success = DCUO.Powers.ActivateFlight(ply)
    elseif powerID == "super_speed" then
        success = DCUO.Powers.ActivateSuperSpeed(ply, power)
    elseif powerID == "heat_vision" then
        success = DCUO.Powers.ActivateHeatVision(ply, power)
    elseif powerID == "freeze_breath" then
        success = DCUO.Powers.ActivateFreezeBreath(ply, power)
    elseif powerID == "super_strength" then
        success = DCUO.Powers.ActivateSuperStrength(ply, power)
    elseif powerID == "energy_shield" then
        success = DCUO.Powers.ActivateEnergyShield(ply, power)
    elseif powerID == "grappling_hook" then
        success = DCUO.Powers.ActivateGrapplingHook(ply, power)
    elseif powerID == "smoke_bomb" then
        success = DCUO.Powers.ActivateSmokeBomb(ply, power)
    elseif powerID == "speed_punch" then
        success = DCUO.Powers.ActivateSpeedPunch(ply, power)
    elseif powerID == "tornado" then
        success = DCUO.Powers.ActivateTornado(ply, power)
    else
        -- Pouvoir générique
        success = true
    end
    
    if success then
        -- Consommer la stamina (si le système existe)
        if DCUO.Stamina and DCUO.Stamina.Config.PowerCosts[powerID] then
            DCUO.Stamina.Use(ply, DCUO.Stamina.Config.PowerCosts[powerID])
        end
        
        -- Appliquer le cooldown
        ply.DCUOCooldowns[powerID] = CurTime() + power.cooldown
        
        -- Son
        if power.sound then
            ply:EmitSound(power.sound, 75, 100, 1, CHAN_AUTO)
        end
        
        -- Effet visuel
        if power.effect then
            local effectdata = EffectData()
            effectdata:SetOrigin(ply:GetPos())
            effectdata:SetEntity(ply)
            util.Effect(power.effect, effectdata, true, true)
        end
        
        -- Notification
        DCUO.Notify(ply, "Pouvoir activé: " .. power.name, DCUO.Colors.Success)
        
        return true
    end
    
    return false
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    POUVOIRS SPÉCIFIQUES                           ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Vol
function DCUO.Powers.ActivateFlight(ply)
    if ply.DCUOFlying then
        -- Désactiver le vol
        ply.DCUOFlying = false
        ply:SetMoveType(MOVETYPE_WALK)
        ply:SetGravity(1)
        return true
    else
        -- Activer le vol
        ply.DCUOFlying = true
        ply:SetMoveType(MOVETYPE_FLY)
        ply:SetGravity(0)
        return true
    end
end

-- Super Vitesse
function DCUO.Powers.ActivateSuperSpeed(ply, power)
    local multiplier = power.speedMultiplier or 3
    local originalSpeed = ply:GetRunSpeed()
    
    ply:SetRunSpeed(originalSpeed * multiplier)
    ply:SetWalkSpeed(originalSpeed * multiplier)
    
    -- Restaurer après la durée
    timer.Simple(power.duration, function()
        if IsValid(ply) then
            local job = DCUO.Jobs.Get(ply.DCUOData.job)
            ply:SetRunSpeed(job.runSpeed or 250)
            ply:SetWalkSpeed(job.walkSpeed or 150)
            DCUO.Notify(ply, "Super vitesse terminée", DCUO.Colors.Warning)
        end
    end)
    
    return true
end

-- Vision Thermique
function DCUO.Powers.ActivateHeatVision(ply, power)
    local trace = ply:GetEyeTrace()
    
    if not trace.Hit then return false end
    
    local target = trace.Entity
    
    -- Effet laser
    local effectdata = EffectData()
    effectdata:SetStart(ply:GetShootPos())
    effectdata:SetOrigin(trace.HitPos)
    effectdata:SetEntity(ply)
    util.Effect("ToolTracer", effectdata)
    
    -- Dégâts
    if IsValid(target) then
        local dmginfo = DamageInfo()
        dmginfo:SetDamage(power.damage or 50)
        dmginfo:SetAttacker(ply)
        dmginfo:SetInflictor(ply)
        dmginfo:SetDamageType(DMG_BURN)
        target:TakeDamageInfo(dmginfo)
        
        -- Effet de feu
        if target:IsPlayer() or target:IsNPC() then
            target:Ignite(3)
        end
    end
    
    -- Explosion à l'impact
    local explode = ents.Create("env_explosion")
    explode:SetPos(trace.HitPos)
    explode:SetKeyValue("iMagnitude", "50")
    explode:Spawn()
    explode:Fire("Explode", 0, 0)
    
    return true
end

-- Souffle Glacial
function DCUO.Powers.ActivateFreezeBreath(ply, power)
    local trace = ply:GetEyeTrace()
    
    if not trace.Hit or not IsValid(trace.Entity) then return false end
    
    local target = trace.Entity
    
    if target:IsPlayer() or target:IsNPC() then
        -- Geler la cible
        target:SetMoveType(MOVETYPE_NONE)
        target:SetColor(Color(100, 100, 255, 255))
        
        -- Dégel après la durée
        timer.Simple(power.freezeDuration or 5, function()
            if IsValid(target) then
                target:SetMoveType(MOVETYPE_WALK)
                target:SetColor(Color(255, 255, 255, 255))
            end
        end)
    end
    
    return true
end

-- Super Force
function DCUO.Powers.ActivateSuperStrength(ply, power)
    ply.DCUOSuperStrength = true
    ply.DCUOStrengthMultiplier = power.damageMultiplier or 3
    
    -- Restaurer après la durée
    timer.Simple(power.duration, function()
        if IsValid(ply) then
            ply.DCUOSuperStrength = false
            ply.DCUOStrengthMultiplier = 1
            DCUO.Notify(ply, "Super force terminée", DCUO.Colors.Warning)
        end
    end)
    
    return true
end

-- Bouclier d'Énergie
function DCUO.Powers.ActivateEnergyShield(ply, power)
    local currentArmor = ply:Armor()
    ply:SetArmor(currentArmor + (power.armorBonus or 100))
    
    -- Restaurer après la durée
    timer.Simple(power.duration, function()
        if IsValid(ply) then
            ply:SetArmor(math.max(0, ply:Armor() - (power.armorBonus or 100)))
            DCUO.Notify(ply, "Bouclier désactivé", DCUO.Colors.Warning)
        end
    end)
    
    return true
end

-- Grappin
function DCUO.Powers.ActivateGrapplingHook(ply, power)
    local trace = ply:GetEyeTrace()
    
    if not trace.Hit or trace.HitPos:Distance(ply:GetPos()) > (power.range or 1500) then
        return false
    end
    
    -- Calculer la vélocité
    local direction = (trace.HitPos - ply:GetPos()):GetNormalized()
    ply:SetVelocity(direction * 1000)
    
    return true
end

-- Bombe Fumigène
function DCUO.Powers.ActivateSmokeBomb(ply, power)
    -- Effet de fumée
    local smoke = ents.Create("env_smokestack")
    if IsValid(smoke) then
        smoke:SetPos(ply:GetPos())
        smoke:SetKeyValue("InitialState", "1")
        smoke:SetKeyValue("BaseSpread", "10")
        smoke:SetKeyValue("SpreadSpeed", "10")
        smoke:SetKeyValue("Speed", "30")
        smoke:SetKeyValue("StartSize", "10")
        smoke:SetKeyValue("EndSize", "50")
        smoke:SetKeyValue("Rate", "15")
        smoke:SetKeyValue("JetLength", "100")
        smoke:Spawn()
        smoke:Fire("TurnOn", "", 0)
        smoke:Fire("Kill", "", power.duration)
    end
    
    -- Invisibilité
    if power.invisibility then
        ply:SetNoDraw(true)
        ply:SetNotSolid(true)
        
        timer.Simple(power.duration, function()
            if IsValid(ply) then
                ply:SetNoDraw(false)
                ply:SetNotSolid(false)
                DCUO.Notify(ply, "Invisibilité terminée", DCUO.Colors.Warning)
            end
        end)
    end
    
    return true
end

-- Punch Éclair
function DCUO.Powers.ActivateSpeedPunch(ply, power)
    local trace = ply:GetEyeTrace()
    
    if not trace.Hit or not IsValid(trace.Entity) then return false end
    
    local target = trace.Entity
    local hits = power.hits or 5
    local damage = power.damage or 40
    
    -- Série de coups rapides
    for i = 1, hits do
        timer.Simple(i * 0.05, function()
            if IsValid(target) and IsValid(ply) then
                local dmginfo = DamageInfo()
                dmginfo:SetDamage(damage / hits)
                dmginfo:SetAttacker(ply)
                dmginfo:SetInflictor(ply)
                dmginfo:SetDamageType(DMG_CLUB)
                target:TakeDamageInfo(dmginfo)
                
                -- Effet visuel
                local effectdata = EffectData()
                effectdata:SetOrigin(target:GetPos())
                util.Effect("ManhackSparks", effectdata)
            end
        end)
    end
    
    return true
end

-- Tornade
function DCUO.Powers.ActivateTornado(ply, power)
    local pos = ply:GetPos()
    local radius = power.radius or 300
    local damage = power.damage or 10
    local endTime = CurTime() + power.duration
    
    -- Créer une tornade qui inflige des dégâts dans le temps
    timer.Create("DCUO_Tornado_" .. ply:EntIndex(), 0.5, power.duration * 2, function()
        if not IsValid(ply) or CurTime() > endTime then return end
        
        for _, ent in ipairs(ents.FindInSphere(pos, radius)) do
            if (ent:IsPlayer() or ent:IsNPC()) and ent ~= ply then
                local dmginfo = DamageInfo()
                dmginfo:SetDamage(damage / 2)
                dmginfo:SetAttacker(ply)
                dmginfo:SetInflictor(ply)
                dmginfo:SetDamageType(DMG_BLAST)
                ent:TakeDamageInfo(dmginfo)
                
                -- Pousser l'entité
                local direction = (ent:GetPos() - pos):GetNormalized()
                direction.z = 1
                ent:SetVelocity(direction * 200)
            end
        end
    end)
    
    return true
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    HOOKS                                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Modifier les dégâts si super force active
hook.Add("EntityTakeDamage", "DCUO:SuperStrengthDamage", function(target, dmginfo)
    local attacker = dmginfo:GetAttacker()
    
    if IsValid(attacker) and attacker:IsPlayer() and attacker.DCUOSuperStrength then
        local multiplier = attacker.DCUOStrengthMultiplier or 1
        dmginfo:SetDamage(dmginfo:GetDamage() * multiplier)
    end
end)

-- Recevoir l'activation de pouvoir du client
net.Receive("DCUO:PowerActivate", function(len, ply)
    local powerID = net.ReadString()
    DCUO.Powers.Activate(ply, powerID)
end)

-- Recevoir l'équipement de pouvoir (nouveau système SWEP)
util.AddNetworkString("DCUO:PowerEquip")
util.AddNetworkString("DCUO:PowerUnequip")

net.Receive("DCUO:PowerEquip", function(len, ply)
    local powerID = net.ReadString()
    
    if not IsValid(ply) then return end
    
    local power = DCUO.Powers.Get(powerID)
    if not power then
        DCUO.Notify(ply, "Pouvoir invalide", DCUO.Colors.Error)
        return
    end
    
    -- Vérifier si le joueur a accès à ce pouvoir
    if not DCUO.Powers.HasPower(ply, powerID) then
        DCUO.Notify(ply, "Vous n'avez pas accès à ce pouvoir", DCUO.Colors.Error)
        return
    end
    
    -- Obtenir le SWEP correspondant
    local weaponClass = DCUO.Powers.WeaponMap[powerID]
    if not weaponClass then
        DCUO.Notify(ply, "Ce pouvoir n'est pas encore disponible", DCUO.Colors.Warning)
        return
    end
    
    -- Vérifier si le joueur a déjà ce SWEP
    if ply:HasWeapon(weaponClass) then
        DCUO.Notify(ply, "Vous avez déjà ce pouvoir équipé !", DCUO.Colors.Warning)
        return
    end
    
    -- Donner le SWEP
    ply:Give(weaponClass)
    ply:SelectWeapon(weaponClass)
    
    -- Enregistrer le pouvoir actif
    ply.DCUOData.power = powerID
    
    DCUO.Notify(ply, "Pouvoir équipé: " .. power.name, DCUO.Colors.Success)
    ply:EmitSound("items/ammopickup.wav", 75, 120)
    
    -- Synchroniser avec le client
    net.Start("DCUO:PlayerData")
    net.WriteTable(ply.DCUOData)
    net.Send(ply)
end)

net.Receive("DCUO:PowerUnequip", function(len, ply)
    local powerID = net.ReadString()
    
    if not IsValid(ply) then return end
    
    -- Obtenir le SWEP correspondant
    local weaponClass = DCUO.Powers.WeaponMap[powerID]
    if not weaponClass then return end
    
    -- Retirer le SWEP
    if ply:HasWeapon(weaponClass) then
        ply:StripWeapon(weaponClass)
        ply.DCUOData.power = nil
        
        DCUO.Notify(ply, "Pouvoir retiré", DCUO.Colors.Info)
        
        -- Synchroniser avec le client
        net.Start("DCUO:PlayerData")
        net.WriteTable(ply.DCUOData)
        net.Send(ply)
    end
end)

DCUO.Log("Powers system (server) loaded", "SUCCESS")

--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système d'Expérience (Server)
    Gestion serveur de l'XP et des niveaux
═══════════════════════════════════════════════════════════════════════
--]]

if CLIENT then return end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    DONNER DE L'XP                                 ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Donner de l'XP à un joueur
function DCUO.XP.Give(ply, amount, reason)
    if not IsValid(ply) or not ply.DCUOData then return end
    if amount <= 0 then return end
    
    local data = ply.DCUOData
    
    -- Ne pas donner d'XP si niveau max
    if data.level >= DCUO.Config.MaxLevel then
        DCUO.Notify(ply, "Vous avez atteint le niveau maximum!", DCUO.Colors.Warning)
        return
    end
    
    -- Ajouter l'XP
    local oldXP = data.xp
    local oldLevel = data.level
    data.xp = data.xp + amount
    
    -- Vérifier le level up
    local maxXP = data.maxXP or DCUO.XP.CalculateXPNeeded(data.level)
    local leveledUp = false
    
    while data.xp >= maxXP and data.level < DCUO.Config.MaxLevel do
        -- Level UP!
        data.xp = data.xp - maxXP
        data.level = data.level + 1
        maxXP = DCUO.XP.CalculateXPNeeded(data.level)
        data.maxXP = maxXP
        leveledUp = true
        
        DCUO.Log(ply:Nick() .. " leveled up to " .. data.level, "SUCCESS")
    end
    
    -- Mettre à jour maxXP
    data.maxXP = maxXP
    
    -- Sauvegarder
    DCUO.Database.SavePlayer(ply)
    
    -- Envoyer au client
    net.Start("DCUO:UpdateXP")
        net.WriteInt(data.xp, 32)
        net.WriteInt(data.maxXP, 32)
    net.Send(ply)
    
    -- Si level up, envoyer la notification
    if leveledUp then
        -- Mettre à jour le niveau réseau pour le scaling
        ply:SetNWInt("DCUO_Level", data.level)
        
        net.Start("DCUO:UpdateLevel")
            net.WriteInt(data.level, 16)
            net.WriteBool(true)
        net.Send(ply)
        
        -- Notification
        local message = string.format(DCUO.Config.Messages.LevelUp, data.level)
        DCUO.Notify(ply, message, DCUO.Colors.Success)
        DCUO.NotifyAll(ply:Nick() .. " a atteint le niveau " .. data.level .. " !", DCUO.Colors.XP)
        
        -- Effets visuels et sonores
        DCUO.XP.LevelUpEffects(ply)
        
        -- Hook pour d'autres systèmes (newLevel, oldLevel)
        hook.Run("DCUO:PlayerLevelUp", ply, data.level, oldLevel)
    else
        -- Simple notification d'XP gagnée
        local msg = "+ " .. amount .. " XP"
        if reason then
            msg = msg .. " (" .. reason .. ")"
        end
        DCUO.Notify(ply, msg, DCUO.Colors.XP)
    end
end

-- Retirer de l'XP à un joueur
function DCUO.XP.Take(ply, amount, reason)
    if not IsValid(ply) or not ply.DCUOData then return end
    if amount <= 0 then return end
    
    local data = ply.DCUOData
    data.xp = math.max(0, data.xp - amount)
    
    -- Sauvegarder
    DCUO.Database.SavePlayer(ply)
    
    -- Envoyer au client
    net.Start("DCUO:UpdateXP")
        net.WriteInt(data.xp, 32)
        net.WriteInt(data.maxXP, 32)
    net.Send(ply)
    
    -- Notification
    local msg = "- " .. amount .. " XP"
    if reason then
        msg = msg .. " (" .. reason .. ")"
    end
    DCUO.Notify(ply, msg, DCUO.Colors.Error)
end

-- Définir l'XP d'un joueur
function DCUO.XP.Set(ply, amount)
    if not IsValid(ply) or not ply.DCUOData then return end
    
    local data = ply.DCUOData
    local oldLevel = data.level
    
    -- Définir l'XP
    data.xp = math.max(0, amount)
    
    -- Recalculer le niveau
    local newLevel = DCUO.XP.CalculateLevel(data.xp)
    if newLevel ~= oldLevel then
        data.level = newLevel
        data.maxXP = DCUO.XP.CalculateXPNeeded(data.level)
        
        -- Level up effects si augmentation
        if newLevel > oldLevel then
            DCUO.XP.LevelUpEffects(ply)
        end
        
        -- Envoyer mise à jour niveau
        net.Start("DCUO:UpdateLevel")
            net.WriteInt(data.level, 16)
            net.WriteBool(newLevel > oldLevel)
        net.Send(ply)
    end
    
    -- Sauvegarder
    DCUO.Database.SavePlayer(ply)
    
    -- Envoyer au client
    net.Start("DCUO:UpdateXP")
        net.WriteInt(data.xp, 32)
        net.WriteInt(data.maxXP, 32)
    net.Send(ply)
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    EFFETS DE LEVEL UP                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.XP.LevelUpEffects(ply)
    if not IsValid(ply) then return end
    
    -- Effet de particules
    local effectdata = EffectData()
    effectdata:SetOrigin(ply:GetPos())
    effectdata:SetEntity(ply)
    util.Effect("dcuo_levelup", effectdata, true, true)
    
    -- Son
    ply:EmitSound("buttons/bell1.wav", 75, 100, 1, CHAN_AUTO)
    
    -- Heal complet
    ply:SetHealth(ply:GetMaxHealth())
    ply:SetArmor(ply:GetMaxArmor())
    
    -- Effet visuel (lumière)
    local light = ents.Create("env_sprite")
    if IsValid(light) then
        light:SetPos(ply:GetPos() + Vector(0, 0, 50))
        light:SetKeyValue("model", "sprites/glow01.spr")
        light:SetKeyValue("scale", "1")
        light:SetKeyValue("rendercolor", "155 89 182")
        light:SetKeyValue("rendermode", "9")
        light:Spawn()
        light:Fire("Kill", "", 3)
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    COMMANDES ADMIN                                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Commande ULX pour donner de l'XP
if ulx then
    function ulx.dcuogiveXP(calling_ply, target_ply, amount)
        if not IsValid(target_ply) then
            ULib.tsayError(calling_ply, "Joueur invalide", true)
            return
        end
        
        DCUO.XP.Give(target_ply, amount, "Admin")
        
        ulx.fancyLogAdmin(calling_ply, "#A a donné #i XP à #T", amount, target_ply)
        
        -- Log dans la base de données
        DCUO.Database.LogAdminAction(
            calling_ply,
            "GIVE_XP",
            target_ply,
            "Amount: " .. amount
        )
    end
    
    local giveXP = ulx.command("DCUO", "ulx dcuogiveXP", ulx.dcuogiveXP, "!givexp")
    giveXP:addParam{type = ULib.cmds.PlayerArg}
    giveXP:addParam{type = ULib.cmds.NumArg, min = 1, hint = "amount"}
    giveXP:defaultAccess(ULib.ACCESS_ADMIN)
    giveXP:help("Donner de l'XP à un joueur")
end

-- Commande ULX pour définir le niveau
if ulx then
    function ulx.dcuosetLevel(calling_ply, target_ply, level)
        if not IsValid(target_ply) then
            ULib.tsayError(calling_ply, "Joueur invalide", true)
            return
        end
        
        level = math.Clamp(level, 1, DCUO.Config.MaxLevel)
        
        if target_ply.DCUOData then
            target_ply.DCUOData.level = level
            target_ply.DCUOData.xp = 0
            target_ply.DCUOData.maxXP = DCUO.XP.CalculateXPNeeded(level)
            
            DCUO.Database.SavePlayer(target_ply)
            
            net.Start("DCUO:UpdateLevel")
                net.WriteInt(level, 16)
                net.WriteBool(false)
            net.Send(target_ply)
            
            net.Start("DCUO:UpdateXP")
                net.WriteInt(0, 32)
                net.WriteInt(target_ply.DCUOData.maxXP, 32)
            net.Send(target_ply)
        end
        
        ulx.fancyLogAdmin(calling_ply, "#A a défini le niveau de #T à #i", target_ply, level)
        
        DCUO.Database.LogAdminAction(
            calling_ply,
            "SET_LEVEL",
            target_ply,
            "Level: " .. level
        )
    end
    
    local setLevel = ulx.command("DCUO", "ulx dcuosetlevel", ulx.dcuosetLevel, "!setlevel")
    setLevel:addParam{type = ULib.cmds.PlayerArg}
    setLevel:addParam{type = ULib.cmds.NumArg, min = 1, max = DCUO.Config.MaxLevel, hint = "level"}
    setLevel:defaultAccess(ULib.ACCESS_ADMIN)
    setLevel:help("Définir le niveau d'un joueur")
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    HOOKS                                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Donner de l'XP pour avoir tué un NPC
hook.Add("OnNPCKilled", "DCUO:NPCKillXP", function(npc, attacker, inflictor)
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    
    local xpAmount = DCUO.Config.XPGains.KillNPC or 10
    
    -- Boss donnent plus d'XP
    if npc:Health() > 500 or npc:GetMaxHealth() > 500 then
        xpAmount = DCUO.Config.XPGains.KillBoss or 100
    end
    
    DCUO.XP.Give(attacker, xpAmount, "Kill NPC")
end)

DCUO.Log("XP system (server) loaded", "SUCCESS")

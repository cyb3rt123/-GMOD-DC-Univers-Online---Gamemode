-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    DUEL SYSTEM (SERVER)                           ║
-- ║        Gestion serveur des duels avec zone et cinématiques        ║
-- ╚═══════════════════════════════════════════════════════════════════╝

if CLIENT then return end

-- Network strings
util.AddNetworkString("DCUO_SendDuelRequest")
util.AddNetworkString("DCUO_DuelRequest")
util.AddNetworkString("DCUO_DuelAccepted")
util.AddNetworkString("DCUO_DuelStart")
util.AddNetworkString("DCUO_DuelCountdown")
util.AddNetworkString("DCUO_DuelEnd")
util.AddNetworkString("DCUO_DuelFinishCam")

local pendingRequests = {}
local duelID = 0

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     DEMANDES DE DUEL                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

net.Receive("DCUO_SendDuelRequest", function(len, requester)
    local target = net.ReadEntity()
    
    if not IsValid(requester) or not IsValid(target) then return end
    if requester == target then return end
    if not target:IsPlayer() then return end
    
    -- Vérifier si les joueurs sont déjà en duel
    if DCUO.Duel.IsInDuel(requester) then
        DCUO.Notify(requester, "Vous êtes déjà en duel !", DCUO.Colors.Error)
        return
    end
    
    if DCUO.Duel.IsInDuel(target) then
        DCUO.Notify(requester, target:Nick() .. " est déjà en duel !", DCUO.Colors.Error)
        return
    end
    
    -- Créer la demande
    local requestID = requester:SteamID64() .. "_" .. target:SteamID64()
    pendingRequests[requestID] = {
        requester = requester,
        target = target,
        time = CurTime()
    }
    
    -- Envoyer la notification au target
    net.Start("DCUO_DuelRequest")
    net.WriteEntity(requester)
    net.WriteString(requestID)
    net.Send(target)
    
    DCUO.Notify(requester, "Demande de duel envoyée à " .. target:Nick(), DCUO.Colors.Info)
    DCUO.Log(requester:Nick() .. " a défié " .. target:Nick() .. " en duel", "INFO")
end)

-- Accepter un duel
function DCUO.Duel.AcceptRequest(requestID)
    local request = pendingRequests[requestID]
    if not request then return end
    
    local p1 = request.requester
    local p2 = request.target
    
    if not IsValid(p1) or not IsValid(p2) then
        pendingRequests[requestID] = nil
        return
    end
    
    -- Supprimer la demande
    pendingRequests[requestID] = nil
    
    -- Démarrer le duel
    DCUO.Duel.Start(p1, p2)
end

concommand.Add("dcuo_accept_duel", function(ply, cmd, args)
    if #args < 1 then return end
    DCUO.Duel.AcceptRequest(args[1])
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     DÉMARRER UN DUEL                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Duel.Start(player1, player2)
    if not IsValid(player1) or not IsValid(player2) then return end
    
    duelID = duelID + 1
    
    -- Calculer la position centrale
    local centerPos = (player1:GetPos() + player2:GetPos()) / 2
    centerPos.z = centerPos.z + 10 -- Légèrement au-dessus du sol
    
    -- Créer le duel
    local duel = {
        id = duelID,
        player1 = player1,
        player2 = player2,
        centerPos = centerPos,
        state = DCUO.Duel.States.PREPARING,
        startTime = CurTime(),
        
        -- Positions originales pour le retour
        player1OrigPos = player1:GetPos(),
        player2OrigPos = player2:GetPos(),
        
        -- Santé originale
        player1OrigHealth = player1:Health(),
        player2OrigHealth = player2:Health(),
        
        -- Sauvegarder les armes originales
        player1OrigWeapons = {},
        player2OrigWeapons = {},
    }
    
    -- Sauvegarder et retirer les armes
    for _, wep in ipairs(player1:GetWeapons()) do
        table.insert(duel.player1OrigWeapons, wep:GetClass())
    end
    for _, wep in ipairs(player2:GetWeapons()) do
        table.insert(duel.player2OrigWeapons, wep:GetClass())
    end
    
    player1:StripWeapons()
    player2:StripWeapons()
    
    -- Donner weapon_fists pour le combat au corps-à-corps
    player1:Give("weapon_fists")
    player2:Give("weapon_fists")
    
    DCUO.Duel.ActiveDuels[duelID] = duel
    
    -- Marquer les joueurs comme étant en duel
    player1:SetNWBool("DCUO_InDuel", true)
    player2:SetNWBool("DCUO_InDuel", true)
    
    -- Téléporter les joueurs face à face
    local offset = Vector(DCUO.Duel.Config.ArenaRadius * 0.4, 0, 0)
    player1:SetPos(centerPos - offset)
    player2:SetPos(centerPos + offset)
    
    -- Les faire se regarder
    local ang1 = (player2:GetPos() - player1:GetPos()):Angle()
    local ang2 = (player1:GetPos() - player2:GetPos()):Angle()
    player1:SetEyeAngles(Angle(0, ang1.y, 0))
    player2:SetEyeAngles(Angle(0, ang2.y, 0))
    
    -- Freeze les joueurs pendant la préparation
    player1:Freeze(true)
    player2:Freeze(true)
    
    -- Notification serveur
    DCUO.NotifyAll(player1:Nick() .. " VS " .. player2:Nick() .. " - DUEL COMMENCE !", DCUO.Colors.Warning)
    
    -- Cinématique d'intro
    net.Start("DCUO_DuelStart")
    net.WriteInt(duelID, 16)
    net.WriteVector(centerPos)
    net.WriteEntity(player1)
    net.WriteEntity(player2)
    net.Send({player1, player2})
    
    -- Démarrer le countdown après l'intro
    timer.Simple(DCUO.Duel.Config.IntroAnimDuration, function()
        if IsValid(player1) and IsValid(player2) then
            DCUO.Duel.StartCountdown(duelID)
        end
    end)
    
    DCUO.Log("Duel #" .. duelID .. " started: " .. player1:Nick() .. " vs " .. player2:Nick(), "INFO")
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     COMPTE À REBOURS                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Duel.StartCountdown(duelID)
    local duel = DCUO.Duel.ActiveDuels[duelID]
    if not duel then return end
    
    duel.state = DCUO.Duel.States.COUNTDOWN
    
    local count = DCUO.Duel.Config.CountdownDuration
    
    timer.Create("DCUO_Duel_Countdown_" .. duelID, 1, count, function()
        if not DCUO.Duel.ActiveDuels[duelID] then
            timer.Remove("DCUO_Duel_Countdown_" .. duelID)
            return
        end
        
        local repsLeft = timer.RepsLeft("DCUO_Duel_Countdown_" .. duelID)
        local currentNumber = repsLeft  -- Compte à rebours: 3, 2, 1
        
        -- Envoyer le countdown
        net.Start("DCUO_DuelCountdown")
        net.WriteInt(duelID, 16)
        net.WriteInt(currentNumber, 8)
        net.Send({duel.player1, duel.player2})
        
        if currentNumber <= 0 then
            -- FIGHT !
            DCUO.Duel.StartFight(duelID)
        end
    end)
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     COMMENCER LE COMBAT                           ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Duel.StartFight(duelID)
    local duel = DCUO.Duel.ActiveDuels[duelID]
    if not duel then return end
    
    duel.state = DCUO.Duel.States.FIGHTING
    duel.fightStartTime = CurTime()
    
    -- Unfreeze les joueurs
    if IsValid(duel.player1) then duel.player1:Freeze(false) end
    if IsValid(duel.player2) then duel.player2:Freeze(false) end
    
    DCUO.Notify(duel.player1, "COMBAT !", DCUO.Colors.Success)
    DCUO.Notify(duel.player2, "COMBAT !", DCUO.Colors.Success)
    
    -- Timer de combat (5 minutes max)
    local fightDuration = 300  -- 5 minutes
    timer.Create("DCUO_Duel_FightTimer_" .. duelID, fightDuration, 1, function()
        if DCUO.Duel.ActiveDuels[duelID] and DCUO.Duel.ActiveDuels[duelID].state == DCUO.Duel.States.FIGHTING then
            -- Temps écoulé, égalité
            DCUO.Duel.EndDraw(duelID, "TEMPS ÉCOULÉ")
        end
    end)
    
    DCUO.Log("Duel #" .. duelID .. " fight started", "INFO")
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     TERMINER LE DUEL                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Duel.End(duelID, winner, loser, reason)
    local duel = DCUO.Duel.ActiveDuels[duelID]
    if not duel then return end
    
    duel.state = DCUO.Duel.States.FINISHING
    duel.winner = winner
    duel.loser = loser
    
    -- Supprimer le timer de combat
    timer.Remove("DCUO_Duel_FightTimer_" .. duelID)
    
    -- Freeze les deux joueurs pour la cinématique
    if IsValid(winner) then winner:Freeze(true) end
    if IsValid(loser) then loser:Freeze(true) end
    
    -- Cinématique du coup fatal
    net.Start("DCUO_DuelFinishCam")
    net.WriteInt(duelID, 16)
    net.WriteEntity(winner)
    net.WriteEntity(loser)
    net.WriteString(reason or "K.O.")
    net.Send({winner, loser})
    
    -- Notifications
    DCUO.NotifyAll(winner:Nick() .. " a vaincu " .. loser:Nick() .. " en duel !", DCUO.Colors.Success)
    
    -- Récompenses XP
    if IsValid(winner) then
        DCUO.XP.Add(winner, DCUO.Duel.Config.WinnerXP, "Victoire en duel")
    end
    if IsValid(loser) then
        DCUO.XP.Add(loser, DCUO.Duel.Config.ParticipationXP, "Participation au duel")
    end
    
    -- Cleanup après la cinématique
    timer.Simple(DCUO.Duel.Config.FinishAnimDuration, function()
        DCUO.Duel.Cleanup(duelID)
    end)
    
    DCUO.Log("Duel #" .. duelID .. " ended - Winner: " .. (IsValid(winner) and winner:Nick() or "Unknown"), "INFO")
end

-- Terminer le duel en égalité
function DCUO.Duel.EndDraw(duelID, reason)
    local duel = DCUO.Duel.ActiveDuels[duelID]
    if not duel then return end
    
    duel.state = DCUO.Duel.States.FINISHING
    
    -- Supprimer le timer de combat
    timer.Remove("DCUO_Duel_FightTimer_" .. duelID)
    
    -- Freeze les joueurs
    if IsValid(duel.player1) then duel.player1:Freeze(true) end
    if IsValid(duel.player2) then duel.player2:Freeze(true) end
    
    -- Notifications
    DCUO.NotifyAll("Match nul entre " .. duel.player1:Nick() .. " et " .. duel.player2:Nick() .. " - " .. reason, DCUO.Colors.Warning)
    
    -- XP de participation pour les deux
    if IsValid(duel.player1) then
        DCUO.XP.Add(duel.player1, DCUO.Duel.Config.ParticipationXP, "Duel - Égalité")
    end
    if IsValid(duel.player2) then
        DCUO.XP.Add(duel.player2, DCUO.Duel.Config.ParticipationXP, "Duel - Égalité")
    end
    
    -- Cleanup immédiat (pas de cinématique pour l'égalité)
    timer.Simple(2, function()
        DCUO.Duel.Cleanup(duelID)
    end)
    
    DCUO.Log("Duel #" .. duelID .. " ended in a draw - " .. reason, "INFO")
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     NETTOYAGE                                     ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Duel.Cleanup(duelID)
    local duel = DCUO.Duel.ActiveDuels[duelID]
    if not duel then return end
    
    -- Restaurer la santé
    if DCUO.Duel.Config.RestoreHealthAfter then
        if IsValid(duel.player1) then
            duel.player1:SetHealth(duel.player1OrigHealth)
        end
        if IsValid(duel.player2) then
            duel.player2:SetHealth(duel.player2OrigHealth)
        end
    end
    
    -- Téléporter les joueurs à leur position d'origine
    if DCUO.Duel.Config.TeleportBackAfter then
        if IsValid(duel.player1) then
            duel.player1:SetPos(duel.player1OrigPos)
        end
        if IsValid(duel.player2) then
            duel.player2:SetPos(duel.player2OrigPos)
        end
    end
    
    -- Unfreeze
    if IsValid(duel.player1) then
        duel.player1:Freeze(false)
        duel.player1:SetNWBool("DCUO_InDuel", false)
        
        -- TOUJOURS forcer le mouvement à WALK (même si noclip/fly)
        duel.player1:SetMoveType(MOVETYPE_WALK)
        
        -- Réactiver la gravité au cas où
        duel.player1:SetGravity(1)
        
        -- Restaurer les armes
        duel.player1:StripWeapons()
        for _, wepClass in ipairs(duel.player1OrigWeapons) do
            duel.player1:Give(wepClass)
        end
    end
    if IsValid(duel.player2) then
        duel.player2:Freeze(false)
        duel.player2:SetNWBool("DCUO_InDuel", false)
        
        -- TOUJOURS forcer le mouvement à WALK (même si noclip/fly)
        duel.player2:SetMoveType(MOVETYPE_WALK)
        
        -- Réactiver la gravité au cas où
        duel.player2:SetGravity(1)
        
        -- Restaurer les armes
        duel.player2:StripWeapons()
        for _, wepClass in ipairs(duel.player2OrigWeapons) do
            duel.player2:Give(wepClass)
        end
    end
    
    -- Envoyer notification de fin
    net.Start("DCUO_DuelEnd")
    net.WriteInt(duelID, 16)
    net.Send({duel.player1, duel.player2})
    
    -- Supprimer le duel
    DCUO.Duel.ActiveDuels[duelID] = nil
    
    -- Supprimer les timers
    timer.Remove("DCUO_Duel_Countdown_" .. duelID)
    timer.Remove("DCUO_Duel_FightTimer_" .. duelID)
    timer.Remove("DCUO_Duel_BoundaryCheck_" .. duelID)
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                          HOOKS                                    ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Empêcher les dégâts hors combat
hook.Add("EntityTakeDamage", "DCUO_Duel_DamageControl", function(target, dmginfo)
    local attacker = dmginfo:GetAttacker()
    
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if not IsValid(target) or not target:IsPlayer() then return end
    
    local duel = DCUO.Duel.GetPlayerDuel(attacker)
    if not duel then return end
    
    -- Vérifier que l'attaquant attaque bien son adversaire
    local opponent = DCUO.Duel.GetOpponent(attacker)
    if target ~= opponent then
        return true -- Bloquer les dégâts sur d'autres joueurs
    end
    
    -- Bloquer les dégâts pendant la préparation/countdown
    if duel.state ~= DCUO.Duel.States.FIGHTING then
        return true
    end
end)

-- Détecter la mort d'un joueur
hook.Add("PlayerDeath", "DCUO_Duel_OnDeath", function(victim, inflictor, attacker)
    local duel, duelID = DCUO.Duel.GetPlayerDuel(victim)
    if not duel then return end
    
    -- Le joueur mort a perdu
    local opponent = DCUO.Duel.GetOpponent(victim)
    
    if IsValid(opponent) then
        DCUO.Duel.End(duelID, opponent, victim, "FATALITY")
    else
        DCUO.Duel.Cleanup(duelID)
    end
end)

-- Vérifier les limites de l'arène
timer.Create("DCUO_Duel_BoundaryCheck", 0.5, 0, function()
    for id, duel in pairs(DCUO.Duel.ActiveDuels) do
        if duel.state == DCUO.Duel.States.FIGHTING then
            -- Vérifier player1
            if IsValid(duel.player1) then
                local dist = duel.player1:GetPos():Distance(duel.centerPos)
                if dist > DCUO.Duel.Config.ArenaRadius then
                    -- Ramener le joueur
                    local dir = (duel.centerPos - duel.player1:GetPos()):GetNormalized()
                    local newPos = duel.centerPos - dir * (DCUO.Duel.Config.ArenaRadius - 50)
                    newPos.z = duel.player1:GetPos().z
                    duel.player1:SetPos(newPos)
                    
                    DCUO.Notify(duel.player1, "Vous ne pouvez pas quitter l'arène !", DCUO.Colors.Warning)
                end
            end
            
            -- Vérifier player2
            if IsValid(duel.player2) then
                local dist = duel.player2:GetPos():Distance(duel.centerPos)
                if dist > DCUO.Duel.Config.ArenaRadius then
                    local dir = (duel.centerPos - duel.player2:GetPos()):GetNormalized()
                    local newPos = duel.centerPos - dir * (DCUO.Duel.Config.ArenaRadius - 50)
                    newPos.z = duel.player2:GetPos().z
                    duel.player2:SetPos(newPos)
                    
                    DCUO.Notify(duel.player2, "Vous ne pouvez pas quitter l'arène !", DCUO.Colors.Warning)
                end
            end
        end
    end
end)

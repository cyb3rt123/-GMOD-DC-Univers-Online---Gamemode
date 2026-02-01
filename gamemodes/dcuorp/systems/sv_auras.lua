--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système d'Auras (Serveur)
    Gestion des auras côté serveur
═══════════════════════════════════════════════════════════════════════
--]]

if CLIENT then return end

DCUO.Auras = DCUO.Auras or {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    ACHAT D'AURA                                   ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Auras.Buy(ply, auraId)
    if not IsValid(ply) or not ply.DCUOData then return false end
    
    local canBuy, reason = DCUO.Auras.CanBuy(ply, auraId)
    if not canBuy then
        DCUO.Notify(ply, reason or "Impossible d'acheter cette aura", DCUO.Colors.Error)
        return false
    end
    
    local aura = DCUO.Auras.Get(auraId)
    if not aura then return false end
    
    -- Retirer l'XP
    DCUO.XP.Take(ply, aura.cost, "Achat aura: " .. aura.name)
    
    -- Ajouter l'aura à la collection
    ply.DCUOData.auras = ply.DCUOData.auras or {}
    table.insert(ply.DCUOData.auras, auraId)
    
    -- Équiper automatiquement
    DCUO.Auras.Equip(ply, auraId)
    
    -- Sauvegarder
    DCUO.Database.SavePlayer(ply)
    
    -- Notification
    DCUO.Notify(ply, "Aura '" .. aura.name .. "' achetée et équipée !", DCUO.Colors.Success)
    DCUO.Log(ply:Nick() .. " bought aura: " .. auraId, "INFO")
    
    return true
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    ÉQUIPER UNE AURA                               ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Auras.Equip(ply, auraId)
    if not IsValid(ply) or not ply.DCUOData then return false end
    
    -- Vérifier que le joueur possède l'aura
    if auraId ~= "none" then
        if not ply.DCUOData.auras or not table.HasValue(ply.DCUOData.auras, auraId) then
            DCUO.Notify(ply, "Vous ne possédez pas cette aura", DCUO.Colors.Error)
            return false
        end
    end
    
    local aura = DCUO.Auras.Get(auraId)
    if not aura then return false end
    
    -- Équiper l'aura
    ply.DCUOData.equippedAura = auraId
    
    -- Sauvegarder
    DCUO.Database.SavePlayer(ply)
    
    -- Envoyer au client
    net.Start("DCUO:EquipAura")
        net.WriteString(auraId)
    net.Send(ply)
    
    -- Notification
    if auraId == "none" then
        DCUO.Notify(ply, "Aura désactivée", DCUO.Colors.Info)
    else
        DCUO.Notify(ply, "Aura '" .. aura.name .. "' équipée !", DCUO.Colors.Success)
    end
    
    DCUO.Log(ply:Nick() .. " equipped aura: " .. auraId, "INFO")
    
    return true
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    NETWORK RECEIVERS                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

util.AddNetworkString("DCUO:BuyAura")
util.AddNetworkString("DCUO:RequestEquipAura")  -- Client -> Serveur (demande)
util.AddNetworkString("DCUO:EquipAura")          -- Serveur -> Client (confirmation)
util.AddNetworkString("DCUO:SendAuras")

-- Recevoir achat d'aura
net.Receive("DCUO:BuyAura", function(len, ply)
    local auraId = net.ReadString()
    DCUO.Auras.Buy(ply, auraId)
end)

-- Recevoir demande d'équipement d'aura (Client -> Serveur)
net.Receive("DCUO:RequestEquipAura", function(len, ply)
    local auraId = net.ReadString()
    DCUO.Auras.Equip(ply, auraId)
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CHARGEMENT AURA AU SPAWN                       ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("PlayerSpawn", "DCUO:LoadAura", function(ply)
    timer.Simple(0.1, function()
        if not IsValid(ply) or not ply.DCUOData then return end
        
        -- Charger l'aura équipée
        local auraId = ply.DCUOData.equippedAura or "none"
        
        if auraId and auraId ~= "none" then
            net.Start("DCUO:EquipAura")
                net.WriteString(auraId)
            net.Send(ply)
        end
    end)
end)

DCUO.Log("Auras server system loaded", "SUCCESS")

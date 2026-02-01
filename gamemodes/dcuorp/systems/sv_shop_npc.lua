--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - NPC Boutique (Server)
    Gestion du NPC marchand
═══════════════════════════════════════════════════════════════════════
--]]

if CLIENT then return end

DCUO.ShopNPC = DCUO.ShopNPC or {}
DCUO.ShopNPC.NPCs = {}

util.AddNetworkString("DCUO:Shop:Open")
util.AddNetworkString("DCUO:Shop:Purchase")

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CRÉATION DU NPC                                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.ShopNPC.Create(pos, ang, model)
    model = model or "models/player/male_02.mdl"
    
    local npc = ents.Create("npc_citizen")
    if not IsValid(npc) then
        DCUO.Log("Failed to create shop NPC", "ERROR")
        return nil
    end
    
    npc:SetModel(model)
    npc:SetPos(pos)
    npc:SetAngles(ang)
    npc:SetMaxHealth(999999)
    npc:SetHealth(999999)
    npc:SetKeyValue("spawnflags", "512") -- Désactiver les mouvements
    npc:SetMoveType(MOVETYPE_NONE)
    npc:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
    npc:SetNPCState(NPC_STATE_IDLE)
    npc.IsShopNPC = true
    npc:Spawn()
    npc:Activate()
    
    -- Empêcher de bouger
    local phys = npc:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
    end
    
    table.insert(DCUO.ShopNPC.NPCs, npc)
    
    DCUO.Log("Shop NPC created at " .. tostring(pos), "SUCCESS")
    return npc
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    INTERACTION                                    ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("PlayerUse", "DCUO:ShopNPC:Use", function(ply, ent)
    if IsValid(ent) and ent.IsShopNPC then
        net.Start("DCUO:Shop:Open")
        net.Send(ply)
        return false
    end
end)

-- Empêcher les dégâts sur le NPC
hook.Add("EntityTakeDamage", "DCUO:ShopNPC:NoDamage", function(target, dmg)
    if IsValid(target) and target.IsShopNPC then
        return true
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    COMMANDE ADMIN                                 ║
-- ╚═══════════════════════════════════════════════════════════════════╝

concommand.Add("dcuo_createshopnpc", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    
    local tr = ply:GetEyeTrace()
    local pos = tr.HitPos + Vector(0, 0, 10)
    local ang = ply:EyeAngles()
    ang.p = 0
    ang.r = 0
    ang.y = ang.y + 180
    
    local model = args[1] or "models/player/male_02.mdl"
    
    DCUO.ShopNPC.Create(pos, ang, model)
    ply:ChatPrint("[SHOP] NPC créé à votre position")
end)

-- Sauvegarder les NPCs
concommand.Add("dcuo_saveshopnpcs", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    
    local npcData = {}
    
    for _, npc in ipairs(DCUO.ShopNPC.NPCs) do
        if IsValid(npc) then
            table.insert(npcData, {
                pos = npc:GetPos(),
                ang = npc:GetAngles(),
                model = npc:GetModel()
            })
        end
    end
    
    file.Write("dcuo/shop_npcs.txt", util.TableToJSON(npcData, true))
    ply:ChatPrint("[SHOP] " .. #npcData .. " NPCs sauvegardés")
    DCUO.Log("Saved " .. #npcData .. " shop NPCs", "SUCCESS")
end)

-- Charger les NPCs sauvegardés
function DCUO.ShopNPC.LoadAll()
    if not file.Exists("dcuo/shop_npcs.txt", "DATA") then
        DCUO.Log("No shop NPCs to load", "INFO")
        return
    end
    
    local data = file.Read("dcuo/shop_npcs.txt", "DATA")
    local npcData = util.JSONToTable(data) or {}
    
    for _, npcInfo in ipairs(npcData) do
        DCUO.ShopNPC.Create(npcInfo.pos, npcInfo.ang, npcInfo.model)
    end
    
    DCUO.Log("Loaded " .. #npcData .. " shop NPCs", "SUCCESS")
end

-- Charger au démarrage
hook.Add("InitPostEntity", "DCUO:LoadShopNPCs", function()
    timer.Simple(1, function()
        DCUO.ShopNPC.LoadAll()
    end)
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    ACHAT D'ITEMS                                  ║
-- ╚═══════════════════════════════════════════════════════════════════╝

net.Receive("DCUO:Shop:Purchase", function(len, ply)
    local itemID = net.ReadString()
    
    -- TODO: Implémenter la logique d'achat
    -- Pour l'instant, on utilise le système d'auras existant
    
    if DCUO.Auras and DCUO.Auras.Purchase then
        DCUO.Auras.Purchase(ply, itemID)
    end
end)

DCUO.Log("Shop NPC System (Server) Loaded", "SUCCESS")

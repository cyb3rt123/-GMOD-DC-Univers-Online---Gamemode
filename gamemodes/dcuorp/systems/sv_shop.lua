--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Boutique (Server)
    Shop avec XP comme monnaie
═══════════════════════════════════════════════════════════════════════
--]]

if CLIENT then return end

DCUO.Shop = DCUO.Shop or {}

-- Acheter un item
function DCUO.Shop.BuyItem(ply, itemID)
    if not IsValid(ply) or not ply.DCUOData then return false end
    
    local item = DCUO.Config.Shop.Items[itemID]
    if not item then
        DCUO.Notify(ply, "Item introuvable", DCUO.Colors.Error)
        return false
    end
    
    -- Vérifier l'XP
    if ply.DCUOData.xp < item.cost then
        DCUO.Notify(ply, string.format(DCUO.Config.Messages.InsufficientXP, item.cost), DCUO.Colors.Error)
        return false
    end
    
    -- Vérifier si déjà acheté
    if table.HasValue(ply.DCUOData.purchases or {}, itemID) then
        DCUO.Notify(ply, "Vous possédez déjà cet item", DCUO.Colors.Warning)
        return false
    end
    
    -- Retirer l'XP
    DCUO.XP.Take(ply, item.cost, "Achat: " .. item.name)
    
    -- Ajouter l'item
    table.insert(ply.DCUOData.purchases, itemID)
    DCUO.Database.SavePurchase(ply, itemID)
    
    -- Notification
    DCUO.Notify(ply, "Vous avez acheté: " .. item.name, DCUO.Colors.Success)
    
    return true
end

DCUO.Log("Shop system (server) loaded", "SUCCESS")

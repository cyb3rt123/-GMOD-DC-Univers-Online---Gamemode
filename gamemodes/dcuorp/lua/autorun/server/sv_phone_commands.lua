--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Commandes DCUO Phone
    Commandes serveur pour gérer le téléphone
═══════════════════════════════════════════════════════════════════════
--]]

if CLIENT then return end

-- Commande pour donner le téléphone à un joueur
concommand.Add("dcuo_givephone", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    
    local target = ply
    
    -- Si un nom est fourni, chercher le joueur
    if args[1] then
        local name = table.concat(args, " ")
        for _, p in ipairs(player.GetAll()) do
            if string.find(string.lower(p:Nick()), string.lower(name)) then
                target = p
                break
            end
        end
    end
    
    if IsValid(target) then
        target:Give("dcuo_phone")
        DCUO.Notify(ply, "Téléphone donné à " .. target:Nick(), Color(0, 255, 0))
        DCUO.Notify(target, "Vous avez reçu un DCUO Phone !", Color(52, 152, 219))
    end
end)

-- Commande pour donner le téléphone à tous
concommand.Add("dcuo_givephone_all", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    
    for _, p in ipairs(player.GetAll()) do
        if not p:HasWeapon("dcuo_phone") then
            p:Give("dcuo_phone")
        end
    end
    
    DCUO.NotifyAll("Tous les joueurs ont reçu un DCUO Phone !", Color(52, 152, 219))
end)

DCUO.Log("DCUO Phone commands loaded", "SUCCESS")

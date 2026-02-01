--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Commandes GPS pour tests
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

-- Commande pour définir des checkpoints de test
concommand.Add("dcuo_gps_test", function()
    local ply = LocalPlayer()
    local pos = ply:GetPos()
    
    -- Créer 5 checkpoints autour du joueur
    local checkpoints = {
        {pos = pos + Vector(500, 0, 0), name = "Point Nord"},
        {pos = pos + Vector(500, 500, 0), name = "Point Nord-Est"},
        {pos = pos + Vector(0, 500, 0), name = "Point Est"},
        {pos = pos + Vector(-500, 500, 0), name = "Point Sud-Est"},
        {pos = pos + Vector(-500, 0, 0), name = "Destination finale", color = Color(46, 204, 113)},
    }
    
    DCUO.MissionHUD.SetCheckpoints(checkpoints)
    print("[GPS TEST] 5 checkpoints créés autour de votre position")
    notification.AddLegacy("[GPS] Activé - 5 checkpoints à atteindre", NOTIFY_GENERIC, 5)
end)

-- Commande pour effacer le GPS
concommand.Add("dcuo_gps_clear", function()
    DCUO.MissionHUD.ClearWaypoints()
    DCUO.MissionHUD.MissionPosition = nil
    print("[GPS] Tous les waypoints effacés")
    notification.AddLegacy("GPS désactivé", NOTIFY_GENERIC, 3)
end)

-- Commande pour définir un seul waypoint
concommand.Add("dcuo_gps_set", function(ply, cmd, args)
    if not args[1] or not args[2] or not args[3] then
        print("[GPS] Usage: dcuo_gps_set <x> <y> <z>")
        return
    end
    
    local x = tonumber(args[1])
    local y = tonumber(args[2])
    local z = tonumber(args[3])
    
    if not x or not y or not z then
        print("[GPS] Coordonnées invalides")
        return
    end
    
    local pos = Vector(x, y, z)
    DCUO.MissionHUD.MissionPosition = pos
    DCUO.MissionHUD.ClearWaypoints()
    DCUO.MissionHUD.AddWaypoint(pos, "Destination", Color(52, 152, 219))
    
    print("[GPS] Waypoint défini à: " .. tostring(pos))
    notification.AddLegacy("[GPS] Activé", NOTIFY_GENERIC, 3)
end)

-- Commande pour afficher ma position
concommand.Add("dcuo_getpos", function()
    local pos = LocalPlayer():GetPos()
    print("Position: " .. math.Round(pos.x) .. " " .. math.Round(pos.y) .. " " .. math.Round(pos.z))
    SetClipboardText(math.Round(pos.x) .. " " .. math.Round(pos.y) .. " " .. math.Round(pos.z))
    notification.AddLegacy("Position copiée dans le presse-papier", NOTIFY_GENERIC, 3)
end)

print("[DCUO GPS] Commandes de test chargées:")
print("  dcuo_gps_test - Créer 5 checkpoints de test")
print("  dcuo_gps_clear - Effacer le GPS")
print("  dcuo_gps_set <x> <y> <z> - Définir un waypoint")
print("  dcuo_getpos - Afficher votre position")

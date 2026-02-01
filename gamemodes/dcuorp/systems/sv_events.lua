--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système d'Événements (Server)
    Gestion des événements serveur
═══════════════════════════════════════════════════════════════════════
--]]

if CLIENT then return end

DCUO.Events = DCUO.Events or {}

-- Lancer un événement global
function DCUO.Events.Trigger(eventName, data)
    DCUO.Log("Event triggered: " .. eventName, "INFO")
    
    net.Start("DCUO:EventStart")
        net.WriteString(eventName)
        net.WriteTable(data or {})
    net.Broadcast()
    
    hook.Run("DCUO:Event_" .. eventName, data)
end

DCUO.Log("Events system (server) loaded", "SUCCESS")

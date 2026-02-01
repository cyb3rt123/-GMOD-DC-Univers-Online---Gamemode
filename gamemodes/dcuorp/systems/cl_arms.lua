-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                PLAYERMODEL ARMS SYSTEM (CLIENT)                   ║
-- ║            Application des viewmodels de mains côté client        ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Variable locale pour stocker les arms actuelles
local currentArms = "models/weapons/c_arms_citizen.mdl"

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     NETWORK RECEIVERS                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

net.Receive("DCUO_SetPlayerArms", function()
    local armsModel = net.ReadString()
    
    if armsModel and armsModel ~= "" then
        currentArms = armsModel
        DCUO.Log("Arms model set to: " .. armsModel, "INFO")
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     APPLIQUER LES ARMS                            ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Hook pour changer les arms des viewmodels
hook.Add("PreDrawViewModel", "DCUO_CustomArms", function(vm, ply, wep)
    if not IsValid(vm) or not IsValid(ply) or not IsValid(wep) then return end
    if ply ~= LocalPlayer() then return end
    
    -- Ne pas affecter le toolgun
    local wepClass = wep:GetClass()
    if wepClass == "gmod_tool" then
        return
    end
    
    -- Appliquer le model d'arms personnalisé
    if currentArms and vm:GetModel() ~= currentArms then
        vm:SetModel(currentArms)
    end
end)

-- Alternative: Hook pour les SWEP
hook.Add("CalcViewModelView", "DCUO_CustomArms", function(weapon, vm, oldPos, oldAng, pos, ang)
    if not IsValid(vm) or not IsValid(weapon) then return end
    
    local wepClass = weapon:GetClass()
    if wepClass == "gmod_tool" then
        return
    end
    
    -- Forcer le model d'arms
    if currentArms and vm:GetModel() ~= currentArms then
        vm:SetModel(currentArms)
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     FONCTIONS UTILITAIRES                         ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Fonction pour récupérer les arms actuelles (pour debug)
function DCUO.GetCurrentArms()
    return currentArms
end

-- Fonction pour forcer un changement d'arms (pour admin/debug)
function DCUO.ForceArms(armsModel)
    if armsModel and armsModel ~= "" then
        currentArms = armsModel
        print("[DCUO] Force changed arms to: " .. armsModel)
    end
end

-- Commande console pour debug
concommand.Add("dcuo_show_arms", function()
    print("Current arms model: " .. currentArms)
end)

concommand.Add("dcuo_reset_arms", function()
    currentArms = "models/weapons/c_arms_citizen.mdl"
    print("Arms reset to default")
end)

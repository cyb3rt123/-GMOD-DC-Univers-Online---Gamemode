--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Fix pour The Flash SWEP (Workshop)
    Corrige l'erreur NULL entity dans tfsr_sv_speed.lua
═══════════════════════════════════════════════════════════════════════
--]]

-- Désactiver le hook problématique de The Flash SWEP
local function ApplyFlashSWEPFix()
    -- Remplacer/neutraliser le hook exact utilisé par l'addon.
    -- hook.Add avec le même (event, identifier) remplace la fonction existante.
    hook.Add("PlayerTick", "TheFlashSR_PlayerThink", function(ply)
        if not IsValid(ply) then return end
        if not ply:Alive() then return end

        local weapon = ply:GetActiveWeapon()
        if not IsValid(weapon) then return end

        -- NE PAS appeler weapon:GetClass() si l'addon le faisait avec une entité NULL.
        -- Ici on neutralise simplement pour éviter l'erreur (stabilité > comportement addon).
    end)

    -- Certains serveurs/addons enregistrent le même identifier sur d'autres events.
    hook.Add("Think", "TheFlashSR_PlayerThink", function()
        -- no-op
    end)
    hook.Add("Tick", "TheFlashSR_PlayerThink", function()
        -- no-op
    end)
end

-- Appliquer après le chargement autorun, puis ré-appliquer au cas où l'addon le recrée.
timer.Simple(1, function()
    ApplyFlashSWEPFix()
    print("[DCUO-RP] Flash SWEP hook overridden (pass 1)")
end)

timer.Simple(10, function()
    ApplyFlashSWEPFix()
    print("[DCUO-RP] Flash SWEP hook overridden (pass 2)")
end)

timer.Create("DCUO_FlashSWEP_Fix_KeepAlive", 30, 0, function()
    ApplyFlashSWEPFix()
end)

print("[DCUO-RP] Flash SWEP fix loaded")

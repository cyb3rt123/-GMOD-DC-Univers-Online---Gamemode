--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Test DCUO Phone
    Script de vérification du téléphone
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then
    print("\n=== DCUO PHONE - SERVER CHECK ===")
    
    -- Vérifier que le SWEP existe
    local swepPath = "dcuorp/entities/weapons/dcuo_phone.lua"
    if file.Exists(swepPath, "LUA") then
        print("✓ SWEP file exists: " .. swepPath)
    else
        print("✗ SWEP file MISSING: " .. swepPath)
    end
    
    -- Vérifier l'enregistrement
    timer.Simple(1, function()
        local swepClass = weapons.Get("dcuo_phone")
        if swepClass then
            print("✓ SWEP registered: dcuo_phone")
            print("  - Name: " .. tostring(swepClass.PrintName))
            print("  - Category: " .. tostring(swepClass.Category))
        else
            print("✗ SWEP NOT registered!")
        end
    end)
    
    print("=================================\n")
end

if CLIENT then
    timer.Simple(2, function()
        print("\n=== DCUO PHONE - CLIENT CHECK ===")
        
        -- Vérifier le système UI
        if DCUO and DCUO.Phone then
            print("✓ DCUO.Phone loaded")
            print("  - Open function:", DCUO.Phone.Open ~= nil)
        else
            print("✗ DCUO.Phone NOT loaded!")
        end
        
        -- Vérifier les dépendances
        print("\nDependencies:")
        print("  - DCUO.UI:", DCUO.UI ~= nil)
        print("  - DCUO.AuraShop:", DCUO.AuraShop ~= nil)
        print("  - DCUO.Guilds:", DCUO.Guilds ~= nil)
        
        -- Test command
        print("\nTest commands:")
        print("  lua_run_cl DCUO.Phone.Open()")
        print("  dcuo_phone")
        print("  give dcuo_phone")
        
        print("=================================\n")
    end)
end

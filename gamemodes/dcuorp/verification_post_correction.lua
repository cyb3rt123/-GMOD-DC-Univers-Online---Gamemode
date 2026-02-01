--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Vérification Post-Correction
    Script de diagnostic pour valider toutes les corrections
═══════════════════════════════════════════════════════════════════════
--]]

print("\n" .. string.rep("=", 70))
print("  DCUO-RP - VÉRIFICATION POST-CORRECTION")
print(string.rep("=", 70) .. "\n")

local errors = 0
local warnings = 0
local success = 0

local function Test(name, condition, errorMsg)
    if condition then
        print("✓ " .. name)
        success = success + 1
        return true
    else
        print("✗ " .. name)
        if errorMsg then
            print("  → " .. errorMsg)
        end
        errors = errors + 1
        return false
    end
end

local function Warn(name, condition, warnMsg)
    if condition then
        print("✓ " .. name)
        success = success + 1
        return true
    else
        print("⚠ " .. name)
        if warnMsg then
            print("  → " .. warnMsg)
        end
        warnings = warnings + 1
        return false
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    TESTS CRITIQUES                                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

print("\n🔴 TESTS CRITIQUES:")

-- Test 1: Tables principales
Test("DCUO table exists", DCUO ~= nil, "La table DCUO n'existe pas")
Test("DCUO.Config exists", DCUO and DCUO.Config ~= nil, "DCUO.Config manquant")
Test("DCUO.Colors exists", DCUO and DCUO.Colors ~= nil, "DCUO.Colors manquant")

-- Test 2: Messages Config
Test("DCUO.Config.Messages exists", 
    DCUO and DCUO.Config and DCUO.Config.Messages ~= nil,
    "DCUO.Config.Messages manquant (CRITIQUE)")

if DCUO and DCUO.Config and DCUO.Config.Messages then
    Test("PowerCooldown message exists", 
        DCUO.Config.Messages.PowerCooldown ~= nil,
        "Message PowerCooldown manquant")
    Test("LevelUp message exists", 
        DCUO.Config.Messages.LevelUp ~= nil,
        "Message LevelUp manquant")
end

-- Test 3: Modules principaux
if SERVER then
    Test("DCUO.Database exists", DCUO.Database ~= nil, "Module Database manquant")
    Test("DCUO.XP exists", DCUO.XP ~= nil, "Module XP manquant")
    Test("DCUO.Powers exists", DCUO.Powers ~= nil, "Module Powers manquant")
    Test("DCUO.Guilds exists", DCUO.Guilds ~= nil, "Module Guilds manquant")
end

if CLIENT then
    Test("DCUO.HUD exists", DCUO.HUD ~= nil, "Module HUD manquant")
    Test("DCUO.UI exists", DCUO.UI ~= nil, "Module UI manquant")
    Test("DCUO.F1Menu exists", DCUO.F1Menu ~= nil, "Module F1Menu manquant")
    Test("DCUO.F1Menu.Open exists", 
        DCUO.F1Menu and DCUO.F1Menu.Open ~= nil,
        "Fonction F1Menu.Open manquante")
    Test("DCUO.Guilds.OpenMenu exists",
        DCUO.Guilds and DCUO.Guilds.OpenMenu ~= nil,
        "Fonction Guilds.OpenMenu manquante")
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    TESTS IMPORTANTS                               ║
-- ╚═══════════════════════════════════════════════════════════════════╝

print("\n🟠 TESTS IMPORTANTS:")

-- Test player data initialization
if SERVER then
    local function TestPlayerInit()
        for _, ply in ipairs(player.GetAll()) do
            if not Test("Player " .. ply:Nick() .. " has DCUOData", 
                ply.DCUOData ~= nil,
                "DCUOData manquant pour " .. ply:Nick()) then
                return false
            end
            
            Test("Player " .. ply:Nick() .. " has DCUOCooldowns",
                ply.DCUOCooldowns ~= nil,
                "DCUOCooldowns manquant")
            
            Test("Player " .. ply:Nick() .. " has valid level",
                ply.DCUOData.level and ply.DCUOData.level >= 1,
                "Niveau invalide")
        end
        return true
    end
    
    if #player.GetAll() > 0 then
        TestPlayerInit()
    else
        Warn("Player initialization", false, "Aucun joueur connecté pour tester")
    end
end

-- Test UI systems
if CLIENT then
    Test("DCUO.UI.ActiveMenus exists", 
        DCUO.UI and DCUO.UI.ActiveMenus ~= nil,
        "Table ActiveMenus manquante")
    
    Test("Mission HUD exists",
        DCUO.MissionHUD ~= nil,
        "Module MissionHUD manquant")
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    TESTS DE PERFORMANCE                           ║
-- ╚═══════════════════════════════════════════════════════════════════╝

print("\n🟡 TESTS DE PERFORMANCE:")

if CLIENT then
    -- Compter les hooks HUDPaint
    local hudPaintCount = 0
    local hooks = hook.GetTable()
    if hooks and hooks.HUDPaint then
        for name, func in pairs(hooks.HUDPaint) do
            hudPaintCount = hudPaintCount + 1
        end
    end
    
    Warn("HUDPaint hooks optimized",
        hudPaintCount <= 5,
        hudPaintCount .. " hooks HUDPaint actifs (recommandé: ≤5)")
    
    -- Compter les hooks Think
    local thinkCount = 0
    if hooks and hooks.Think then
        for name, func in pairs(hooks.Think) do
            thinkCount = thinkCount + 1
        end
    end
    
    Warn("Think hooks acceptable",
        thinkCount <= 10,
        thinkCount .. " hooks Think actifs (recommandé: ≤10)")
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    TESTS BASE DE DONNÉES                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

if SERVER then
    print("\n🗄 TESTS BASE DE DONNÉES:")
    
    -- Vérifier les tables SQL
    local tables = sql.Query("SELECT name FROM sqlite_master WHERE type='table'")
    
    if tables then
        local requiredTables = {
            "dcuo_players",
            "dcuo_guilds",
            "dcuo_missions_completed",
            "dcuo_shop_purchases",
            "dcuo_admin_logs",
            "dcuo_achievements"
        }
        
        local foundTables = {}
        for _, t in ipairs(tables) do
            foundTables[t.name] = true
        end
        
        for _, tableName in ipairs(requiredTables) do
            Test("Table " .. tableName .. " exists",
                foundTables[tableName] == true,
                "Table SQL manquante")
        end
    else
        Test("SQL tables accessible", false, "Impossible d'accéder aux tables SQL")
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    RÉSULTATS                                      ║
-- ╚═══════════════════════════════════════════════════════════════════╝

print("\n" .. string.rep("=", 70))
print("  RÉSULTATS")
print(string.rep("=", 70))

local total = success + warnings + errors
local successRate = total > 0 and math.floor((success / total) * 100) or 0

print("\n✓ Réussis: " .. success)
print("⚠ Avertissements: " .. warnings)
print("✗ Erreurs: " .. errors)
print("\nTaux de réussite: " .. successRate .. "%")

if errors == 0 then
    print("\n🎉 TOUS LES TESTS CRITIQUES SONT PASSÉS !")
    print("Le gamemode est prêt pour le déploiement.")
else
    print("\n⚠️  " .. errors .. " ERREUR(S) DÉTECTÉE(S)")
    print("Veuillez corriger ces problèmes avant le déploiement.")
end

if warnings > 0 then
    print("\nℹ️  " .. warnings .. " avertissement(s) - Non bloquant mais à surveiller")
end

print("\n" .. string.rep("=", 70) .. "\n")

-- Retourner le statut
return errors == 0

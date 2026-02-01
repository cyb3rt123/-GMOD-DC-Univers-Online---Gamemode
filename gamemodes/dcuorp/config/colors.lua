--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Configuration des Couleurs
    Palette de couleurs supplémentaires
═══════════════════════════════════════════════════════════════════════
--]]

-- Les couleurs principales sont déjà définies dans shared.lua
-- Ce fichier permet d'ajouter des couleurs supplémentaires

DCUO.Colors = DCUO.Colors or {}

-- Couleurs supplémentaires pour les jobs
DCUO.Colors.Flash = Color(220, 20, 20)
DCUO.Colors.Batman = Color(30, 30, 30)
DCUO.Colors.Superman = Color(0, 0, 255)
DCUO.Colors.WonderWoman = Color(220, 20, 60)
DCUO.Colors.GreenLantern = Color(0, 255, 0)
DCUO.Colors.Joker = Color(128, 0, 128)
DCUO.Colors.LexLuthor = Color(0, 128, 0)
DCUO.Colors.Harley = Color(255, 20, 147)
DCUO.Colors.Deathstroke = Color(255, 140, 0)

-- Couleurs pour l'interface
DCUO.Colors.UIBackground = Color(10, 10, 10, 240)
DCUO.Colors.UIBorder = Color(30, 144, 255, 150)
DCUO.Colors.UIHover = Color(30, 144, 255, 100)
DCUO.Colors.UIActive = Color(30, 144, 255, 200)

-- Couleurs de rareté (pour items futurs)
DCUO.Colors.Common = Color(200, 200, 200)
DCUO.Colors.Uncommon = Color(30, 255, 0)
DCUO.Colors.Rare = Color(0, 112, 221)
DCUO.Colors.Epic = Color(163, 53, 238)
DCUO.Colors.Legendary = Color(255, 128, 0)

DCUO.Log("Colors config loaded", "SUCCESS")

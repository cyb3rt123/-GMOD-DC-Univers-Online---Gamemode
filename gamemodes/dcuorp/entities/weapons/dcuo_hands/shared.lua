-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                        DCUO HANDS SWEP                             ║
-- ║         SWEP invisible pour simuler les mains par défaut           ║
-- ╚═══════════════════════════════════════════════════════════════════╝

SWEP.PrintName = "Hands"
SWEP.Author = "DCUO-RP"
SWEP.Instructions = ""
SWEP.Category = "DCUO-RP"

SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 0
SWEP.SlotPos = 0

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.UseHands = true

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:Deploy()
    return true
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:Think()
end

function SWEP:DrawWorldModel()
    -- Ne rien dessiner
end

if CLIENT then
    function SWEP:DrawViewModel()
        -- Ne rien dessiner
        return true
    end
    
    function SWEP:GetViewModelPosition(pos, ang)
        return pos, ang
    end
    
    function SWEP:DrawHUD()
        -- Pas de HUD
    end
end

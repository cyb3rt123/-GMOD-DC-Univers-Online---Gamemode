--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - DCUO Phone (SWEP)
    Téléphone invisible pour accéder aux menus du serveur
═══════════════════════════════════════════════════════════════════════
--]]

SWEP.PrintName = "DCUO Phone"
SWEP.Author = "DCUO-RP Team"
SWEP.Instructions = "Clic gauche pour ouvrir les menus"
SWEP.Category = "DCUO-RP"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 1
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 2

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

-- PAS DE MODEL VISIBLE
SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.UseHands = false
SWEP.ViewModelFOV = 0

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    INITIALIZATION                                 ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:Deploy()
    if SERVER then
        -- Marquer le joueur comme "sur son téléphone"
        self.Owner.IsOnPhone = true
        self.Owner:SetNWBool("DCUO_OnPhone", true)
    end
    
    if CLIENT then
        LocalPlayer():EmitSound("buttons/button14.wav", 50, 120)
    end
    
    return true
end

function SWEP:Holster()
    if SERVER then
        -- Le joueur n'est plus sur son téléphone
        if IsValid(self.Owner) then
            self.Owner.IsOnPhone = false
            self.Owner:SetNWBool("DCUO_OnPhone", false)
        end
    end
    
    return true
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    PRIMARY ATTACK - OUVRIR MENU                   ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function SWEP:PrimaryAttack()
    if CLIENT then
        if DCUO and DCUO.Phone and DCUO.Phone.Open then
            DCUO.Phone.Open()
            LocalPlayer():EmitSound("buttons/button15.wav", 60, 100)
        end
    end
    
    self:SetNextPrimaryFire(CurTime() + 0.5)
end

function SWEP:SecondaryAttack()
    -- Secondary ne fait rien
    self:SetNextSecondaryFire(CurTime() + 0.5)
end

function SWEP:Reload()
    -- Ne rien faire
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    NO DRAWING                                     ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function SWEP:DrawWorldModel()
    -- Ne rien dessiner
end

function SWEP:ViewModelDrawn()
    -- Ne rien dessiner
end

function SWEP:PreDrawViewModel()
    -- Empêcher le dessin du viewmodel
    return true
end

if CLIENT then
    function SWEP:DrawHUD()
        local scrW, scrH = ScrW(), ScrH()
        
        -- Simple indication en bas de l'écran
        draw.RoundedBox(6, scrW/2 - 150, scrH - 60, 300, 40, Color(0, 0, 0, 150))
        
        draw.SimpleText(
            "[!] TÉLÉPHONE DCUO",
            "DermaDefaultBold",
            scrW/2,
            scrH - 50,
            Color(52, 152, 219),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
        
        draw.SimpleText(
            "Clic gauche pour ouvrir les menus",
            "DermaDefault",
            scrW/2,
            scrH - 30,
            Color(200, 200, 200),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    end
end

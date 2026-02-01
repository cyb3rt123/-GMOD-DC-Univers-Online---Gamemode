--[[
═══════════════════════════════════════════════════════════════════
    DCUO-RP - Vol (Flight)
    Système de vol pour les personnages volants
═══════════════════════════════════════════════════════════════════
--]]

if SERVER then
    AddCSLuaFile()
end

SWEP.PrintName = "Vol"
SWEP.Author = "DCUO-RP"
SWEP.Instructions = "Maintenez ESPACE pour voler, SHIFT pour accélérer"
SWEP.Category = "DCUO - Pouvoirs"

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

SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.UseHands = true

-- Variables de vol
SWEP.IsFlying = false
SWEP.FlightSpeed = 500
SWEP.FlightSpeedBoost = 800
SWEP.FlightForce = 300

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
    -- Pas d'attaque primaire
end

function SWEP:SecondaryAttack()
    -- Pas d'attaque secondaire
end

function SWEP:Think()
    if CLIENT then return end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return end
    
    -- Vérifier si le joueur maintient ESPACE
    if ply:KeyDown(IN_JUMP) and not ply:OnGround() then
        self.IsFlying = true
        
        local vel = ply:GetVelocity()
        local eyeAngles = ply:EyeAngles()
        
        -- Direction de vol
        local forward = eyeAngles:Forward()
        local right = eyeAngles:Right()
        local up = Vector(0, 0, 1)
        
        -- Calculer la nouvelle vélocité
        local moveDir = Vector(0, 0, 0)
        
        if ply:KeyDown(IN_FORWARD) then
            moveDir = moveDir + forward
        end
        if ply:KeyDown(IN_BACK) then
            moveDir = moveDir - forward
        end
        if ply:KeyDown(IN_MOVERIGHT) then
            moveDir = moveDir + right
        end
        if ply:KeyDown(IN_MOVELEFT) then
            moveDir = moveDir - right
        end
        
        -- Ajuster la hauteur
        if ply:KeyDown(IN_JUMP) then
            moveDir = moveDir + up * 0.5
        end
        if ply:KeyDown(IN_DUCK) then
            moveDir = moveDir - up * 0.5
        end
        
        moveDir:Normalize()
        
        -- Vitesse (boost si SHIFT)
        local speed = ply:KeyDown(IN_SPEED) and self.FlightSpeedBoost or self.FlightSpeed
        
        -- Appliquer la vélocité
        local targetVel = moveDir * speed
        local newVel = LerpVector(0.1, vel, targetVel)
        
        ply:SetVelocity(newVel - vel)
        
        -- Annuler la gravité
        ply:SetGravity(0.001)
        
    else
        -- Arrêter le vol
        if self.IsFlying then
            self.IsFlying = false
            ply:SetGravity(1)
        end
    end
    
    self:NextThink(CurTime())
    return true
end

function SWEP:Holster()
    if SERVER and IsValid(self:GetOwner()) then
        self:GetOwner():SetGravity(1)
        self.IsFlying = false
    end
    return true
end

function SWEP:OnRemove()
    if SERVER and IsValid(self:GetOwner()) then
        self:GetOwner():SetGravity(1)
    end
end

function SWEP:DrawHUD()
    if not self.IsFlying then return end
    
    local scrW, scrH = ScrW(), ScrH()
    local ply = LocalPlayer()
    
    -- Indicateur de vol
    draw.SimpleText("EN VOL", "DermaLarge", scrW / 2, scrH - 100, Color(52, 152, 219), TEXT_ALIGN_CENTER)
    
    if ply:KeyDown(IN_SPEED) then
        draw.SimpleText("BOOST", "DermaDefault", scrW / 2, scrH - 70, Color(241, 196, 15), TEXT_ALIGN_CENTER)
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                        DCUO FLIGHT SWEP                           ║
-- ║         SWEP de vol utilisant les fonctionnalités GMod            ║
-- ╚═══════════════════════════════════════════════════════════════════╝

SWEP.PrintName = "Vol"
SWEP.Author = "DCUO-RP"
SWEP.Instructions = "Clic gauche: Voler\nClic droit: Atterrir"
SWEP.Category = "DCUO-RP"

SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 0

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.UseHands = true

-- Icône
SWEP.IconOverride = "materials/icon16/arrow_up.png"

-- Vitesse de vol
local FLIGHT_SPEED = 500
local FLIGHT_ACCELERATION = 20
local MAX_HEIGHT = 10000    -- Hauteur maximale

function SWEP:Initialize()
    self:SetHoldType("normal")
    self.ActivationHeight = nil  -- Hauteur à laquelle le vol a été activé
end

function SWEP:Deploy()
    return true
end

function SWEP:PrimaryAttack()
    if CLIENT then return end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return end
    
    -- Activer le vol (noclip)
    if ply:GetMoveType() ~= MOVETYPE_NOCLIP then
        -- Enregistrer la hauteur d'activation
        self.ActivationHeight = ply:GetPos().z
        
        ply:SetMoveType(MOVETYPE_NOCLIP)
        DCUO.Notify(ply, "Vol activé (hauteur minimale: " .. math.Round(self.ActivationHeight) .. ")", DCUO.Colors.Success)
        
        -- Effet sonore
        ply:EmitSound("ambient/wind/wind_hit1.wav", 50, 120)
    end
end

function SWEP:SecondaryAttack()
    if CLIENT then return end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return end
    
    -- Désactiver le vol
    if ply:GetMoveType() == MOVETYPE_NOCLIP then
        ply:SetMoveType(MOVETYPE_WALK)
        DCUO.Notify(ply, "Atterrissage", DCUO.Colors.Info)
        
        -- Réinitialiser la hauteur d'activation
        self.ActivationHeight = nil
        
        -- Effet sonore
        ply:EmitSound("ambient/wind/wind_hit1.wav", 50, 120)
    end
    
    self:SetNextSecondaryFire(CurTime() + 1)
end

function SWEP:Think()
    if CLIENT then return end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return end
    
    -- Limiter la vitesse de vol
    if ply:GetMoveType() == MOVETYPE_NOCLIP then
        local vel = ply:GetVelocity()
        if vel:Length() > FLIGHT_SPEED then
            ply:SetVelocity(vel:GetNormalized() * FLIGHT_SPEED - vel)
        end
        
        -- Limites de hauteur
        local pos = ply:GetPos()
        
        -- Vérifier hauteur minimale (basée sur l'activation)
        if self.ActivationHeight and pos.z < self.ActivationHeight then
            pos.z = self.ActivationHeight
            ply:SetPos(pos)
            ply:SetVelocity(Vector(vel.x, vel.y, 0))  -- Annuler la vélocité verticale
        end
        
        -- Vérifier hauteur maximale
        if pos.z > MAX_HEIGHT then
            pos.z = MAX_HEIGHT
            ply:SetPos(pos)
            ply:SetVelocity(Vector(vel.x, vel.y, 0))  -- Annuler la vélocité verticale
            DCUO.Notify(ply, "Altitude maximale atteinte !", DCUO.Colors.Warning)
        end
    end
end

function SWEP:OnRemove()
    if CLIENT then return end
    
    local ply = self:GetOwner()
    if IsValid(ply) and ply:GetMoveType() == MOVETYPE_NOCLIP then
        -- Remettre en mode normal
        ply:SetMoveType(MOVETYPE_WALK)
    end
end

function SWEP:Holster()
    if CLIENT then return end
    
    local ply = self:GetOwner()
    if IsValid(ply) and ply:GetMoveType() == MOVETYPE_NOCLIP then
        -- Remettre en mode normal si on change d'arme
        ply:SetMoveType(MOVETYPE_WALK)
    end
    
    return true
end

-- Effet visuel de vol (client)
if CLIENT then
    function SWEP:DrawWorldModel()
        -- Invisible
    end
    
    -- Dessiner le HUD d'instructions
    function SWEP:DrawHUD()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local scrW, scrH = ScrW(), ScrH()
        local isFlying = ply:GetMoveType() == MOVETYPE_NOCLIP
        
        -- Panneau d'instructions
        local panelW = 300
        local panelH = isFlying and 100 or 80
        local panelX = scrW - panelW - 20
        local panelY = scrH / 2 - panelH / 2
        
        -- Fond
        draw.RoundedBox(8, panelX, panelY, panelW, panelH, Color(20, 20, 30, 220))
        surface.SetDrawColor(100, 150, 255, 150)
        surface.DrawOutlinedRect(panelX, panelY, panelW, panelH, 2)
        
        -- Titre
        local titleColor = isFlying and Color(100, 255, 100) or Color(150, 150, 150)
        draw.SimpleText("VOL", "DermaDefaultBold", panelX + panelW/2, panelY + 15, titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Instructions
        local y = panelY + 40
        if isFlying then
            draw.SimpleText("Statut: EN VOL", "DermaDefault", panelX + panelW/2, y, Color(100, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            y = y + 20
            draw.SimpleText("Clic Droit: Atterrir", "DermaDefault", panelX + panelW/2, y, Color(255, 200, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("Statut: AU SOL", "DermaDefault", panelX + panelW/2, y, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            y = y + 20
            draw.SimpleText("Clic Gauche: Décoller", "DermaDefault", panelX + panelW/2, y, Color(100, 200, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    local nextParticle = 0
    
    function SWEP:Think()
        local ply = self:GetOwner()
        if not IsValid(ply) then return end
        
        -- Particules de vol
        if ply:GetMoveType() == MOVETYPE_NOCLIP and CurTime() > nextParticle then
            nextParticle = CurTime() + 0.1
            
            local pos = ply:GetPos()
            local emitter = ParticleEmitter(pos)
            if emitter then
                local particle = emitter:Add("effects/softglow", pos + Vector(0, 0, -20))
                if particle then
                    particle:SetVelocity(Vector(0, 0, -50))
                    particle:SetDieTime(0.5)
                    particle:SetStartAlpha(100)
                    particle:SetEndAlpha(0)
                    particle:SetStartSize(20)
                    particle:SetEndSize(5)
                    particle:SetColor(100, 150, 255)
                end
                emitter:Finish()
            end
        end
    end
end

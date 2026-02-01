--[[
═══════════════════════════════════════════════════════════════════
    DCUO-RP - Bouclier avec Cooldown
    Wrapper pour weapon_shield_activator avec limite d'utilisation
═══════════════════════════════════════════════════════════════════
--]]

if SERVER then
    AddCSLuaFile()
end

SWEP.PrintName = "Bouclier d'Énergie"
SWEP.Author = "DCUO-RP"
SWEP.Instructions = "Clic gauche pour activer (10s max, 1min cooldown)"
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

SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.UseHands = true

-- Cooldown settings
SWEP.MaxDuration = 10  -- 10 secondes max
SWEP.Cooldown = 60     -- 1 minute de cooldown

function SWEP:Initialize()
    self:SetHoldType("normal")
    
    if SERVER then
        self.NextUse = 0
        self.ShieldActive = false
        self.ShieldStartTime = 0
        self.RealShield = nil
    end
end

function SWEP:PrimaryAttack()
    if CLIENT then return end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return end
    
    local curTime = CurTime()
    
    -- Vérifier le cooldown
    if curTime < self.NextUse then
        local remaining = math.ceil(self.NextUse - curTime)
        ply:ChatPrint("[BOUCLIER] Cooldown: " .. remaining .. "s restantes")
        return
    end
    
    -- Si le bouclier est actif, le désactiver
    if self.ShieldActive then
        self:DeactivateShield(ply)
        return
    end
    
    -- Activer le bouclier
    self:ActivateShield(ply)
    
    self:SetNextPrimaryFire(curTime + 0.5)
end

function SWEP:ActivateShield(ply)
    if not IsValid(ply) then return end
    
    -- Donner le vrai SWEP du bouclier
    local shield = ply:Give("weapon_shield_activator", true)
    if IsValid(shield) then
        self.RealShield = shield
        self.ShieldActive = true
        self.ShieldStartTime = CurTime()
        
        ply:ChatPrint("[BOUCLIER] Activé ! (10 secondes max)")
        ply:SelectWeapon("weapon_shield_activator")
    end
end

function SWEP:DeactivateShield(ply)
    if not IsValid(ply) then return end
    
    -- Retirer le bouclier
    if IsValid(self.RealShield) then
        ply:StripWeapon("weapon_shield_activator")
    end
    
    self.ShieldActive = false
    self.NextUse = CurTime() + self.Cooldown
    
    ply:ChatPrint("[BOUCLIER] Désactivé ! Cooldown: 60 secondes")
    ply:SelectWeapon("dcuo_shield_wrapper")
end

function SWEP:Think()
    if CLIENT then return end
    if not self.ShieldActive then return end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return end
    
    local elapsed = CurTime() - self.ShieldStartTime
    
    -- Désactiver automatiquement après 10 secondes
    if elapsed >= self.MaxDuration then
        self:DeactivateShield(ply)
        ply:ChatPrint("[BOUCLIER] Durée maximum atteinte !")
    end
    
    self:NextThink(CurTime() + 0.1)
    return true
end

function SWEP:Holster()
    -- Permettre de changer d'arme
    return true
end

function SWEP:OnRemove()
    if SERVER and self.ShieldActive then
        local ply = self:GetOwner()
        if IsValid(ply) then
            self:DeactivateShield(ply)
        end
    end
end

function SWEP:DrawHUD()
    local scrW, scrH = ScrW(), ScrH()
    local ply = LocalPlayer()
    
    if not IsValid(ply) or ply:GetActiveWeapon() ~= self then return end
    
    local curTime = CurTime()
    
    -- Afficher le cooldown
    if curTime < (self.NextUse or 0) then
        local remaining = math.ceil((self.NextUse or 0) - curTime)
        draw.SimpleText("Cooldown: " .. remaining .. "s", "DermaLarge", scrW / 2, scrH - 100, Color(231, 76, 60), TEXT_ALIGN_CENTER)
    else
        draw.SimpleText("Bouclier: PRÊT", "DermaLarge", scrW / 2, scrH - 100, Color(46, 204, 113), TEXT_ALIGN_CENTER)
    end
    
    -- Si actif, afficher le temps restant
    if self.ShieldActive then
        local elapsed = curTime - (self.ShieldStartTime or 0)
        local remaining = math.max(0, self.MaxDuration - elapsed)
        draw.SimpleText(string.format("Actif: %.1fs", remaining), "DermaDefault", scrW / 2, scrH - 70, Color(52, 152, 219), TEXT_ALIGN_CENTER)
    end
end

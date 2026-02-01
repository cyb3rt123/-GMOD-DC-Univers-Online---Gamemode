--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Cinématiques (Server)
    Gestion serveur des cinématiques
═══════════════════════════════════════════════════════════════════════
--]]

if CLIENT then return end

DCUO.Cinematics = DCUO.Cinematics or {}

-- Lancer une cinématique pour un joueur
function DCUO.Cinematics.Play(ply, cinematicID)
    if not IsValid(ply) then return end
    
    -- Marquer le joueur comme étant en cinématique
    ply.InCinematic = true
    
    -- Rendre le joueur invisible
    ply:SetNoDraw(true)
    ply:SetNotSolid(true)
    
    -- Bloquer les mouvements
    ply:Freeze(true)
    
    net.Start("DCUO:StartCinematic")
        net.WriteString(cinematicID or "intro")
    net.Send(ply)
end

-- Lancer une cinématique globale
function DCUO.Cinematics.PlayGlobal(cinematicID)
    net.Start("DCUO:StartCinematic")
        net.WriteString(cinematicID or "intro")
    net.Broadcast()
end

-- Terminer la cinématique pour un joueur
function DCUO.Cinematics.End(ply)
    if not IsValid(ply) then return end
    
    ply.InCinematic = false
    
    -- Rendre le joueur visible
    ply:SetNoDraw(false)
    ply:SetNotSolid(false)
    
    -- Débloquer les mouvements
    ply:Freeze(false)
end

-- Network receiver pour quand le client termine la cinématique
net.Receive("DCUO:EndCinematic", function(len, ply)
    DCUO.Cinematics.End(ply)
end)

-- Hook pour bloquer les mouvements pendant la cinématique
hook.Add("PlayerNoClip", "DCUO:BlockNoclipInCinematic", function(ply)
    if ply.InCinematic then
        return false
    end
end)

hook.Add("SetupMove", "DCUO:BlockMovementInCinematic", function(ply, mv, cmd)
    if ply.InCinematic then
        mv:SetForwardSpeed(0)
        mv:SetSideSpeed(0)
        mv:SetUpSpeed(0)
        mv:SetButtons(0)
    end
end)

hook.Add("PlayerSwitchWeapon", "DCUO:BlockWeaponSwitchInCinematic", function(ply, oldWep, newWep)
    if ply.InCinematic then
        return true
    end
end)

hook.Add("CanPlayerSuicide", "DCUO:BlockSuicideInCinematic", function(ply)
    if ply.InCinematic then
        return false
    end
end)

DCUO.Log("Cinematics system (server) loaded", "SUCCESS")

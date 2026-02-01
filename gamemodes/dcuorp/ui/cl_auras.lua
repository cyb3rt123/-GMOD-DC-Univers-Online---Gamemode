--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système d'Auras (Client)
    Rendu des auras et effets visuels
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

DCUO.Auras = DCUO.Auras or {}

-- Table des effets actifs
local activeAuras = {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    ACTIVER UNE AURA SUR UN JOUEUR                 ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Auras.Activate(ply, auraId)
    if not IsValid(ply) then return end
    
    -- Désactiver l'aura précédente
    DCUO.Auras.Deactivate(ply)
    
    if auraId == "none" then return end
    
    local aura = DCUO.Auras.Get(auraId)
    if not aura then return end
    
    -- Stocker l'aura active
    activeAuras[ply] = {
        id = auraId,
        aura = aura,
        startTime = CurTime(),
    }
    
    DCUO.Log("Aura activated for " .. ply:Nick() .. ": " .. auraId, "INFO")
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    DÉSACTIVER UNE AURA                            ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Auras.Deactivate(ply)
    if activeAuras[ply] then
        activeAuras[ply] = nil
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    RENDU DES AURAS                                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("PostPlayerDraw", "DCUO:RenderAuras", function(ply)
    if not IsValid(ply) then return end
    if not activeAuras[ply] then return end
    
    local auraData = activeAuras[ply]
    local aura = auraData.aura
    local time = CurTime() - auraData.startTime
    
    local pos = ply:GetPos() + Vector(0, 0, 40)
    local bonePos = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Spine2") or 0)
    if bonePos then
        pos = bonePos
    end
    
    -- Rendu selon le type d'effet
    if aura.effect == "electric" then
        DCUO.Auras.RenderElectric(ply, pos, aura, time)
    elseif aura.effect == "fire" then
        DCUO.Auras.RenderFire(ply, pos, aura, time)
    elseif aura.effect == "glow" then
        DCUO.Auras.RenderGlow(ply, pos, aura, time)
    elseif aura.effect == "smoke" then
        DCUO.Auras.RenderSmoke(ply, pos, aura, time)
    elseif aura.effect == "sparkles" then
        DCUO.Auras.RenderSparkles(ply, pos, aura, time)
    elseif aura.effect == "legendary" then
        DCUO.Auras.RenderLegendary(ply, pos, aura, time)
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    EFFETS ÉLECTRIQUES                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Auras.RenderElectric(ply, pos, aura, time)
    -- Particules d'éclairs aléatoires
    if math.random(1, 3) == 1 then
        local effectData = EffectData()
        effectData:SetOrigin(pos + VectorRand() * 20)
        effectData:SetScale(0.5)
        effectData:SetMagnitude(1)
        util.Effect("TeslaHitBoxes", effectData)
    end
    
    -- Lueur
    local dlight = DynamicLight(ply:EntIndex())
    if dlight then
        dlight.pos = pos
        dlight.r = aura.color.r
        dlight.g = aura.color.g
        dlight.b = aura.color.b
        dlight.brightness = 2
        dlight.Decay = 1000
        dlight.Size = 128
        dlight.DieTime = CurTime() + 0.1
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    EFFETS DE FEU                                  ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Auras.RenderFire(ply, pos, aura, time)
    -- Particules de feu
    if math.random(1, 2) == 1 then
        local emitter = ParticleEmitter(pos)
        if emitter then
            local particle = emitter:Add("effects/fire_cloud" .. math.random(1, 2), pos + VectorRand() * 15)
            if particle then
                particle:SetVelocity(Vector(0, 0, math.random(10, 30)))
                particle:SetDieTime(math.Rand(0.3, 0.6))
                particle:SetStartAlpha(200)
                particle:SetEndAlpha(0)
                particle:SetStartSize(math.random(5, 15))
                particle:SetEndSize(0)
                particle:SetColor(aura.color.r, aura.color.g, aura.color.b)
                particle:SetRoll(math.Rand(0, 360))
                particle:SetRollDelta(math.Rand(-2, 2))
            end
            emitter:Finish()
        end
    end
    
    -- Lueur
    local dlight = DynamicLight(ply:EntIndex())
    if dlight then
        dlight.pos = pos
        dlight.r = aura.color.r
        dlight.g = aura.color.g
        dlight.b = aura.color.b
        dlight.brightness = 2
        dlight.Decay = 1000
        dlight.Size = 150
        dlight.DieTime = CurTime() + 0.1
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    EFFETS DE LUEUR                                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Auras.RenderGlow(ply, pos, aura, time)
    -- Lueur dynamique pulsante
    local pulse = math.abs(math.sin(time * 2))
    
    local dlight = DynamicLight(ply:EntIndex())
    if dlight then
        dlight.pos = pos
        dlight.r = aura.color.r
        dlight.g = aura.color.g
        dlight.b = aura.color.b
        dlight.brightness = (aura.brightness or 3) * (0.5 + pulse * 0.5)
        dlight.Decay = 1000
        dlight.Size = 200 * (0.8 + pulse * 0.2)
        dlight.DieTime = CurTime() + 0.1
    end
    
    -- Particules brillantes
    if math.random(1, 5) == 1 then
        local emitter = ParticleEmitter(pos)
        if emitter then
            local particle = emitter:Add("effects/yellowflare", pos + VectorRand() * 25)
            if particle then
                particle:SetVelocity(VectorRand() * 20)
                particle:SetDieTime(math.Rand(0.5, 1))
                particle:SetStartAlpha(150)
                particle:SetEndAlpha(0)
                particle:SetStartSize(math.random(2, 5))
                particle:SetEndSize(0)
                particle:SetColor(aura.color.r, aura.color.g, aura.color.b)
            end
            emitter:Finish()
        end
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    EFFETS DE FUMÉE                                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Auras.RenderSmoke(ply, pos, aura, time)
    if math.random(1, 3) == 1 then
        local emitter = ParticleEmitter(pos)
        if emitter then
            local particle = emitter:Add("particle/smokesprites_000" .. math.random(1, 9), pos + VectorRand() * 10)
            if particle then
                particle:SetVelocity(Vector(0, 0, math.random(5, 15)))
                particle:SetDieTime(math.Rand(1, 2))
                particle:SetStartAlpha(100)
                particle:SetEndAlpha(0)
                particle:SetStartSize(math.random(10, 20))
                particle:SetEndSize(math.random(25, 35))
                particle:SetColor(aura.color.r, aura.color.g, aura.color.b)
                particle:SetRoll(math.Rand(0, 360))
                particle:SetRollDelta(math.Rand(-1, 1))
            end
            emitter:Finish()
        end
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    EFFETS D'ÉTINCELLES                            ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Auras.RenderSparkles(ply, pos, aura, time)
    if math.random(1, 2) == 1 then
        local emitter = ParticleEmitter(pos)
        if emitter then
            for i = 1, 2 do
                local particle = emitter:Add("effects/spark", pos + VectorRand() * 30)
                if particle then
                    particle:SetVelocity(VectorRand() * 50)
                    particle:SetDieTime(math.Rand(0.3, 0.8))
                    particle:SetStartAlpha(255)
                    particle:SetEndAlpha(0)
                    particle:SetStartSize(math.random(1, 3))
                    particle:SetEndSize(0)
                    particle:SetColor(aura.color.r, aura.color.g, aura.color.b)
                    particle:SetGravity(Vector(0, 0, -50))
                end
            end
            emitter:Finish()
        end
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    EFFETS LÉGENDAIRES                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Auras.RenderLegendary(ply, pos, aura, time)
    -- Combinaison de tous les effets
    DCUO.Auras.RenderGlow(ply, pos, aura, time)
    DCUO.Auras.RenderSparkles(ply, pos, aura, time)
    
    -- Anneau rotatif
    local radius = 40
    local angle = time * 2
    for i = 0, 7 do
        local a = angle + (i * math.pi / 4)
        local sparklePos = pos + Vector(math.cos(a) * radius, math.sin(a) * radius, 0)
        
        local emitter = ParticleEmitter(sparklePos)
        if emitter then
            local particle = emitter:Add("effects/yellowflare", sparklePos)
            if particle then
                particle:SetVelocity(Vector(0, 0, 0))
                particle:SetDieTime(0.1)
                particle:SetStartAlpha(200)
                particle:SetEndAlpha(0)
                particle:SetStartSize(5)
                particle:SetEndSize(0)
                particle:SetColor(aura.color.r, aura.color.g, aura.color.b)
            end
            emitter:Finish()
        end
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    NETWORK RECEIVERS                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

net.Receive("DCUO:EquipAura", function()
    local auraId = net.ReadString()
    DCUO.Auras.Activate(LocalPlayer(), auraId)
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    NETTOYAGE                                      ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("EntityRemoved", "DCUO:CleanupAuras", function(ent)
    if ent:IsPlayer() then
        DCUO.Auras.Deactivate(ent)
    end
end)

DCUO.Log("Auras client system loaded", "SUCCESS")

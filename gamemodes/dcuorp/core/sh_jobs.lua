--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Jobs
    Définition et gestion des jobs (super-héros/vilains)
═══════════════════════════════════════════════════════════════════════
--]]

DCUO.Jobs = DCUO.Jobs or {}
DCUO.Jobs.List = DCUO.Jobs.List or {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    JOB PAR DÉFAUT                                 ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Jobs.List["Recrue"] = {
    name = "Recrue",
    description = "Un métahumain en formation du Programme Genesis",
    faction = {"Hero", "Villain", "Neutral"},  -- Disponible pour toutes les factions
    model = {
        "models/smalls_civilians/pack2/male/leatherjacket/male_08_leather_jacket_pm.mdl",
        "models/smalls_civilians/pack2/male/flannel/male_07_flannel_pm.mdl",
        "models/smalls_civilians/pack2/male/jacket_open/male_02_jacketopen_pm.mdl",
        "models/smalls_civilians/pack2/male/jacketvneck_sweatpants/male_03_jacketvneck_sweatpants_pm.mdl",
        "models/smalls_civilians/pack2/female/hoodiezippedjeans/female_02_hoodiezippedjeans_pm.mdl",
        "models/smalls_civilians/pack2/female/hoodiepulloversweats/female_06_hoodiepulloversweats_pm.mdl",
        "models/smalls_civilians/pack2/female/hoodiezippedjeans/female_03_hoodiezippedjeans_pm.mdl",
    },
    arms = "models/weapons/c_arms_citizen.mdl",
    color = DCUO.Colors.Neutral,
    weapons = {},
    powers = {},
    requirements = {
        level = 0,
        xp = 0,
        faction = nil,
    },
    salary = 0,
    maxHealth = 100,
    maxArmor = 0,
    walkSpeed = 150,
    runSpeed = 250,
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    JOBS HÉROS                                     ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Jobs.List["Flash"] = {
    name = "The Flash",
    description = "L'homme le plus rapide du monde",
    faction = {"Hero"},
    model = {
        "models/kryptonite/thefloosh/thefloosh.mdl",
    },
    arms = "models/weapons/c_arms_citizen.mdl",
    color = Color(220, 20, 20),
    weapons = {},
    powers = {"speedster", "tranquilizer"},  -- SWEPs Workshop Flash
    requirements = {
        level = 10,
        xp = 5000,
        faction = "Hero",
    },
    salary = 100,
    maxHealth = 150,
    maxArmor = 50,
    walkSpeed = 200,
    runSpeed = 300,  -- Le SWEP speedster gère la vitesse
}

DCUO.Jobs.List["Batman"] = {
    name = "Batman",
    description = "Le chevalier noir de Gotham",
    faction = {"Hero"},
    model = {
        "models/player/bobert/aobm.mdl",
    },
    arms = "models/weapons/aobm/aobm_arms.mdl",
    color = Color(30, 30, 30),
    weapons = {},
    powers = {"batman"},  -- SWEP Workshop Batman
    requirements = {
        level = 15,
        xp = 10000,
        faction = "Hero",
        mission = "mission_gotham",
    },
    salary = 150,
    maxHealth = 120,
    maxArmor = 100,
    walkSpeed = 180,
    runSpeed = 300,
}

DCUO.Jobs.List["Superman"] = {
    name = "Superman",
    description = "L'Homme d'Acier",
    faction = {"Hero"},
    model = {
        "models/kryptonite/bvs_superman/inj_superman.mdl",
    },
    arms = "models/weapons/c_arms_citizen.mdl",
    color = Color(0, 0, 255),
    weapons = {},
    powers = {"superman", "flight"},  -- SWEP Workshop Superman + Vol
    requirements = {
        level = 30,
        xp = 50000,
        faction = "Hero",
    },
    salary = 200,
    maxHealth = 250,
    maxArmor = 150,
    walkSpeed = 200,
    runSpeed = 400,
}

DCUO.Jobs.List["WonderWoman"] = {
    name = "Wonder Woman",
    description = "La princesse amazone",
    faction = {"Hero"},
    model = {
        "models/player/wonderwoman.mdl",
    },
    arms = "models/weapons/c_arms_citizen.mdl",
    color = Color(220, 20, 60),
    weapons = {},
    powers = {"shield", "flight"},  -- Bouclier avec cooldown + Vol
    requirements = {
        level = 25,
        xp = 35000,
        faction = "Hero",
    },
    salary = 180,
    maxHealth = 200,
    maxArmor = 120,
    walkSpeed = 190,
    runSpeed = 350,
}

DCUO.Jobs.List["GreenLantern"] = {
    name = "Green Lantern",
    description = "Porteur de l'anneau vert",
    faction = {"Hero"},
    model = {
        "models/kryptonite/jordan/jordan.mdl",
    },
    arms = "models/weapons/c_arms_citizen.mdl",
    color = Color(0, 255, 0),
    weapons = {},
    powers = {"flight", "energy_construct", "energy_shield", "energy_blast"},
    requirements = {
        level = 20,
        xp = 25000,
        faction = "Hero",
    },
    salary = 160,
    maxHealth = 180,
    maxArmor = 100,
    walkSpeed = 185,
    runSpeed = 320,
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    JOBS VILAINS                                   ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Jobs.List["Joker"] = {
    name = "The Joker",
    description = "Le prince du crime",
    faction = {"Villain"},
    model = {
        "models/slow/arkham_cityum/jokcl/slow.mdl",
    },
    arms = "models/weapons/c_arms_citizen.mdl",
    color = Color(128, 0, 128),
    weapons = {"weapon_joker_gun"},
    powers = {"laughing_gas", "explosive_joy", "chaos"},
    requirements = {
        level = 15,
        xp = 10000,
        faction = "Villain",
    },
    salary = 150,
    maxHealth = 100,
    maxArmor = 50,
    walkSpeed = 175,
    runSpeed = 280,
}

DCUO.Jobs.List["LexLuthor"] = {
    name = "Lex Luthor",
    description = "Le génie criminel",
    faction = {"Villain"},
    model = {
        "models/lexcorp/luthor.mdl",
    },
    arms = "models/weapons/c_arms_citizen.mdl",
    color = Color(0, 128, 0),
    weapons = {"weapon_lexcorp_gun"},
    powers = {"power_armor", "kryptonite_blast", "energy_shield"},
    requirements = {
        level = 30,
        xp = 50000,
        faction = "Villain",
    },
    salary = 200,
    maxHealth = 150,
    maxArmor = 200,
    walkSpeed = 160,
    runSpeed = 250,
}

DCUO.Jobs.List["Harley"] = {
    name = "Harley Quinn",
    description = "La reine de la folie",
    faction = {"Villain"},
    model = {
        "models/konnie/asapgaming/fortnite/harleyquinn.mdl",
    },
    arms = "models/weapons/arms/v_arms_harleyquinn.mdl",
    color = Color(255, 20, 147),
    weapons = {"weapon_baseballbat"},
    powers = {"acrobatics", "explosive_surprise", "charm"},
    requirements = {
        level = 12,
        xp = 7500,
        faction = "Villain",
    },
    salary = 120,
    maxHealth = 110,
    maxArmor = 60,
    walkSpeed = 180,
    runSpeed = 320,
}

DCUO.Jobs.List["Deathstroke"] = {
    name = "Deathstroke",
    description = "Le mercenaire ultime",
    faction = {"Villain", "Neutral"},
    model = {
        "models/player/deathstroke.mdl",
    },
    arms = "models/weapons/c_arms_citizen.mdl",
    color = Color(255, 140, 0),
    weapons = {"weapon_katana", "weapon_ar2"},
    powers = {"enhanced_reflexes", "tactical_vision", "regeneration"},
    requirements = {
        level = 25,
        xp = 35000,
        faction = nil,
    },
    salary = 180,
    maxHealth = 180,
    maxArmor = 120,
    walkSpeed = 185,
    runSpeed = 330,
}

DCUO.Jobs.List["Doomsday"] = {
    name = "Doomsday",
    description = "La machine à tuer ultime",
    faction = {"Villain"},
    model = {
        "models/player/captainpawn/doomsday.mdl",
    },
    arms = "models/weapons/c_doomsday_arms.mdl",
    color = Color(120, 120, 120),
    weapons = {},
    powers = {"super_strength", "regeneration", "berserker_rage"},
    requirements = {
        level = 35,
        xp = 60000,
        faction = "Villain",
    },
    salary = 250,
    maxHealth = 300,
    maxArmor = 150,
    walkSpeed = 180,
    runSpeed = 320,
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONCTIONS JOBS                                 ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Récupérer un job
function DCUO.Jobs.Get(jobID)
    return DCUO.Jobs.List[jobID]
end

-- Récupérer tous les jobs
function DCUO.Jobs.GetAll()
    return DCUO.Jobs.List
end

-- Récupérer les jobs disponibles pour une faction
function DCUO.Jobs.GetByFaction(faction)
    local jobs = {}
    
    for id, job in pairs(DCUO.Jobs.List) do
        if table.HasValue(job.faction, faction) or job.faction == nil then
            jobs[id] = job
        end
    end
    
    return jobs
end

-- Vérifier si un joueur peut avoir un job
function DCUO.Jobs.CanHaveJob(ply, jobID)
    if not IsValid(ply) or not ply.DCUOData then return false end
    
    local job = DCUO.Jobs.Get(jobID)
    if not job then return false end
    
    local data = ply.DCUOData
    
    -- Vérifier le niveau
    if job.requirements.level and data.level < job.requirements.level then
        return false, "Niveau insuffisant (requis: " .. job.requirements.level .. ")"
    end
    
    -- Note: On ne vérifie plus l'XP totale car elle est remise à 0 à chaque level up
    -- Le niveau est suffisant pour déterminer l'accès aux jobs
    
    -- Vérifier la faction
    if job.requirements.faction and data.faction ~= job.requirements.faction then
        return false, "Faction incorrecte"
    end
    
    -- Vérifier la mission spéciale
    if job.requirements.mission then
        if not data.missions or not table.HasValue(data.missions, job.requirements.mission) then
            return false, "Mission spéciale requise"
        end
    end
    
    return true
end

-- Définir le job d'un joueur (serveur uniquement)
if SERVER then
    function DCUO.Jobs.SetJob(ply, jobID)
        if not IsValid(ply) or not ply.DCUOData then return false end
        
        local job = DCUO.Jobs.Get(jobID)
        if not job then
            DCUO.Notify(ply, "Ce job n'existe pas", DCUO.Colors.Error)
            return false
        end
        
        local canHave, reason = DCUO.Jobs.CanHaveJob(ply, jobID)
        if not canHave then
            DCUO.Notify(ply, reason or "Vous ne pouvez pas avoir ce job", DCUO.Colors.Error)
            return false
        end
        
        -- Changer le job
        ply.DCUOData.job = jobID
        
        -- Réinitialiser le pouvoir (important pour actualiser les pouvoirs disponibles)
        ply.DCUOData.power = nil
        
        -- Appliquer les propriétés du job
        if job.model then
            local model = job.model
            if istable(model) then
                model = table.Random(model)
            end
            ply:SetModel(model)
        end
        
        ply:SetHealth(job.maxHealth or 100)
        ply:SetArmor(job.maxArmor or 0)
        ply:SetMaxHealth(job.maxHealth or 100)
        ply:SetRunSpeed(job.runSpeed or 250)
        ply:SetWalkSpeed(job.walkSpeed or 150)
        
        -- Donner les armes
        ply:StripWeapons()
        if job.weapons then
            for _, weapon in ipairs(job.weapons) do
                ply:Give(weapon)
            end
        end
        
        -- Sauvegarder
        DCUO.Database.SavePlayer(ply)
        
        -- Notifier
        DCUO.Notify(ply, "Vous êtes maintenant : " .. job.name, DCUO.Colors.Success)
        DCUO.NotifyAll(ply:Nick() .. " est devenu " .. job.name, job.color)
        
        -- Envoyer au client
        net.Start("DCUO:JobChange")
            net.WriteString(jobID)
        net.Send(ply)
        
        -- Envoyer les données complètes pour mettre à jour l'UI
        net.Start("DCUO:PlayerData")
            net.WriteTable(ply.DCUOData)
        net.Send(ply)
        
        return true
    end
    
    -- Handler réseau pour le changement de job
    net.Receive("DCUO:JobChange", function(len, ply)
        local jobID = net.ReadString()
        DCUO.Jobs.SetJob(ply, jobID)
    end)
end

DCUO.Log("Jobs system loaded (" .. table.Count(DCUO.Jobs.List) .. " jobs)", "SUCCESS")

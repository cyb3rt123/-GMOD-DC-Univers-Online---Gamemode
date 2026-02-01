-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    PLAYERMODEL ARMS SYSTEM                        ║
-- ║        Gestion automatique des viewmodels de mains par job       ║
-- ╚═══════════════════════════════════════════════════════════════════╝

if CLIENT then return end

-- Network string pour envoyer les arms au client
util.AddNetworkString("DCUO_SetPlayerArms")

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     FONCTIONS ARMS                                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Récupérer les arms d'un job
function DCUO.GetJobArms(jobID)
    if not jobID then return DCUO.Config.DefaultArms end
    
    -- Vérifier dans la config des arms personnalisés
    if DCUO.Config.JobArms and DCUO.Config.JobArms[jobID] then
        return DCUO.Config.JobArms[jobID]
    end
    
    -- Vérifier dans la définition du job
    local job = DCUO.Jobs.Get(jobID)
    if job and job.arms then
        return job.arms
    end
    
    -- Par défaut, arms GMod standard
    return DCUO.Config.DefaultArms or "models/weapons/c_arms_citizen.mdl"
end

-- Appliquer les arms à un joueur
function DCUO.ApplyPlayerArms(ply, jobID)
    if not IsValid(ply) then return end
    
    jobID = jobID or (ply.DCUOData and ply.DCUOData.job) or "Recrue"
    
    local armsModel = DCUO.GetJobArms(jobID)
    
    -- Stocker sur le joueur pour référence
    ply.DCUOArmsModel = armsModel
    
    -- Envoyer au client
    net.Start("DCUO_SetPlayerArms")
    net.WriteString(armsModel)
    net.Send(ply)
    
    DCUO.Log(string.format("Applied arms to %s: %s", ply:Nick(), armsModel), "INFO")
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                          HOOKS                                    ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Appliquer les arms au spawn
hook.Add("PlayerSpawn", "DCUO_ApplyArms", function(ply)
    timer.Simple(0.1, function()
        if IsValid(ply) then
            DCUO.ApplyPlayerArms(ply)
        end
    end)
end)

-- Appliquer les arms quand le job change
hook.Add("DCUO_PlayerJobChanged", "DCUO_ApplyArms", function(ply, newJob, oldJob)
    DCUO.ApplyPlayerArms(ply, newJob)
end)

-- Appliquer les arms à la connexion
hook.Add("PlayerInitialSpawn", "DCUO_ApplyArms", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) then
            DCUO.ApplyPlayerArms(ply)
        end
    end)
end)

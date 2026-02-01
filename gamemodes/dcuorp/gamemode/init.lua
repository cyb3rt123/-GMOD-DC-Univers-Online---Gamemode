--[[
═══════════════════════════════════════════════════════════════════════
    DC UNIVERSE ONLINE ROLEPLAY (DCUO-RP)
    Server-Side Initialization
═══════════════════════════════════════════════════════════════════════
--]]

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CHARGEMENT DES MODULES                         ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Log("=== Starting Server-Side Initialization ===", "INFO")

-- Charger les configurations
DCUO.IncludeFile("dcuorp/core/sh_config.lua", "shared")
DCUO.IncludeFile("dcuorp/config/colors.lua", "shared")
DCUO.IncludeFile("dcuorp/config/playermodels.lua", "shared")
DCUO.IncludeFile("dcuorp/config/weapons.lua", "shared")

-- Charger les systèmes Core
DCUO.IncludeFile("dcuorp/core/sv_database.lua", "server")
DCUO.IncludeFile("dcuorp/core/sh_factions.lua", "shared")
DCUO.IncludeFile("dcuorp/core/sh_jobs.lua", "shared")
DCUO.IncludeFile("dcuorp/core/sh_xp.lua", "shared")
DCUO.IncludeFile("dcuorp/core/sv_xp.lua", "server")
DCUO.IncludeFile("dcuorp/core/sh_missions.lua", "shared")
DCUO.IncludeFile("dcuorp/core/sv_missions.lua", "server")

-- Système de Guildes
DCUO.IncludeFile("dcuorp/core/sh_guilds.lua", "shared")
DCUO.IncludeFile("dcuorp/core/sv_guilds.lua", "server")

-- Système de Succès
DCUO.IncludeFile("dcuorp/core/sh_achievements.lua", "shared")
DCUO.IncludeFile("dcuorp/core/sv_achievements.lua", "server")

-- Charger les systèmes
DCUO.IncludeFile("dcuorp/systems/sv_cinematics.lua", "server")
DCUO.IncludeFile("dcuorp/systems/sv_events.lua", "server")
DCUO.IncludeFile("dcuorp/systems/sv_shop.lua", "server")
DCUO.IncludeFile("dcuorp/systems/sv_shop_npc.lua", "server")
DCUO.IncludeFile("dcuorp/systems/sv_powers.lua", "server")
DCUO.IncludeFile("dcuorp/systems/sh_powers.lua", "shared")
DCUO.IncludeFile("dcuorp/systems/sv_admin.lua", "server")
DCUO.IncludeFile("dcuorp/systems/sh_auras.lua", "shared")
DCUO.IncludeFile("dcuorp/systems/sv_auras.lua", "server")

-- Système de Chat
DCUO.IncludeFile("dcuorp/systems/sh_chat.lua", "shared")
DCUO.IncludeFile("dcuorp/systems/sv_chat.lua", "server")
DCUO.IncludeFile("dcuorp/systems/cl_chat.lua", "client")

-- Combat & PvP
DCUO.IncludeFile("dcuorp/systems/sh_scaling.lua", "shared")
DCUO.IncludeFile("dcuorp/systems/sv_scaling.lua", "server")
DCUO.IncludeFile("dcuorp/systems/sh_stamina.lua", "shared")
DCUO.IncludeFile("dcuorp/systems/sv_stamina.lua", "server")
DCUO.IncludeFile("dcuorp/systems/sv_pvp.lua", "server")

-- Playermodel Arms
DCUO.IncludeFile("dcuorp/systems/sv_arms.lua", "server")
DCUO.IncludeFile("dcuorp/systems/cl_arms.lua", "client")

-- Boss & Events
DCUO.IncludeFile("dcuorp/systems/sh_bosses.lua", "shared")
DCUO.IncludeFile("dcuorp/systems/sv_bosses.lua", "server")
DCUO.IncludeFile("dcuorp/systems/sv_random_events.lua", "server")

-- Duel & Friends
DCUO.IncludeFile("dcuorp/systems/sh_duel.lua", "shared")
DCUO.IncludeFile("dcuorp/systems/sv_duel.lua", "server")
DCUO.IncludeFile("dcuorp/systems/cl_duel.lua", "client")
DCUO.IncludeFile("dcuorp/systems/sv_friends.lua", "server")
DCUO.IncludeFile("dcuorp/systems/cl_friends.lua", "client")

-- Charger l'UI (client)
DCUO.IncludeFile("dcuorp/ui/cl_hud.lua", "client")
DCUO.IncludeFile("dcuorp/ui/cl_menus.lua", "client")
DCUO.IncludeFile("dcuorp/ui/cl_character_creator.lua", "client")
DCUO.IncludeFile("dcuorp/ui/cl_auras.lua", "client")
DCUO.IncludeFile("dcuorp/ui/cl_overhead.lua", "client")
DCUO.IncludeFile("dcuorp/ui/cl_aura_shop.lua", "client")
DCUO.IncludeFile("dcuorp/ui/cl_admin_panel.lua", "client")
DCUO.IncludeFile("dcuorp/ui/cl_notifications.lua", "client")
DCUO.IncludeFile("dcuorp/ui/cl_cinematics.lua", "client")
DCUO.IncludeFile("dcuorp/ui/cl_healthbars.lua", "client")
DCUO.IncludeFile("dcuorp/ui/cl_boss_hud.lua", "client")
DCUO.IncludeFile("dcuorp/ui/cl_stamina_hud.lua", "client")
DCUO.IncludeFile("dcuorp/ui/cl_player_interaction.lua", "client")
-- DCUO.IncludeFile("dcuorp/ui/cl_ambient_music_server.lua", "client") -- Fichier supprimé
DCUO.IncludeFile("dcuorp/ui/cl_music_autoplay.lua", "client")
DCUO.IncludeFile("dcuorp/ui/cl_mission_hud.lua", "client")
DCUO.IncludeFile("dcuorp/ui/cl_mission_dialogue.lua", "client")
DCUO.IncludeFile("dcuorp/ui/cl_scoreboard.lua", "client")

-- UI Guildes (remplacées par cl_f2_redesign.lua dans autorun)
-- DCUO.IncludeFile("dcuorp/ui/cl_guild_menu.lua", "client") -- Fichier supprimé
-- DCUO.IncludeFile("dcuorp/ui/cl_guild_members.lua", "client") -- Fichier supprimé
-- DCUO.IncludeFile("dcuorp/ui/cl_guild_admin.lua", "client") -- Fichier supprimé

-- UI Menu F1 (remplacé par cl_f1_redesign.lua dans autorun)
-- DCUO.IncludeFile("dcuorp/ui/cl_f1_menu.lua", "client") -- Fichier supprimé
-- DCUO.IncludeFile("dcuorp/ui/cl_f1_panels.lua", "client") -- Fichier supprimé

-- UI NPC Boutique
DCUO.IncludeFile("dcuorp/ui/cl_shop_npc.lua", "client")

-- Menus F1/F2 depuis autorun
DCUO.IncludeFile("dcuorp/lua/autorun/client/cl_f1_simple.lua", "client")
DCUO.IncludeFile("dcuorp/lua/autorun/client/cl_f2_simple.lua", "client")

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    RESSOURCES À TÉLÉCHARGER                       ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Forcer le téléchargement des fichiers audio
resource.AddFile("sound/dcuo/ambient/metropolis.mp3")
resource.AddFile("sound/dcuo/ambient/gotham.mp3")
resource.AddFile("sound/dcuo/ambient/combat.mp3")

-- Télécharger l'addon de musique depuis le Workshop
-- Remplace l'ID par ton Workshop ID pour la musique
resource.AddWorkshop("TON_WORKSHOP_ID_ICI")

DCUO.Log("Resources added for download", "SUCCESS")

DCUO.Log("=== All Modules Loaded Successfully ===", "SUCCESS")

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    HOOKS PRINCIPAUX                               ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Initialisation du serveur
function GM:Initialize()
    DCUO.Log("Gamemode Initializing...", "INFO")
    
    -- Initialiser la base de données
    if DCUO.Database then
        DCUO.Database.Initialize()
    end
    
    DCUO.Log("Gamemode Initialized!", "SUCCESS")
end

-- Connexion d'un joueur
function GM:PlayerInitialSpawn(ply)
    DCUO.Log(ply:Nick() .. " is connecting...", "INFO")
    
    -- Initialiser DCUOData avec des valeurs par défaut valides pour éviter race condition
    ply.DCUOData = {
        steamID = ply:SteamID64(),
        rpname = "",
        firstname = "",
        lastname = "",
        age = 25,
        origin = "",
        faction = "Neutral",
        job = "Recrue",
        level = 1,
        xp = 0,
        maxXP = 100,
        totalPlaytime = 0,
        model = "",
        equippedAura = "none",
        auras = {},
        missions = {},
        purchases = {},
        achievements = {},
        achievement_points = 0,
        kills = 0,
        boss_kills = 0,
        deaths = 0,
        fall_deaths = 0,
        missions_completed = 0,
        playtime = 0,
        friends = {},
    }
    
    -- Initialiser les tables nécessaires
    ply.DCUOCooldowns = {}
    ply.DCUOActivePowers = {}
    
    -- Vérifier si le joueur a déjà un personnage
    timer.Simple(1, function()
        if IsValid(ply) then
            DCUO.Log("Loading player data for " .. ply:Nick(), "INFO")
            DCUO.Database.LoadPlayer(ply, function(hasCharacter)
                DCUO.Log(ply:Nick() .. " - Has character: " .. tostring(hasCharacter), "INFO")
                
                if not hasCharacter then
                    -- Première connexion : lancer la cinématique et le créateur de personnage
                    DCUO.Log(ply:Nick() .. " is a new player - Starting character creation", "INFO")
                    timer.Simple(0.5, function()
                        if IsValid(ply) then
                            net.Start("DCUO:StartCinematic")
                            net.Send(ply)
                            DCUO.Log("Cinematic message sent to " .. ply:Nick(), "SUCCESS")
                        end
                    end)
                else
                    -- Joueur existant : charger ses données
                    DCUO.Log(ply:Nick() .. " loaded successfully", "SUCCESS")
                end
            end)
        end
    end)
end

-- Réception de la demande d'ouverture du créateur de personnage
net.Receive("DCUO:OpenCharacterCreator", function(len, ply)
    if not IsValid(ply) then return end
    
    DCUO.Log(ply:Nick() .. " requested character creator", "INFO")
    
    -- Envoyer le signal au client pour ouvrir l'UI
    net.Start("DCUO:OpenCharacterCreator")
    net.Send(ply)
    
    DCUO.Log("Character creator UI sent to " .. ply:Nick(), "SUCCESS")
end)

-- Réception de la création de personnage
net.Receive("DCUO:CreateCharacter", function(len, ply)
    local data = net.ReadTable()
    
    if not IsValid(ply) or not data then return end
    
    -- Valider les données
    if not data.rpname or data.rpname == "" then
        DCUO.Notify(ply, "Nom invalide", DCUO.Colors.Error)
        return
    end
    
    -- Mettre à jour les données du joueur
    ply.DCUOData = ply.DCUOData or {}
    ply.DCUOData.rpname = data.rpname
    ply.DCUOData.firstname = data.firstname or ""
    ply.DCUOData.lastname = data.lastname or ""
    ply.DCUOData.age = data.age or 25
    ply.DCUOData.origin = data.origin or ""
    ply.DCUOData.faction = data.faction or "Neutral"
    ply.DCUOData.job = "Recrue"
    ply.DCUOData.level = 1
    ply.DCUOData.xp = 0
    ply.DCUOData.maxXP = DCUO.XP.CalculateXPNeeded(1)
    ply.DCUOData.steamID = ply:SteamID64()
    
    -- Choisir un model selon le sexe et la faction
    local models = DCUO.Config.Playermodels and DCUO.Config.Playermodels["Recrue"] or {
        "models/player/Group01/male_01.mdl",
        "models/player/Group01/female_01.mdl",
    }
    ply.DCUOData.model = table.Random(models)
    
    -- Sauvegarder dans la BDD
    DCUO.Database.SavePlayer(ply)
    
    -- Envoyer les données au client
    net.Start("DCUO:PlayerData")
        net.WriteTable(ply.DCUOData)
    net.Send(ply)
    
    -- Spawn le joueur
    ply:Spawn()
    
    DCUO.Log(ply:Nick() .. " created character: " .. data.rpname, "SUCCESS")
    DCUO.NotifyAll(data.rpname .. " a rejoint le Programme Genesis!", DCUO.Colors.Success)
end)

-- Spawn du joueur
function GM:PlayerSpawn(ply)
    -- Désactiver le sprint par défaut
    ply:SetRunSpeed(DCUO.Config.DefaultRunSpeed or 250)
    ply:SetWalkSpeed(DCUO.Config.DefaultWalkSpeed or 150)
    
    -- Donner les armes de base
    ply:StripWeapons()
    ply:Give("dcuo_hands")
    ply:Give("dcuo_phone")  -- Téléphone DCUO pour accéder aux menus
    
    -- Donner les SWEPs du job
    if ply.DCUOData and ply.DCUOData.job then
        local job = DCUO.Jobs.List[ply.DCUOData.job]
        if job and job.weapons then
            for _, weapon in ipairs(job.weapons) do
                ply:Give(weapon)
            end
        end
    end
    
    -- Appliquer le model du job
    if ply.DCUOData and ply.DCUOData.job then
        local job = DCUO.Jobs.List[ply.DCUOData.job]
        if job and job.model then
            local model = job.model
            if istable(model) then
                model = table.Random(model)
            end
            ply:SetModel(model)
            DCUO.Log(string.format("Applied model to %s: %s", ply:Nick(), model), "INFO")
        else
            -- Fallback: utiliser le model sauvegardé ou un modèle par défaut
            local model = ply.DCUOData.model or "models/player/Group01/male_01.mdl"
            ply:SetModel(model)
            DCUO.Log(string.format("Applied saved model to %s: %s", ply:Nick(), model), "INFO")
        end
    else
        -- Aucun job: utiliser le model sauvegardé ou par défaut
        local model = (ply.DCUOData and ply.DCUOData.model) or "models/player/Group01/male_01.mdl"
        ply:SetModel(model)
        DCUO.Log(string.format("Applied default model to %s: %s", ply:Nick(), model), "INFO")
    end
    
    -- Appliquer la couleur de faction
    if ply.DCUOData and ply.DCUOData.faction then
        local faction = DCUO.Factions.List[ply.DCUOData.faction]
        if faction then
            ply:SetPlayerColor(Vector(faction.color.r / 255, faction.color.g / 255, faction.color.b / 255))
        end
    end
end

-- Mort du joueur
function GM:PlayerDeath(victim, inflictor, attacker)
    if IsValid(victim) then
        -- Créer des ragdolls
        victim:CreateRagdoll()
        
        -- Message de mort
        if IsValid(attacker) and attacker:IsPlayer() and attacker ~= victim then
            DCUO.NotifyAll(victim:Nick() .. " a été éliminé par " .. attacker:Nick(), DCUO.Colors.Error)
        else
            DCUO.NotifyAll(victim:Nick() .. " est mort", DCUO.Colors.Error)
        end
    end
end

-- Respawn
function GM:PlayerDeathThink(ply)
    if ply:IsBot() then
        ply:Spawn()
        return false
    end
    
    -- Initialiser le timer de respawn à la mort
    if not ply.NextSpawnTime then
        ply.NextSpawnTime = CurTime() + 5
    end
    
    -- Bloquer le respawn pendant le délai
    if ply.NextSpawnTime > CurTime() then
        return false
    end
    
    -- Respawn automatique après 5 secondes
    ply.NextSpawnTime = nil  -- Reset pour la prochaine mort
    ply:Spawn()
    return false
end

-- Choisir le point de spawn
function GM:PlayerSelectSpawn(ply)
    -- Récupérer la faction du joueur
    local faction = (ply.DCUOData and ply.DCUOData.faction) or "Neutral"
    
    -- Récupérer les spawn points de la faction
    local spawnPoints = DCUO.Config.SpawnPoints[faction] or DCUO.Config.SpawnPoints.Neutral or {}
    
    if #spawnPoints > 0 then
        -- Choisir un spawn point aléatoire
        local spawnPos = table.Random(spawnPoints)
        
        -- Chercher une entité de spawn proche ou créer un point temporaire
        local spawnEntity = ents.Create("info_player_start")
        spawnEntity:SetPos(spawnPos)
        spawnEntity:Spawn()
        
        -- Retourner l'entité de spawn temporaire
        return spawnEntity
    end
    
    -- Fallback: utiliser les spawns par défaut de la map
    local spawns = ents.FindByClass("info_player_start")
    spawns = table.Add(spawns, ents.FindByClass("info_player_deathmatch"))
    spawns = table.Add(spawns, ents.FindByClass("info_player_terrorist"))
    spawns = table.Add(spawns, ents.FindByClass("info_player_counterterrorist"))
    
    if #spawns > 0 then
        return table.Random(spawns)
    end
    
    return nil
end

-- Loadout du joueur
function GM:PlayerLoadout(ply)
    -- Les armes sont gérées dans PlayerSpawn
    return true
end

-- Déconnexion
function GM:PlayerDisconnected(ply)
    DCUO.Log(ply:Nick() .. " disconnected", "INFO")
    
    -- Sauvegarder les données
    if DCUO.Database then
        DCUO.Database.SavePlayer(ply)
    end
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONCTIONS UTILITAIRES                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Notification à tous les joueurs
function DCUO.NotifyAll(message, color)
    color = color or DCUO.Colors.Light
    
    net.Start("DCUO:Notification")
        net.WriteString(message)
        net.WriteColor(color)
    net.Broadcast()
end

-- Notification à un joueur
function DCUO.Notify(ply, message, color)
    if not IsValid(ply) then return end
    
    color = color or DCUO.Colors.Light
    
    net.Start("DCUO:Notification")
        net.WriteString(message)
        net.WriteColor(color)
    net.Send(ply)
end

DCUO.Log("=== Server Initialization Complete ===", "SUCCESS")

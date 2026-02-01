--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Configuration Principale
    Fichier de configuration centralisé
═══════════════════════════════════════════════════════════════════════
--]]

DCUO.Config = DCUO.Config or {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CONFIGURATION GÉNÉRALE                         ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Config.ServerName = "DC Universe Online Roleplay"
DCUO.Config.ServerDescription = "Un serveur roleplay super-héros immersif"

-- Vitesses de déplacement par défaut
DCUO.Config.DefaultWalkSpeed = 150
DCUO.Config.DefaultRunSpeed = 250

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    SYSTÈME D'EXPÉRIENCE                           ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Niveau maximum
DCUO.Config.MaxLevel = 50

-- Formule de calcul XP pour level up
-- XP nécessaire = BaseXP * (Level ^ Multiplier)
DCUO.Config.XP = {
    BaseXP = 100,           -- XP de base pour le niveau 1
    Multiplier = 1.5,       -- Multiplicateur de progression
}

-- Gains d'XP
DCUO.Config.XPGains = {
    MissionComplete = 50,       -- XP pour une mission complétée
    EventParticipation = 25,    -- XP pour participation à un event
    KillNPC = 10,               -- XP pour tuer un NPC ennemi
    KillBoss = 100,             -- XP pour tuer un boss
    Roleplay = 5,               -- XP par minute de RP (si système de détection RP)
    Help = 15,                  -- XP pour aider d'autres joueurs
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    SYSTÈME DE SPAWN                               ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Config.SpawnPoints = {
    -- Points de spawn selon la faction
    Hero = {
        Vector(-1606.72, -2123.44, -127.97),
        -- Ajoutez vos positions ici
    },
    Villain = {
        Vector(-4315.50, -5974.72, -191.97),
        -- Ajoutez vos positions ici
    },
    Neutral = {
        Vector(-7462.72, -2652.72, -191.97),
        -- Ajoutez vos positions ici
    }
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    SPAWN POINTS BOSS & ÉVÉNEMENTS                 ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Points de spawn pour les BOSS (à configurer selon votre map)
DCUO.Config.BossSpawnPoints = {
    Vector(1000, 1000, 100),
    Vector(-1000, 1000, 100),
    Vector(1000, -1000, 100),
    Vector(-1000, -1000, 100),
    Vector(0, 2000, 100),
    Vector(2000, 0, 100),
    -- Ajoutez vos positions ici selon votre map
}

-- Points de spawn pour les ÉVÉNEMENTS NPCs aléatoires (agressions, vols, etc.)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    MESSAGES DU SYSTÈME                            ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Config.Messages = {
    PowerCooldown = "⏱ Cooldown: %d secondes restantes",
    InsufficientXP = "❌ XP insuffisante (requis: %d)",
    LevelUp = "🎉 NIVEAU %d ATTEINT !",
    InsufficientLevel = "❌ Niveau insuffisant (requis: %d)",
    MissionCompleted = "✅ Mission complétée: %s",
    MissionFailed = "❌ Mission échouée: %s",
    XPGained = "⭐ +%d XP (%s)",
    AuraEquipped = "✨ Aura équipée: %s",
    AuraPurchased = "🛒 Aura achetée: %s",
    PowerActivated = "⚡ Pouvoir activé: %s",
    GuildCreated = "🏛 Guilde créée: %s",
    GuildJoined = "✅ Vous avez rejoint: %s",
    GuildLeft = "👋 Vous avez quitté: %s",
    FactionChanged = "⚔ Faction changée: %s",
    JobChanged = "💼 Métier changé: %s",
}
DCUO.Config.EventSpawnPoints = {
    Vector(500, 500, 50),
    Vector(-500, 500, 50),
    Vector(500, -500, 50),
    Vector(-500, -500, 50),
    Vector(0, 1000, 50),
    Vector(1000, 0, 50),
    Vector(-1000, 0, 50),
    Vector(0, -1000, 50),
    -- Ajoutez vos positions ici selon votre map
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CINÉMATIQUE D'INTRODUCTION                     ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Config.Cinematic = {
    Enabled = true,
    Duration = 70,              -- Durée en secondes (1 minute 10 secondes)
    Message = [[Bienvenue, recrue.

Le monde a changé. Les lignes temporelles sont brisées.
Héros et vilains s'affrontent dans une guerre sans fin.

Le Programme Genesis a été créé pour former
une nouvelle génération de métahumains.

Votre voyage commence maintenant.

Ferez-vous le choix du bien... ou du mal ?]],
    
    -- MUSIQUE DE CINÉMATIQUE
    -- Choisir "mp3" ou "youtube"
    MusicType = "youtube",      -- "mp3" pour fichier local, "youtube" pour lien YouTube
    
    -- Pour MP3 : Mettre le chemin du fichier dans sound/
    -- Exemple: "sound/dcuo/intro.mp3" -> Music = "dcuo/intro.mp3"
    Music = "mDb7yu2blww",
    
    -- Pour YouTube : Mettre l'URL complète ou juste l'ID de la vidéo
    -- Exemples:
    -- Music = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    -- Music = "https://youtu.be/dQw4w9WgXcQ"
    -- Music = "dQw4w9WgXcQ"
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CONFIGURATION DU SHOP                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Config.Shop = {
    Enabled = true,
    
    -- Items achetables avec de l'XP
    Items = {
        -- Format:
        -- ["id_unique"] = {
        --     name = "Nom de l'item",
        --     description = "Description",
        --     cost = 500,  -- Coût en XP
        --     type = "skin" / "emote" / "power" / "job_unlock",
        --     icon = "materials/icon.png",
        -- }
    }
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CONFIGURATION DES POUVOIRS                     ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Config.Powers = {
    -- Cooldown global entre deux utilisations de pouvoir (secondes)
    GlobalCooldown = 1,
    
    -- Effets visuels activés
    EnableEffects = true,
    
    -- Sons activés
    EnableSounds = true,
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CONFIGURATION DES MISSIONS                     ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Config.Missions = {
    -- Temps entre deux spawns d'événements aléatoires (secondes)
    EventSpawnInterval = 300,  -- 5 minutes
    
    -- Nombre maximum d'événements actifs simultanément
    MaxActiveEvents = 3,
    
    -- Rayon de détection pour les missions
    MissionRadius = 500,
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CONFIGURATION ADMIN                            ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Config.Admin = {
    -- Groupes ULX autorisés à accéder au panel admin
    AllowedGroups = {
        "superadmin",
        "admin",
    },
    
    -- Logs des actions admin
    LogActions = true,
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CONFIGURATION HUD                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Config.HUD = {
    -- Position de la barre XP (x, y en pourcentage de l'écran)
    XPBarPos = {x = 0.5, y = 0.95},
    
    -- Taille de la barre XP
    XPBarSize = {w = 600, h = 30},
    
    -- Afficher la barre de stamina
    Stamina = true,
    
    -- Afficher la minimap
    ShowMinimap = false,
    
    -- Position de la minimap
    MinimapPos = {x = 0.9, y = 0.1},
    
    -- Taille de la minimap
    MinimapSize = 200,
    
    -- Afficher les informations du joueur
    ShowPlayerInfo = true,
    
    -- Position des infos joueur
    PlayerInfoPos = {x = 0.02, y = 0.02},
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    MESSAGES SYSTÈME                               ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Config.Messages = {
    Welcome = "Bienvenue sur %s !",
    FirstConnection = "Création de votre personnage en cours...",
    LevelUp = "LEVEL UP ! Vous êtes maintenant niveau %d !",
    JobUnlocked = "Nouveau job débloqué : %s",
    MissionComplete = "Mission terminée ! +%d XP",
    InsufficientXP = "XP insuffisante. Il vous faut %d XP.",
    PowerCooldown = "Pouvoir en rechargement... (%ds)",
}

DCUO.Log("Configuration loaded", "SUCCESS")

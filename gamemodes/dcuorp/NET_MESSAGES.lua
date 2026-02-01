-- NET MESSAGES DOCUMENTATION
-- Liste de tous les net messages et leur direction
-- REGLE: UN net message = UNE direction uniquement

--[[
═══════════════════════════════════════════════════════════════════════
    CLIENT -> SERVEUR (Requêtes)
═══════════════════════════════════════════════════════════════════════
--]]

-- AURAS
DCUO:RequestEquipAura    -- Demander d'équiper une aura
DCUO:BuyAura             -- Acheter une aura

-- ADMIN
DCUO:AdminAction         -- Action admin (kick, ban, teleport, etc)
DCUO:AdminPosition       -- Enregistrer position admin

-- CREATION PERSONNAGE
DCUO:CreateCharacter     -- Créer un nouveau personnage

-- JOBS
DCUO:JobChange           -- Changer de métier

-- MISSIONS
DCUO:MissionDialogue     -- Interaction dialogue mission

-- POUVOIRS
DCUO:PowerActivate       -- Activer un pouvoir
DCUO:PowerEquip          -- Équiper un pouvoir
DCUO:PowerUnequip        -- Déséquiper un pouvoir

-- SHOP
DCUO:Shop:Purchase       -- Acheter un item

-- SOCIAL
DCUO_SendFriendRequest   -- Envoyer demande d'ami
DCUO_RemoveFriend        -- Retirer un ami
DCUO_SendDuelRequest     -- Défier en duel

-- CINEMATIC
DCUO:EndCinematic        -- Terminer la cinématique

-- GUILDES
DCUO:Guilds:Create       -- Créer une guilde

-- MUSIQUE
DCUO:ChangeMusicMode     -- Changer le mode de musique

--[[
═══════════════════════════════════════════════════════════════════════
    SERVEUR -> CLIENT (Réponses/Notifications)
═══════════════════════════════════════════════════════════════════════
--]]

-- AURAS
DCUO:EquipAura          -- Confirmer équipement aura
DCUO:SendAuras          -- Envoyer liste des auras

-- ADMIN
DCUO:AdminPanel         -- Ouvrir panel admin
DCUO:ServerAnnounce     -- Annonce serveur

-- BOSS
DCUO:BossSpawned        -- Boss apparu
DCUO:BossKilled         -- Boss tué

-- CREATION PERSONNAGE
DCUO:OpenCharacterCreator  -- Ouvrir créateur de personnage

-- EVENTS
DCUO:EventStart         -- Événement commencé

-- MENUS
DCUO:OpenMenu           -- Ouvrir un menu

-- MISSIONS
DCUO:MissionUpdate      -- Mise à jour mission

-- NOTIFICATIONS
DCUO:Notification       -- Notification générale

-- PLAYER DATA
DCUO:PlayerData         -- Envoyer données joueur
DCUO:UpdateXP           -- Mise à jour XP
DCUO:UpdateLevel        -- Mise à jour niveau

-- SHOP
DCUO:Shop:Open          -- Ouvrir boutique NPC

-- CINEMATIC
DCUO:StartCinematic     -- Démarrer cinématique

--[[
═══════════════════════════════════════════════════════════════════════
    BIDIRECTIONNEL (À ÉVITER !)
═══════════════════════════════════════════════════════════════════════

AUCUN - Tous les net messages doivent être unidirectionnels

Si vous avez besoin de communication bidirectionnelle :
1. Créer 2 net messages distincts :
   - DCUO:Request[Action] (Client -> Serveur)
   - DCUO:[Action] (Serveur -> Client)

2. Exemple :
   ❌ MAUVAIS:
      DCUO:EquipAura (utilisé dans les 2 sens)
   
   ✅ BON:
      DCUO:RequestEquipAura (Client -> Serveur)
      DCUO:EquipAura (Serveur -> Client)
--]]

--[[
═══════════════════════════════════════════════════════════════════════
    CONVENTIONS DE NOMMAGE
═══════════════════════════════════════════════════════════════════════

Client -> Serveur:
- DCUO:Request[Action]  (préféré)
- DCUO:[System]:[Action]
- DCUO_[Action] (legacy)

Serveur -> Client:
- DCUO:[Action]
- DCUO:[System]:[Action]
- DCUO:Send[Data]

--]]

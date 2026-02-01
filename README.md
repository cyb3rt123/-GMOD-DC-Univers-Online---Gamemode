# 🦸 DCUO-RP - DC Universe Online Roleplay Gamemode

[![Garry's Mod](https://img.shields.io/badge/Garry's%20Mod-Gamemode-blue.svg)](https://gmod.facepunch.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-In%20Development-yellow.svg)]()

> **Un gamemode roleplay immersif inspiré de l'univers DC Comics pour Garry's Mod**

---

## 📖 Histoire & Concept

Bienvenue dans **DCUO-RP**, un gamemode de roleplay qui vous plonge dans l'univers des super-héros et super-vilains DC Comics. 

### L'Univers

Dans un monde où les héros et les vilains coexistent, vous incarnez un habitant de **Metropolis** ou **Gotham**. Votre destin ? À vous de le choisir :

- **Devenez un Héros** 🦸‍♂️ : Protégez les innocents, combattez le crime, rejoignez la Justice League
- **Embrassez le Mal** 🦹‍♂️ : Semez le chaos, combattez les héros, ralliez-vous aux vilains
- **Restez Neutre** 👤 : Vivez votre vie de civil, témoin des affrontements épiques

### Système de Progression

- **Système XP/Niveaux** : Gagnez de l'expérience en accomplissant des missions
- **Pouvoirs Uniques** : Débloquez et améliorez vos super-pouvoirs
- **Auras Cosmétiques** : Personnalisez votre apparence avec des effets visuels
- **Guildes** : Créez ou rejoignez des organisations de héros/vilains
- **Boss Dynamiques** : Affrontez des boss légendaires (Doomsday, Darkseid, Brainiac...)

---

## ✨ Fonctionnalités

### ✅ Implémentées

- ✅ **Système de missions** (Kill, Rescue, Collect)
- ✅ **Boss system** avec IA dynamique et patrouille
- ✅ **Boutique d'auras** avec 15+ auras achetables
- ✅ **Système de guildes** complet (création, gestion, membres)
- ✅ **DCUO Phone** - Hub central pour tous les menus
- ✅ **Système d'XP et niveaux**
- ✅ **Musique d'ambiance** automatique
- ✅ **HUD personnalisé** avec barre de boss
- ✅ **Système de chat** amélioré
- ✅ **Panel d'administration**
- ✅ **Système d'amis**

### ⚠️ En Développement

- ⚠️ **Système de pouvoirs** (partiellement implémenté)
- ⚠️ **Combat PvP** avancé
- ⚠️ **Événements aléatoires** (base existante)
- ⚠️ **Économie complète**
- ⚠️ **Système de crafting**
- ⚠️ **Plus de missions** (actuellement 5 types)
- ⚠️ **Map personnalisée** Metropolis/Gotham
- ⚠️ **Cinématiques** pour les missions
- ⚠️ **Système de réputation** Héros/Vilain

### ❌ Non Implémentées

- ❌ Système de véhicules volants
- ❌ Bases de guildes personnalisables
- ❌ Arbre de talents
- ❌ Raids multi-joueurs
- ❌ PvP arènes
- ❌ Système de mentors

---

## 🚀 Installation

### Prérequis

- **Garry's Mod** (version récente)
- **DarkRP** (compatible avec le système de jobs)
- **Workshop Content** (voir section Content Pack)

### Installation Serveur

1. **Cloner le repository**
```bash
git clone https://github.com/VotreNom/dcuo-rp.git
cd dcuo-rp
```

2. **Copier les fichiers**
```
Copier le dossier 'gamemodes/dcuorp' vers:
garrysmod/gamemodes/dcuorp/

Copier le dossier 'garrysmod/addons/dcuorp-content' vers:
garrysmod/addons/dcuorp-content/
```

3. **Configuration serveur**

Éditez `server.cfg` :
```
hostname "Votre Serveur DCUO-RP"
gamemode "dcuorp"
sv_loadingurl "https://votre-loading-screen.com"
```

4. **Démarrer le serveur**
```bash
srcds.exe -console -game garrysmod +gamemode dcuorp +map rp_downtown_v4c_v2 +maxplayers 32
```

### Content Pack

Les fichiers suivants doivent être dans `garrysmod/addons/dcuorp-content/` :

**Materials** :
- `materials/dcuo/logos/server_logo.png` - Logo du serveur
- `materials/icons/` - Icônes des pouvoirs et auras

**Sons** :
- `sound/dcuo/ambient/metropolis.mp3` - Musique Metropolis
- `sound/dcuo/ambient/gotham.mp3` - Musique Gotham
- `sound/dcuo/ambient/atlantis.mp3` - Musique Atlantis

---

## 🎮 Guide d'Utilisation

### Première Connexion

1. **Création du personnage** : Choisissez votre faction (Héros/Vilain/Neutre)
2. **Choix du métier** : Utilisez le menu F1 ou le DCUO Phone
3. **Tutoriel** : Suivez les instructions du coordinateur

### Commandes Principales

#### Joueur
- **F1** - Menu principal (jobs, shop)
- **F2** - Menu guildes
- **F3** - DCUO Phone (hub central)
- **F4** - DarkRP menu
- **/accept** - Accepter un événement de boss
- **/cancel** - Annuler votre mission en cours

#### Admin
- **!spawnboss [id]** - Faire spawn un boss
- **dcuo_test_mission_spawn [id]** - Tester une mission
- **dcuo_boss_info** - Infos sur les boss actifs
- **dcuo_list_active_missions** - Lister les missions actives

### Le DCUO Phone

Le **DCUO Phone** est votre hub central. Accédez-y avec **F3** ou équipez le SWEP "DCUO Phone".

**Applications disponibles** :
- **[J] Métiers** - Changer de job
- **[P] Pouvoirs** - Gérer vos pouvoirs (WIP)
- **[M] Missions** - Voir les missions (WIP)
- **[A] Auras** - Boutique d'auras
- **[G] Guildes** - Menu de guilde
- **[F] Amis** - Liste d'amis (WIP)
- **[!] Admin** - Panel admin (admins seulement)
- **[i] Profil** - Voir vos stats
- **[*] Paramètres** - Options (WIP)

### Missions

**Types de missions disponibles** :

1. **Kill** - Éliminer des ennemis
   - Exemple : "Arrêter un Braquage" (10 criminels)
   
2. **Rescue** - Sauver des civils
   - Exemple : "Sauvetage de Civils" (5 civils)
   - Approchez-vous et appuyez sur **E**

3. **Collect** - Collecter des objets
   - Ramassez les objets au point GPS

**Démarrer une mission** :
1. Ouvrez le menu missions (F3 → Missions ou NPC de mission)
2. Choisissez une mission adaptée à votre niveau
3. Suivez le GPS vers le point de mission
4. Accomplissez les objectifs
5. Recevez XP et récompenses

### Boss System

Des boss légendaires apparaissent aléatoirement sur la map :

**Boss disponibles** :
- **Doomsday** - Le destructeur de mondes (Niveau 30)
- **Darkseid** - Le tyran d'Apokolips (Niveau 40)
- **Brainiac** - L'IA maléfique (Niveau 25)
- **Sinestro** - Le porteur de l'anneau jaune (Niveau 20)
- **Ares** - Le Dieu de la Guerre (Niveau 35)

**Quand un boss apparaît** :
1. Notification globale : `[!] BOSS APPARU : Doomsday !`
2. Tapez **/accept** pour recevoir le GPS
3. Allez au point GPS
4. Combattez le boss en groupe (recommandé)
5. Partagez les récompenses XP

**Barre de vie du boss** : Visible en haut de l'écran quand vous êtes proche

### Système d'Auras

Les auras sont des effets visuels cosmétiques autour de votre personnage.

**Acheter une aura** :
1. F3 → Auras
2. Naviguez les catégories (Électriques, Feu, Énergie...)
3. Cliquez sur une aura pour l'acheter (coûte de l'XP)
4. Cliquez sur une aura possédée pour l'équiper
5. Cliquez sur une aura équipée pour la retirer

**Catégories** :
- Électriques (bleu, jaune, rouge, Speed Force)
- Feu (orange, bleu, vert)
- Énergie (blanc, violet, cyan, Lantern)
- Particules (or, arc-en-ciel)
- Sombres (fumée, violet)
- Légendaires (héros, vilain, cosmique)
- Spéciales (kryptonite)

### Guildes

**Créer une guilde** :
1. F2 ou F3 → Guildes
2. "Créer une Guilde"
3. Choisissez un nom et une description
4. Invitez des membres

**Gérer votre guilde** :
- Promouvoir/rétrograder des membres
- Expulser des membres
- Dissoudre la guilde (chef seulement)
- Chat de guilde privé

---

## 🛠️ Configuration

### Fichiers de Configuration

**Jobs** : `gamemodes/dcuorp/core/sh_jobs.lua`
```lua
-- Ajouter un nouveau job
DCUO.Jobs.Add("superman", {
    name = "Superman",
    description = "Protecteur de Metropolis",
    color = Color(0, 100, 255),
    model = "models/player/superman.mdl",
    weapons = {"weapon_physgun"},
    command = "superman",
    max = 2,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Heroes",
})
```

**Missions** : `gamemodes/dcuorp/core/sh_missions.lua`
```lua
-- Ajouter une nouvelle mission
DCUO.Missions.List["ma_mission"] = {
    id = "ma_mission",
    name = "Nom de la Mission",
    description = "Description...",
    type = DCUO.Missions.Types.KILL,
    faction = {"Hero"},
    levelRequired = 5,
    maxPlayers = 4,
    xpReward = 200,
    objectives = {
        {
            type = "kill",
            count = 15,
            enemyClass = "npc_combine_s",
            enemyName = "Soldat Ennemi",
        }
    },
    duration = 600,
}
```

**Boss** : `gamemodes/dcuorp/systems/sh_bosses.lua`
```lua
-- Ajouter un nouveau boss
DCUO.Bosses.List["joker"] = {
    name = "Joker",
    description = "Le prince du crime",
    model = "models/player/joker.mdl",
    health = 10000,
    level = 45,
    class = "npc_combine_s",
    weapon = "weapon_smg1",
    xpReward = 2000,
    color = Color(128, 0, 128),
    scale = 1.5,
}
```

### Options Serveur

Dans `gamemodes/dcuorp/gamemode/init.lua` :

```lua
-- XP et Niveaux
DCUO.XP.Config.BaseXPRequired = 100  -- XP pour niveau 2
DCUO.XP.Config.XPMultiplier = 1.5    -- Augmentation par niveau

-- Boss
DCUO.Bosses.Config.SpawnInterval = 600  -- Intervalle spawn (secondes)
DCUO.Bosses.Config.RewardRadius = 500   -- Rayon récompense

-- Musique
DCUO.AmbientMusic.Config.Enabled = true
DCUO.AmbientMusic.Config.Volume = 30
```

---

## 🤝 Contribution

Les contributions sont les bienvenues !

### Comment Contribuer

1. **Fork** le projet
2. **Créer** une branche (`git checkout -b feature/AmazingFeature`)
3. **Commit** vos changements (`git commit -m 'Add some AmazingFeature'`)
4. **Push** vers la branche (`git push origin feature/AmazingFeature`)
5. **Ouvrir** une Pull Request

### Guidelines

- Suivez le style de code existant (4 espaces, commentaires en français)
- Testez vos modifications sur un serveur local
- Documentez les nouvelles fonctionnalités
- Pas d'emojis Unicode dans le code (utilisez des symboles ASCII)

---

## 📋 Roadmap

### Version 1.0 (Actuelle - Beta)
- [x] Système de base (XP, jobs, HUD)
- [x] Missions (3 types)
- [x] Boss system
- [x] Auras
- [x] Guildes
- [x] DCUO Phone

### Version 1.5 (Prochaine)
- [ ] Système de pouvoirs complet
- [ ] 10+ nouvelles missions
- [ ] Events aléatoires activés
- [ ] Économie avancée
- [ ] 5+ nouveaux boss

### Version 2.0 (Future)
- [ ] Map personnalisée Metropolis
- [ ] Système de réputation
- [ ] Véhicules volants
- [ ] Arbre de talents
- [ ] Raids multi-joueurs

---

## 📄 License

Ce projet est sous licence **MIT** - voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 👥 Crédits

### Développeur Principal
**CyB3Rt** - Développement, design et architecture du gamemode

### Remerciements
- **Facepunch Studios** - Garry's Mod
- **DC Comics** - Univers et personnages
- **Communauté GMod** - Ressources et support

---

## 📞 Support & Contact

**Problèmes connus** : Voir [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

**Rapporter un bug** : Ouvrez une [Issue](https://github.com/VotreNom/dcuo-rp/issues)

**Discord** : [Votre serveur Discord]

---

## ⚠️ Avertissement

Ce gamemode est un projet **fan-made** non officiel. Tous les personnages et éléments DC Comics sont la propriété de **DC Entertainment** et **Warner Bros**. Ce projet n'est pas affilié, approuvé ou sponsorisé par DC Comics.

Utilisé uniquement à des fins de divertissement et d'apprentissage.

---

<div align="center">

**Fait avec ❤️ par CyB3Rt**

[⬆ Retour en haut](#-dcuo-rp---dc-universe-online-roleplay-gamemode)

</div>

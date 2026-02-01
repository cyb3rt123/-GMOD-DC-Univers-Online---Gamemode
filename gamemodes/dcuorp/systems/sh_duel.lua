-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                       DUEL SYSTEM (SHARED)                        ║
-- ║          Configuration et données partagées des duels             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Duel = DCUO.Duel or {}

-- Configuration
DCUO.Duel.Config = {
    -- Zone de combat
    ArenaRadius = 500,              -- Rayon de l'arène de duel (unités)
    ArenaWallHeight = 300,          -- Hauteur du mur invisible
    
    -- Timings
    CountdownDuration = 5,          -- Durée du décompte (secondes)
    IntroAnimDuration = 3,          -- Durée de la cinématique d'intro
    FinishAnimDuration = 5,         -- Durée de la cinématique finale
    
    -- Effets visuels
    ArenaColor = Color(255, 50, 50, 100),   -- Couleur de la barrière
    CountdownColor = Color(255, 200, 0),    -- Couleur du compte à rebours
    
    -- Règles
    AllowPowers = true,             -- Autoriser les pouvoirs
    AllowWeapons = true,            -- Autoriser les armes
    RestoreHealthAfter = true,      -- Restaurer la santé après le duel
    TeleportBackAfter = true,       -- Téléporter les joueurs à leur position d'origine
    
    -- Récompenses
    WinnerXP = 200,                 -- XP pour le gagnant
    ParticipationXP = 50,           -- XP pour le perdant
}

-- États du duel
DCUO.Duel.States = {
    WAITING = 0,        -- En attente d'acceptation
    PREPARING = 1,      -- Préparation (cinématique intro)
    COUNTDOWN = 2,      -- Décompte
    FIGHTING = 3,       -- Combat en cours
    FINISHING = 4,      -- Cinématique finale
    ENDED = 5,          -- Terminé
}

-- Structure d'un duel actif
DCUO.Duel.ActiveDuels = DCUO.Duel.ActiveDuels or {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     FONCTIONS UTILITAIRES                         ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Duel.GetPlayerDuel(ply)
    if not IsValid(ply) then return nil end
    
    for id, duel in pairs(DCUO.Duel.ActiveDuels) do
        if duel.player1 == ply or duel.player2 == ply then
            return duel, id
        end
    end
    
    return nil
end

function DCUO.Duel.IsInDuel(ply)
    return DCUO.Duel.GetPlayerDuel(ply) ~= nil
end

function DCUO.Duel.GetOpponent(ply)
    local duel = DCUO.Duel.GetPlayerDuel(ply)
    if not duel then return nil end
    
    if duel.player1 == ply then
        return duel.player2
    else
        return duel.player1
    end
end

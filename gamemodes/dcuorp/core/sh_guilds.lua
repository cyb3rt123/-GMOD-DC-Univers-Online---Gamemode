--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Guildes (Shared)
    Données partagées des guildes
═══════════════════════════════════════════════════════════════════════
--]]

DCUO.Guilds = DCUO.Guilds or {}
DCUO.Guilds.List = DCUO.Guilds.List or {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CONFIGURATION                                  ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Guilds.Config = {
    MaxGuilds = 100,              -- Maximum de guildes sur le serveur
    MaxMembers = 10,              -- Maximum de membres par guilde
    MinNameLength = 3,            -- Longueur minimale du nom
    MaxNameLength = 20,           -- Longueur maximale du nom
    CreationCost = 0,             -- Coût de création (XP ou argent) - GRATUIT pour l'instant
    LevelRequirement = 10,         -- Niveau minimum pour créer - NIVEAU 1 pour faciliter les tests
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    RANGS ET PERMISSIONS                           ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Guilds.Ranks = {
    ["leader"] = {
        id = 1,
        name = "Leader",
        color = Color(241, 196, 15),
        permissions = {
            invite = true,
            kick = true,
            promote = true,
            demote = true,
            disband = true,
            editInfo = true,
            manageAlliance = true,
            withdrawBank = true,
        }
    },
    ["officer"] = {
        id = 2,
        name = "Officier",
        color = Color(52, 152, 219),
        permissions = {
            invite = true,
            kick = true,
            promote = false,
            demote = false,
            disband = false,
            editInfo = true,
            manageAlliance = false,
            withdrawBank = true,
        }
    },
    ["member"] = {
        id = 3,
        name = "Membre",
        color = Color(149, 165, 166),
        permissions = {
            invite = false,
            kick = false,
            promote = false,
            demote = false,
            disband = false,
            editInfo = false,
            manageAlliance = false,
            withdrawBank = false,
        }
    }
}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FONCTIONS UTILITAIRES                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Guilds.GetRank(rankID)
    for id, rank in pairs(DCUO.Guilds.Ranks) do
        if rank.id == rankID then
            return rank
        end
    end
    return DCUO.Guilds.Ranks.member
end

function DCUO.Guilds.HasPermission(guildID, steamID, permission)
    local guild = DCUO.Guilds.List[guildID]
    if not guild then return false end
    
    local member = guild.members[steamID]
    if not member then return false end
    
    local rank = DCUO.Guilds.GetRank(member.rank)
    return rank.permissions[permission] or false
end

function DCUO.Guilds.GetPlayerGuild(steamID)
    for id, guild in pairs(DCUO.Guilds.List) do
        if guild.members[steamID] then
            return id, guild
        end
    end
    return nil, nil
end

function DCUO.Guilds.GetGuild(guildID)
    return DCUO.Guilds.List[guildID]
end

function DCUO.Guilds.GetMemberCount(guildID)
    local guild = DCUO.Guilds.GetGuild(guildID)
    if not guild then return 0 end
    
    local count = 0
    for _ in pairs(guild.members) do
        count = count + 1
    end
    return count
end

function DCUO.Guilds.GetTotalLevel(guildID)
    local guild = DCUO.Guilds.GetGuild(guildID)
    if not guild then return 0 end
    
    local total = 0
    for steamID, member in pairs(guild.members) do
        total = total + (member.level or 1)
    end
    return total
end

function DCUO.Guilds.GetAverageLevel(guildID)
    local count = DCUO.Guilds.GetMemberCount(guildID)
    if count == 0 then return 0 end
    
    return math.floor(DCUO.Guilds.GetTotalLevel(guildID) / count)
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    STRUCTURE D'UNE GUILDE                         ║
-- ╚═══════════════════════════════════════════════════════════════════╝

--[[
    guild = {
        id = "guild_123456",
        name = "Les Justiciers",
        tag = "LJ",
        description = "Une guilde de héros...",
        leader = "STEAM_0:1:12345678",
        faction = "Hero",
        created = os.time(),
        
        members = {
            ["STEAM_0:1:12345678"] = {
                steamID = "STEAM_0:1:12345678",
                name = "PlayerName",
                rank = 1,  -- 1=Leader, 2=Officer, 3=Member
                joined = os.time(),
                level = 10,
                contribution = 500,  -- XP/points contribués
            }
        },
        
        stats = {
            totalXP = 5000,
            totalKills = 100,
            totalMissions = 50,
        },
        
        bank = {
            money = 0,
            items = {},
        },
        
        settings = {
            color = Color(255, 255, 255),
            logo = "",
            public = true,  -- Accepte les demandes publiques
            recruitmentMessage = "",
        }
    }
--]]

DCUO.Log("Guilds System (Shared) Loaded", "SUCCESS")

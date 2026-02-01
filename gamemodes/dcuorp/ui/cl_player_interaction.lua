-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                   PLAYER INTERACTION MENU                         ║
-- ║        Menu contextuel pour interagir avec d'autres joueurs       ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Variables locales
local MENU_WIDTH = 250
local MENU_HEIGHT = 350
local selectedPlayer = nil

-- Couleurs
local colorBg = Color(20, 20, 20, 240)
local colorHeader = Color(0, 120, 215)
local colorButton = Color(40, 40, 40, 200)
local colorButtonHover = Color(60, 60, 60, 220)
local colorText = Color(255, 255, 255)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     CRÉER LE MENU                                 ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.OpenPlayerInteractionMenu(target)
    if not IsValid(target) or not target:IsPlayer() then return end
    if target == LocalPlayer() then return end
    
    selectedPlayer = target
    
    -- Fermer le menu existant
    if IsValid(DCUO.PlayerInteractionMenu) then
        DCUO.PlayerInteractionMenu:Remove()
    end
    
    -- Créer le frame
    local frame = vgui.Create("DFrame")
    frame:SetSize(MENU_WIDTH, MENU_HEIGHT)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    frame.Paint = function(self, w, h)
        -- Fond
        draw.RoundedBox(8, 0, 0, w, h, colorBg)
        
        -- Header
        draw.RoundedBoxEx(8, 0, 0, w, 50, colorHeader, true, true, false, false)
        
        -- Titre
        draw.SimpleText("Interaction Joueur", "DCUO_Font_Medium", w / 2, 25, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Nom du joueur ciblé
    local playerLabel = vgui.Create("DLabel", frame)
    playerLabel:SetPos(10, 60)
    playerLabel:SetSize(MENU_WIDTH - 20, 30)
    playerLabel:SetText(target:Nick())
    playerLabel:SetFont("DCUO_Font_Small")
    playerLabel:SetTextColor(colorText)
    playerLabel:SetContentAlignment(5)
    
    -- Niveau du joueur
    local levelLabel = vgui.Create("DLabel", frame)
    levelLabel:SetPos(10, 85)
    levelLabel:SetSize(MENU_WIDTH - 20, 20)
    levelLabel:SetText("Niveau " .. (target:GetNWInt("DCUO_Level", 1)))
    levelLabel:SetFont("DCUO_Font_Small")
    levelLabel:SetTextColor(Color(200, 200, 200))
    levelLabel:SetContentAlignment(5)
    
    -- Séparateur
    local separator = vgui.Create("DPanel", frame)
    separator:SetPos(10, 115)
    separator:SetSize(MENU_WIDTH - 20, 2)
    separator.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(80, 80, 80))
    end
    
    -- ╔═══════════════════════════════════════════════════════════════════╗
    -- ║                          BOUTONS                                  ║
    -- ╚═══════════════════════════════════════════════════════════════════╝
    
    local buttonY = 130
    local buttonHeight = 40
    local buttonSpacing = 10
    
    -- Bouton: Demander en duel
    local duelBtn = createMenuButton(frame, "Demander en Duel", buttonY, function()
        net.Start("DCUO_SendDuelRequest")
        net.WriteEntity(target)
        net.SendToServer()
        frame:Remove()
    end)
    buttonY = buttonY + buttonHeight + buttonSpacing
    
    -- Bouton: Ajouter en ami
    local isFriend = DCUO.Friends and DCUO.Friends.IsFriend(target:SteamID64())
    local friendBtn = createMenuButton(frame, isFriend and "❌ Retirer des amis" or "💚 Ajouter en ami", buttonY, function()
        if isFriend then
            net.Start("DCUO_RemoveFriend")
            net.WriteString(target:SteamID64())
            net.SendToServer()
        else
            net.Start("DCUO_SendFriendRequest")
            net.WriteEntity(target)
            net.SendToServer()
        end
        frame:Remove()
    end)
    buttonY = buttonY + buttonHeight + buttonSpacing
    
    -- Bouton: Voir le profil
    local profileBtn = createMenuButton(frame, "👤 Voir le Profil", buttonY, function()
        DCUO.OpenPlayerProfile(target)
        frame:Remove()
    end)
    buttonY = buttonY + buttonHeight + buttonSpacing
    
    -- Bouton: Échanger
    local tradeBtn = createMenuButton(frame, "🔄 Échanger", buttonY, function()
        chat.AddText(Color(255, 200, 0), "[DCUO] ", Color(255, 255, 255), "Système d'échange bientôt disponible !")
        frame:Remove()
    end)
    buttonY = buttonY + buttonHeight + buttonSpacing
    
    -- Bouton: Fermer
    local closeBtn = createMenuButton(frame, "Fermer", MENU_HEIGHT - 50, function()
        frame:Remove()
    end, Color(180, 50, 50, 200), Color(200, 70, 70, 220))
    
    DCUO.PlayerInteractionMenu = frame
end

-- Fonction helper pour créer un bouton
function createMenuButton(parent, text, yPos, onClick, bgColor, hoverColor)
    bgColor = bgColor or colorButton
    hoverColor = hoverColor or colorButtonHover
    
    local btn = vgui.Create("DButton", parent)
    btn:SetPos(10, yPos)
    btn:SetSize(MENU_WIDTH - 20, 40)
    btn:SetText("")
    btn.DoClick = onClick
    
    btn.Paint = function(self, w, h)
        local col = self:IsHovered() and hoverColor or bgColor
        draw.RoundedBox(6, 0, 0, w, h, col)
        draw.SimpleText(text, "DCUO_Font_Small", w / 2, h / 2, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    return btn
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     PROFIL JOUEUR                                 ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.OpenPlayerProfile(target)
    if not IsValid(target) then return end
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 500)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:MakePopup()
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, colorBg)
        draw.RoundedBoxEx(8, 0, 0, w, 60, colorHeader, true, true, false, false)
        draw.SimpleText("Profil de " .. target:Nick(), "DCUO_Font_Medium", w / 2, 30, colorText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Avatar du joueur
    local avatar = vgui.Create("AvatarImage", frame)
    avatar:SetPos(150, 80)
    avatar:SetSize(100, 100)
    avatar:SetPlayer(target, 184)
    
    -- Informations
    local infoY = 200
    local function addInfo(label, value)
        local lbl = vgui.Create("DLabel", frame)
        lbl:SetPos(20, infoY)
        lbl:SetSize(360, 25)
        lbl:SetText(label .. ": " .. value)
        lbl:SetFont("DCUO_Font_Small")
        lbl:SetTextColor(colorText)
        infoY = infoY + 30
    end
    
    addInfo("Niveau", target:GetNWInt("DCUO_Level", 1))
    addInfo("Faction", target:GetNWString("DCUO_Faction", "Inconnu"))
    
    -- Récupérer le nom du job depuis la table
    local jobID = target:GetNWString("DCUO_Job", "Aucun")
    local job = DCUO.Jobs.Get(jobID)
    local jobName = job and job.name or jobID
    addInfo("Job", jobName)
    
    addInfo("XP", target:GetNWInt("DCUO_XP", 0))
    addInfo("Temps de jeu", string.FormattedTime(target:GetNWInt("DCUO_PlayTime", 0)))
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                          HOOKS                                    ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Ouvrir le menu avec un bind (par exemple F4 sur un joueur)
hook.Add("PlayerBindPress", "DCUO_PlayerInteraction_OpenMenu", function(ply, bind, pressed)
    if not pressed then return end
    if bind ~= "+menu" and bind ~= "+use" then return end -- F4 ou E
    
    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or not trace.Entity:IsPlayer() then return end
    if trace.HitPos:Distance(ply:GetPos()) > 150 then return end -- Distance max 150
    
    -- Ouvrir le menu
    DCUO.OpenPlayerInteractionMenu(trace.Entity)
    return true
end)

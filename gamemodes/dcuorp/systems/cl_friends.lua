-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    FRIENDS SYSTEM (CLIENT)                        ║
-- ║              Interface et gestion côté client                     ║
-- ╚═══════════════════════════════════════════════════════════════════╝

DCUO.Friends = DCUO.Friends or {}
DCUO.Friends.List = {}

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     NETWORK RECEIVERS                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

-- Recevoir une demande d'ami
net.Receive("DCUO_FriendRequest", function()
    local requester = net.ReadEntity()
    local requestID = net.ReadString()
    
    if not IsValid(requester) then return end
    
    DCUO.ShowFriendRequest(requester, requestID)
end)

-- Ami ajouté
net.Receive("DCUO_FriendAdded", function()
    local steamID = net.ReadString()
    local name = net.ReadString()
    
    DCUO.Friends.List[steamID] = {
        steamid = steamID,
        name = name,
        added_date = os.time()
    }
    
    surface.PlaySound("buttons/button9.wav")
    chat.AddText(Color(0, 255, 0), "[AMIS] ", Color(255, 255, 255), name .. " a été ajouté à votre liste d'amis !")
end)

-- Ami retiré
net.Receive("DCUO_FriendRemoved", function()
    local steamID = net.ReadString()
    
    if DCUO.Friends.List[steamID] then
        local name = DCUO.Friends.List[steamID].name
        DCUO.Friends.List[steamID] = nil
        
        chat.AddText(Color(255, 100, 100), "[AMIS] ", Color(255, 255, 255), name .. " a été retiré de votre liste d'amis")
    end
end)

-- Synchroniser la liste
net.Receive("DCUO_SyncFriends", function()
    DCUO.Friends.List = {}
    
    local count = net.ReadUInt(16)
    
    for i = 1, count do
        local steamID = net.ReadString()
        local name = net.ReadString()
        local addedDate = net.ReadUInt(32)
        
        DCUO.Friends.List[steamID] = {
            steamid = steamID,
            name = name,
            added_date = addedDate
        }
    end
    
    DCUO.Log("Synced " .. count .. " friends", "INFO")
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     POPUP DEMANDE D'AMI                           ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.ShowFriendRequest(requester, requestID)
    surface.PlaySound("buttons/button9.wav")
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 200)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 20, 250))
        draw.RoundedBoxEx(8, 0, 0, w, 60, Color(0, 150, 255), true, true, false, false)
        draw.SimpleText("💚 DEMANDE D'AMI", "DCUO_Font_Medium", w / 2, 30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    local msg = vgui.Create("DLabel", frame)
    msg:SetPos(20, 80)
    msg:SetSize(360, 40)
    msg:SetText(requester:Nick() .. " souhaite vous ajouter en ami")
    msg:SetFont("DCUO_Font_Small")
    msg:SetTextColor(color_white)
    msg:SetContentAlignment(5)
    msg:SetWrap(true)
    
    local acceptBtn = vgui.Create("DButton", frame)
    acceptBtn:SetPos(20, 130)
    acceptBtn:SetSize(170, 50)
    acceptBtn:SetText("")
    acceptBtn.DoClick = function()
        RunConsoleCommand("dcuo_accept_friend", requestID)
        frame:Remove()
    end
    acceptBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(0, 200, 0, 220) or Color(0, 150, 0, 200)
        draw.RoundedBox(6, 0, 0, w, h, col)
        draw.SimpleText("[V] ACCEPTER", "DCUO_Font_Small", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    local declineBtn = vgui.Create("DButton", frame)
    declineBtn:SetPos(210, 130)
    declineBtn:SetSize(170, 50)
    declineBtn:SetText("")
    declineBtn.DoClick = function()
        frame:Remove()
        chat.AddText(Color(255, 100, 100), "[AMIS] ", Color(255, 255, 255), "Vous avez refusé la demande d'ami.")
    end
    declineBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(200, 0, 0, 220) or Color(150, 0, 0, 200)
        draw.RoundedBox(6, 0, 0, w, h, col)
        draw.SimpleText("✖ REFUSER", "DCUO_Font_Small", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    timer.Simple(30, function()
        if IsValid(frame) then frame:Remove() end
    end)
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     MENU LISTE D'AMIS                             ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.OpenFriendsList()
    local frame = vgui.Create("DFrame")
    frame:SetSize(500, 600)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:MakePopup()
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 20, 240))
        draw.RoundedBoxEx(8, 0, 0, w, 60, Color(0, 150, 255), true, true, false, false)
        draw.SimpleText("💚 MES AMIS", "DCUO_Font_Medium", w / 2, 30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Compte
    local countLabel = vgui.Create("DLabel", frame)
    countLabel:SetPos(10, 70)
    countLabel:SetSize(480, 25)
    countLabel:SetText(table.Count(DCUO.Friends.List) .. " ami(s)")
    countLabel:SetFont("DCUO_Font_Small")
    countLabel:SetTextColor(Color(200, 200, 200))
    
    -- Liste scrollable
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(10, 105)
    scroll:SetSize(480, 480)
    
    local yPos = 0
    
    -- Trier par nom
    local sortedFriends = {}
    for _, friend in pairs(DCUO.Friends.List) do
        table.insert(sortedFriends, friend)
    end
    table.sort(sortedFriends, function(a, b) return a.name < b.name end)
    
    -- Afficher chaque ami
    for _, friend in ipairs(sortedFriends) do
        local panel = vgui.Create("DPanel", scroll)
        panel:SetPos(0, yPos)
        panel:SetSize(460, 70)
        panel.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(40, 40, 40, 220) or Color(30, 30, 30, 200)
            draw.RoundedBox(6, 0, 0, w, h, col)
        end
        
        -- Avatar
        local avatar = vgui.Create("AvatarImage", panel)
        avatar:SetPos(10, 10)
        avatar:SetSize(50, 50)
        avatar:SetSteamID(friend.steamid, 64)
        
        -- Nom
        local nameLabel = vgui.Create("DLabel", panel)
        nameLabel:SetPos(70, 15)
        nameLabel:SetSize(200, 25)
        nameLabel:SetText(friend.name)
        nameLabel:SetFont("DCUO_Font_Small")
        nameLabel:SetTextColor(color_white)
        
        -- Statut (en ligne/hors ligne)
        local isOnline = false
        for _, ply in ipairs(player.GetAll()) do
            if ply:SteamID64() == friend.steamid then
                isOnline = true
                break
            end
        end
        
        local statusLabel = vgui.Create("DLabel", panel)
        statusLabel:SetPos(70, 40)
        statusLabel:SetSize(200, 20)
        statusLabel:SetText(isOnline and "● En ligne" or "○ Hors ligne")
        statusLabel:SetFont("DCUO_Font_Small")
        statusLabel:SetTextColor(isOnline and Color(0, 255, 0) or Color(150, 150, 150))
        
        -- Bouton Retirer
        local removeBtn = vgui.Create("DButton", panel)
        removeBtn:SetPos(360, 20)
        removeBtn:SetSize(90, 30)
        removeBtn:SetText("")
        removeBtn.DoClick = function()
            net.Start("DCUO_RemoveFriend")
            net.WriteString(friend.steamid)
            net.SendToServer()
            
            panel:Remove()
            countLabel:SetText(table.Count(DCUO.Friends.List) - 1 .. " ami(s)")
        end
        removeBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(200, 50, 50, 220) or Color(150, 50, 50, 200)
            draw.RoundedBox(4, 0, 0, w, h, col)
            draw.SimpleText("✖ Retirer", "DermaDefault", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        yPos = yPos + 80
    end
    
    -- Si aucun ami
    if table.Count(DCUO.Friends.List) == 0 then
        local noFriends = vgui.Create("DLabel", scroll)
        noFriends:SetPos(0, 0)
        noFriends:SetSize(460, 100)
        noFriends:SetText("Vous n'avez pas encore d'amis.\nUtilisez le menu d'interaction sur un joueur pour l'ajouter !")
        noFriends:SetFont("DCUO_Font_Small")
        noFriends:SetTextColor(Color(150, 150, 150))
        noFriends:SetContentAlignment(5)
        noFriends:SetWrap(true)
    end
end

-- Commande pour ouvrir la liste
concommand.Add("dcuo_friends", function()
    DCUO.OpenFriendsList()
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                     FONCTIONS UTILITAIRES                         ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.Friends.IsFriend(steamID)
    return DCUO.Friends.List[steamID] ~= nil
end

function DCUO.Friends.GetFriend(steamID)
    return DCUO.Friends.List[steamID]
end

function DCUO.Friends.GetCount()
    return table.Count(DCUO.Friends.List)
end

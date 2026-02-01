--[[
═══════════════════════════════════════════════════════════════════════
    DCUO-RP - Système de Dialogues de Mission
    Affichage dynamique des dialogues NPC en bas d'écran
═══════════════════════════════════════════════════════════════════════
--]]

if SERVER then return end

DCUO.MissionDialogue = DCUO.MissionDialogue or {}
DCUO.MissionDialogue.ActiveDialogue = nil
DCUO.MissionDialogue.DialogueQueue = {}
DCUO.MissionDialogue.History = {}

-- Configuration
local DIALOGUE_CONFIG = {
    boxHeight = 150,
    boxMargin = 20,
    characterSize = 100,  -- Taille du portrait
    textSpeed = 2,        -- Caractères par frame
    autoCloseDelay = 5,   -- Secondes avant fermeture auto
    fadeSpeed = 3,        -- Vitesse de fade in/out
}

-- Fonts
surface.CreateFont("DCUO_Dialogue_Speaker", {
    font = "Roboto",
    size = 24,
    weight = 700,
    antialias = true,
    shadow = true,
})

surface.CreateFont("DCUO_Dialogue_Text", {
    font = "Roboto",
    size = 18,
    weight = 500,
    antialias = true,
    shadow = false,
})

surface.CreateFont("DCUO_Dialogue_Hint", {
    font = "Roboto",
    size = 14,
    weight = 400,
    antialias = true,
    italic = true,
})

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    AFFICHAGE DU DIALOGUE                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

local currentAlpha = 0
local displayedChars = 0
local autoCloseTime = 0

hook.Add("HUDPaint", "DCUO:MissionDialogue", function()
    local dialogue = DCUO.MissionDialogue.ActiveDialogue
    
    if not dialogue then
        -- Fade out
        if currentAlpha > 0 then
            currentAlpha = math.max(0, currentAlpha - FrameTime() * 255 * DIALOGUE_CONFIG.fadeSpeed)
        end
        return
    end
    
    -- Fade in
    if currentAlpha < 255 then
        currentAlpha = math.min(255, currentAlpha + FrameTime() * 255 * DIALOGUE_CONFIG.fadeSpeed)
    end
    
    local scrW, scrH = ScrW(), ScrH()
    local boxH = DIALOGUE_CONFIG.boxHeight
    local boxY = scrH - boxH - DIALOGUE_CONFIG.boxMargin
    local boxX = DIALOGUE_CONFIG.boxMargin
    local boxW = scrW - (DIALOGUE_CONFIG.boxMargin * 2)
    
    local alpha = currentAlpha
    
    -- ═══ BACKGROUND ═══
    
    -- Ombre portée
    draw.RoundedBox(8, boxX + 5, boxY + 5, boxW, boxH, Color(0, 0, 0, alpha * 0.3))
    
    -- Fond principal avec dégradé
    draw.RoundedBox(8, boxX, boxY, boxW, boxH, Color(20, 20, 30, alpha * 0.95))
    
    -- Bordure selon faction du speaker
    local borderColor = Color(100, 100, 100)
    if dialogue.faction == "Hero" then
        borderColor = Color(52, 152, 219)
    elseif dialogue.faction == "Villain" then
        borderColor = Color(231, 76, 60)
    elseif dialogue.faction == "Neutral" then
        borderColor = Color(149, 165, 166)
    end
    
    -- Bordure animée
    local borderPulse = math.sin(CurTime() * 3) * 0.2 + 0.8
    draw.RoundedBox(8, boxX, boxY, boxW, boxH, Color(borderColor.r, borderColor.g, borderColor.b, alpha * 0.3 * borderPulse))
    draw.RoundedBox(8, boxX + 3, boxY + 3, boxW - 6, boxH - 6, Color(20, 20, 30, alpha * 0.95))
    
    -- Ligne d'accentuation en haut
    draw.RoundedBox(2, boxX + 10, boxY + 10, boxW - 20, 4, Color(borderColor.r, borderColor.g, borderColor.b, alpha))
    
    -- ═══ PORTRAIT DU PERSONNAGE ═══
    
    local charSize = DIALOGUE_CONFIG.characterSize
    local charX = boxX + 20
    local charY = boxY + 25
    
    -- Cadre du portrait
    draw.RoundedBox(6, charX - 3, charY - 3, charSize + 6, charSize + 6, Color(borderColor.r, borderColor.g, borderColor.b, alpha))
    draw.RoundedBox(6, charX, charY, charSize, charSize, Color(40, 40, 50, alpha))
    
    -- Icône selon le type
    local iconText = "?"
    local iconColor = Color(255, 255, 255)
    
    if dialogue.type == "mission_start" then
        iconText = "!"
        iconColor = Color(241, 196, 15)
    elseif dialogue.type == "mission_progress" then
        iconText = "▶"
        iconColor = Color(52, 152, 219)
    elseif dialogue.type == "mission_complete" then
        iconText = "[V]"
        iconColor = Color(46, 204, 113)
    elseif dialogue.type == "mission_fail" then
        iconText = "✖"
        iconColor = Color(231, 76, 60)
    elseif dialogue.type == "warning" then
        iconText = "⚠"
        iconColor = Color(230, 126, 34)
    elseif dialogue.type == "info" then
        iconText = "i"
        iconColor = Color(149, 165, 166)
    end
    
    draw.SimpleText(iconText, "DermaHuge", charX + charSize/2, charY + charSize/2, ColorAlpha(iconColor, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- ═══ NOM DU SPEAKER ═══
    
    local nameX = charX + charSize + 20
    local nameY = boxY + 20
    
    -- Badge de nom
    surface.SetFont("DCUO_Dialogue_Speaker")
    local nameW, nameH = surface.GetTextSize(dialogue.speaker)
    
    draw.RoundedBox(4, nameX - 5, nameY - 5, nameW + 10, nameH + 10, Color(borderColor.r, borderColor.g, borderColor.b, alpha * 0.8))
    draw.SimpleText(dialogue.speaker, "DCUO_Dialogue_Speaker", nameX, nameY, ColorAlpha(Color(255, 255, 255), alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    
    -- ═══ TEXTE DU DIALOGUE ═══
    
    local textX = nameX
    local textY = nameY + nameH + 15
    local textW = boxW - (textX - boxX) - 30
    
    -- Animation d'écriture
    if dialogue.startTime then
        local elapsed = CurTime() - dialogue.startTime
        local targetChars = math.floor(elapsed * DIALOGUE_CONFIG.textSpeed * 60)
        displayedChars = math.min(targetChars, #dialogue.text)
    else
        displayedChars = #dialogue.text
    end
    
    local displayText = string.sub(dialogue.text, 1, displayedChars)
    
    -- Afficher le texte avec word wrap
    draw.DrawText(displayText, "DCUO_Dialogue_Text", textX, textY, ColorAlpha(Color(230, 230, 230), alpha), TEXT_ALIGN_LEFT)
    
    -- ═══ INDICATEURS ═══
    
    -- Indicateur "Appuyez sur E pour continuer" si texte complet
    if displayedChars >= #dialogue.text then
        local hintText = "Appuyez sur [E] pour continuer"
        local hintY = boxY + boxH - 25
        
        local hintAlpha = math.abs(math.sin(CurTime() * 4)) * 0.5 + 0.5
        draw.SimpleText(hintText, "DCUO_Dialogue_Hint", boxX + boxW - 20, hintY, ColorAlpha(Color(150, 150, 150), alpha * hintAlpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        
        -- Auto-close countdown
        if dialogue.autoClose then
            if autoCloseTime == 0 then
                autoCloseTime = CurTime() + DIALOGUE_CONFIG.autoCloseDelay
            end
            
            local remaining = math.max(0, math.ceil(autoCloseTime - CurTime()))
            if remaining > 0 then
                draw.SimpleText("Fermeture auto dans " .. remaining .. "s", "DCUO_Dialogue_Hint", boxX + 20, hintY, ColorAlpha(Color(100, 100, 100), alpha * 0.6), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            else
                DCUO.MissionDialogue.NextDialogue()
            end
        end
    end
    
    -- Indicateur de file d'attente
    if #DCUO.MissionDialogue.DialogueQueue > 0 then
        local queueText = "+" .. #DCUO.MissionDialogue.DialogueQueue .. " message(s) en attente"
        draw.SimpleText(queueText, "DCUO_Dialogue_Hint", boxX + 20, boxY - 20, ColorAlpha(Color(150, 150, 150), alpha * 0.8), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    end
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    GESTION DES DIALOGUES                          ║
-- ╚═══════════════════════════════════════════════════════════════════╝

function DCUO.MissionDialogue.Show(data)
    local dialogue = {
        speaker = data.speaker or "NPC",
        text = data.text or "...",
        type = data.type or "info",
        faction = data.faction or "Neutral",
        autoClose = data.autoClose ~= false,  -- true par défaut
        startTime = CurTime(),
    }
    
    -- Si un dialogue est actif, mettre en queue
    if DCUO.MissionDialogue.ActiveDialogue then
        table.insert(DCUO.MissionDialogue.DialogueQueue, dialogue)
        return
    end
    
    DCUO.MissionDialogue.ActiveDialogue = dialogue
    displayedChars = 0
    autoCloseTime = 0
    
    -- Son
    surface.PlaySound("ui/buttonclick.wav")
    
    -- Historique
    table.insert(DCUO.MissionDialogue.History, {
        time = os.time(),
        speaker = dialogue.speaker,
        text = dialogue.text,
    })
    
    DCUO.Log("Dialogue shown: " .. dialogue.speaker .. " - " .. dialogue.text, "INFO")
end

function DCUO.MissionDialogue.NextDialogue()
    DCUO.MissionDialogue.ActiveDialogue = nil
    autoCloseTime = 0
    displayedChars = 0
    
    -- Passer au suivant dans la queue
    if #DCUO.MissionDialogue.DialogueQueue > 0 then
        local next = table.remove(DCUO.MissionDialogue.DialogueQueue, 1)
        timer.Simple(0.3, function()
            DCUO.MissionDialogue.Show(next)
        end)
    end
end

function DCUO.MissionDialogue.Clear()
    DCUO.MissionDialogue.ActiveDialogue = nil
    DCUO.MissionDialogue.DialogueQueue = {}
    autoCloseTime = 0
    displayedChars = 0
end

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    CONTRÔLES CLAVIER                              ║
-- ╚═══════════════════════════════════════════════════════════════════╝

hook.Add("PlayerButtonDown", "DCUO:DialogueControls", function(ply, button)
    if button ~= KEY_E then return end
    
    local dialogue = DCUO.MissionDialogue.ActiveDialogue
    if not dialogue then return end
    
    -- Si le texte n'est pas complètement affiché, l'afficher entièrement
    if displayedChars < #dialogue.text then
        displayedChars = #dialogue.text
        return
    end
    
    -- Sinon, passer au suivant
    DCUO.MissionDialogue.NextDialogue()
end)

-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║                    RÉCEPTION RÉSEAU                               ║
-- ╚═══════════════════════════════════════════════════════════════════╝

net.Receive("DCUO:MissionDialogue", function()
    local speaker = net.ReadString()
    local text = net.ReadString()
    local dialogueType = net.ReadString()
    local faction = net.ReadString()
    
    DCUO.MissionDialogue.Show({
        speaker = speaker,
        text = text,
        type = dialogueType,
        faction = faction,
    })
end)

-- Helper
function ColorAlpha(color, alpha)
    return Color(color.r, color.g, color.b, alpha)
end

DCUO.Log("Mission dialogue system loaded", "SUCCESS")

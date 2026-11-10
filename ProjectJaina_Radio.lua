--[[
    ========================================================================
    Project Jaina - Sistema de Radio In-Game 24/7 (ProjectJaina_Radio.lua)
    Reino: Project Jaina | Servidor: Project Jaina Oficial
    Motor: World of Warcraft 3.3.5a (Build 12340)
    ========================================================================
    Módulo de Cliente Oficial #17: Sintonizador arcano de radio in-game.
    Control remoto bidireccional hacia la sesión web de streaming de audio
    (Kirin Tor Arcane Radio) y modo Jukebox Local de emergencia.
]]

local ADDON_NAME = "ProjectJaina_Radio"
local VERSION = "1.0.0"
local PREFIJO_RADIO = "PJ_RADIO"

-- Lista de Emisoras Canónicas (Verificadas en SoundEntries.dbc para WotLK 3.3.5a)
local EMISORAS = {
    { id = 1, name = "Taberna de Theramore", genre = "Folk Medieval & Bardo", localTrack = "Sound\\Music\\ZoneMusic\\TavernHuman\\RA_HumanTavern1A.mp3" },
    { id = 2, name = "Apex Mythic Raider", genre = "Orquestal Épico & Batalla", localTrack = "Sound\\Music\\GlueScreenMusic\\WotLK_main_title.mp3" },
    { id = 3, name = "Kirin Tor Lofi & Chill", genre = "Lo-Fi Beats & Relax", localTrack = "Sound\\Music\\ZoneMusic\\GrizzlyHills\\GH_GeneralWalk_A_Day01.mp3" },
    { id = 4, name = "Sintetizadores de Gnomeregan", genre = "Synthwave 80s", localTrack = "Sound\\Music\\ZoneMusic\\Ulduar\\UL_StoneGeneralWalk01.mp3" },
    { id = 5, name = "Forja de Hierro Rock & Metal", genre = "Heavy Metal & Hard Rock", localTrack = "Sound\\Music\\ZoneMusic\\DMF_L70ETC01.mp3" },
    { id = 6, name = "Tierras Altas de Arathi", genre = "Naturaleza, Lluvia & RPG", localTrack = "Sound\\Music\\ZoneMusic\\HowlingFjord\\HF_GeneralWalk_Day01.mp3" },
    { id = 7, name = "Dial Libre Personalizado", genre = "URL Propia de Audio", localTrack = nil }
}

-- Configuración por defecto
local dbDefaults = {
    station = 1,
    volume = 70,
    mode = "local", -- "local" (Jukebox MP3) o "web" (streaming 24/7)
    isPlaying = false,
    framePos = { "CENTER", "UIParent", "CENTER", 0, 100 },
    minimapAngle = 45,
    shown = false
}

ProjectJaina_Radio_DB = ProjectJaina_Radio_DB or {}

local mainFrame = nil
local nowPlayingTitle = "Sintonizando emisora..."
local lastSentVolume = nil

-- Diálogo emergente para copiar URL web de forma nativa en WoW 3.3.5a
StaticPopupDialogs["PROJECTJAINA_RADIO_URL"] = {
    text = "Kirin Tor Radio Web:\nPresiona Ctrl+C para copiar el enlace:",
    button1 = "Cerrar",
    hasEditBox = true,
    editBoxWidth = 280,
    OnShow = function(self)
        local editBox = _G[self:GetName() .. "EditBox"]
        if editBox then
            editBox:SetText("https://darckrovert.github.io/ProjectJaina_Web/radio/")
            editBox:SetFocus()
            editBox:HighlightText()
        end
    end,
    EditBoxOnEnterPressed = function(self)
        self:GetParent():Hide()
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Función auxiliar de impresión en chat
local function RadioPrint(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD700[Kirin Tor Radio]|r " .. tostring(msg))
end

-- Despacho de órdenes hacia el servidor Eluna y el Web Streamer
local function SendRadioCommand(action, arg)
    local pName = UnitName("player")
    if not pName or pName == "" or pName == UNKNOWNOBJECT then return end

    local payload = tostring(action) .. (arg and (":" .. tostring(arg)) or "")
    if SendAddonMessage then
        SendAddonMessage(PREFIJO_RADIO, payload, "WHISPER", pName)
    end
end

-- Almacenamiento volátil del estado de audio previo del jugador
local userAudioBackup = {
    captured = false,
    enableMusic = nil,
    musicVolume = nil
}

local function BackupUserAudioSettings()
    if not userAudioBackup.captured then
        userAudioBackup.enableMusic = GetCVar("Sound_EnableMusic")
        userAudioBackup.musicVolume = GetCVar("Sound_MusicVolume")
        userAudioBackup.captured = true
    end
end

local function RestoreUserAudioSettings()
    if userAudioBackup.captured then
        if userAudioBackup.enableMusic ~= nil then
            SetCVar("Sound_EnableMusic", userAudioBackup.enableMusic)
        end
        if userAudioBackup.musicVolume ~= nil then
            SetCVar("Sound_MusicVolume", userAudioBackup.musicVolume)
        end
        userAudioBackup.captured = false
    end
end

-- Control de Reproducción
local function PlayCurrentStation()
    local stIndex = ProjectJaina_Radio_DB.station or 1
    local st = EMISORAS[stIndex] or EMISORAS[1]

    if ProjectJaina_Radio_DB.mode == "local" then
        if not st.localTrack then
            StopMusic()
            RestoreUserAudioSettings()
            ProjectJaina_Radio_DB.isPlaying = false
            nowPlayingTitle = st.name .. " (Solo Streaming Web)"
            RadioPrint("|cFFFF5555Aviso:|r La emisora '|cFF00FFCC" .. st.name .. "|r' requiere el modo Streaming Web 24/7.")
            if mainFrame and mainFrame.UpdateUI then mainFrame:UpdateUI() end
            return
        end

        StopMusic()
        BackupUserAudioSettings()
        SetCVar("Sound_EnableMusic", "1")
        local vol = (ProjectJaina_Radio_DB.volume or 70) / 100
        SetCVar("Sound_MusicVolume", tostring(vol))
        PlayMusic(st.localTrack)

        ProjectJaina_Radio_DB.isPlaying = true
        nowPlayingTitle = st.name .. " (Modo Jukebox Local)"
        RadioPrint("Reproduciendo en Jukebox local: |cFF00FFCC" .. st.name .. "|r")
    else
        StopMusic()
        RestoreUserAudioSettings()
        ProjectJaina_Radio_DB.isPlaying = true
        SendRadioCommand("PLAY", stIndex)
        nowPlayingTitle = st.name .. " (" .. st.genre .. ")"
        RadioPrint("Sintonizando en streaming web: |cFF00FFCC" .. st.name .. "|r (Abre el portal web)")
    end

    if mainFrame and mainFrame.UpdateUI then
        mainFrame:UpdateUI()
    end
end

local function PauseCurrentStation()
    ProjectJaina_Radio_DB.isPlaying = false
    if ProjectJaina_Radio_DB.mode == "local" then
        StopMusic()
        RestoreUserAudioSettings()
    else
        SendRadioCommand("PAUSE")
    end
    nowPlayingTitle = "Radio en pausa"
    RadioPrint("Transmisión en pausa.")

    if mainFrame and mainFrame.UpdateUI then
        mainFrame:UpdateUI()
    end
end

local function SetStation(index)
    if index < 1 then index = 1 end
    if index > #EMISORAS then index = #EMISORAS end
    ProjectJaina_Radio_DB.station = index

    local st = EMISORAS[index]
    RadioPrint("Emisora seleccionada: |cFF00FFCC" .. st.name .. "|r (" .. st.genre .. ")")

    if ProjectJaina_Radio_DB.isPlaying then
        PlayCurrentStation()
    else
        SendRadioCommand("STATION", index)
        nowPlayingTitle = st.name
        if mainFrame and mainFrame.UpdateUI then
            mainFrame:UpdateUI()
        end
    end
end

local function NextStation()
    local nextSt = (ProjectJaina_Radio_DB.station or 1) + 1
    if nextSt > #EMISORAS then nextSt = 1 end
    SetStation(nextSt)
end

local function PrevStation()
    local prevSt = (ProjectJaina_Radio_DB.station or 1) - 1
    if prevSt < 1 then prevSt = #EMISORAS end
    SetStation(prevSt)
end

local function SetVolume(vol)
    vol = math.max(0, math.min(100, math.floor((tonumber(vol) or 50) + 0.5)))
    ProjectJaina_Radio_DB.volume = vol
    if ProjectJaina_Radio_DB.mode == "local" then
        SetCVar("Sound_MusicVolume", tostring(vol / 100))
    end
    if vol ~= lastSentVolume then
        lastSentVolume = vol
        SendRadioCommand("VOL", vol)
    end
    RadioPrint("Volumen establecido a: |cFFFFD700" .. vol .. "%|r")
    if mainFrame and mainFrame.UpdateUI then
        mainFrame:UpdateUI()
    end
end

local function ToggleMode()
    if ProjectJaina_Radio_DB.mode == "web" then
        ProjectJaina_Radio_DB.mode = "local"
        RadioPrint("Modo de Radio cambiado a: |cFFFFD700Jukebox Local MP3|r")
    else
        StopMusic()
        RestoreUserAudioSettings()
        ProjectJaina_Radio_DB.mode = "web"
        RadioPrint("Modo de Radio cambiado a: |cFF00FFCCStreaming Web 24/7|r (Usa el navegador)")
    end
    if ProjectJaina_Radio_DB.isPlaying then
        PlayCurrentStation()
    end
    if mainFrame and mainFrame.UpdateUI then
        mainFrame:UpdateUI()
    end
end

----------------------------------------------------------------------------
--  Interfaz Gráfica Flotante (Kirin Tor Radio Deck)
----------------------------------------------------------------------------
local function CreateRadioFrame()
    if mainFrame then return end

    mainFrame = CreateFrame("Frame", "ProjectJaina_RadioDeck", UIParent)
    mainFrame:SetSize(340, 160)
    mainFrame:SetClampedToScreen(true)
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local pt, _, relPt, x, y = self:GetPoint()
        ProjectJaina_Radio_DB.framePos = { pt, "UIParent", relPt, x, y }
    end)

    -- Fondo y Borde Kirin Tor
    mainFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    mainFrame:SetBackdropColor(0.05, 0.08, 0.14, 0.94)
    mainFrame:SetBackdropBorderColor(0.83, 0.69, 0.22, 1.0)

    -- Título de Cabecera
    local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 12, -8)
    title:SetText("|cFFD4AF37KIRIN TOR|r • |cFF00CCFFRadio 24/7|r")

    -- Botón de Cierre
    local closeBtn = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 2, 2)
    closeBtn:SetScript("OnClick", function()
        mainFrame:Hide()
        ProjectJaina_Radio_DB.shown = false
    end)

    -- Marquesina de Título
    local marqueeBox = CreateFrame("Frame", nil, mainFrame)
    marqueeBox:SetSize(316, 26)
    marqueeBox:SetPoint("TOP", mainFrame, "TOP", 0, -30)
    marqueeBox:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    marqueeBox:SetBackdropColor(0, 0, 0, 0.7)
    marqueeBox:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.6)

    local marqueeText = marqueeBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    marqueeText:SetPoint("CENTER", marqueeBox, "CENTER", 0, 0)
    marqueeText:SetText("|cFFFFFFFF" .. nowPlayingTitle .. "|r")
    mainFrame.marqueeText = marqueeText

    -- Botones de Control (Prev, Play, Next) con tipografía ASCII 100% compatible
    local btnPrev = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    btnPrev:SetSize(40, 26)
    btnPrev:SetPoint("TOPLEFT", marqueeBox, "BOTTOMLEFT", 10, -8)
    btnPrev:SetText("<<")
    btnPrev:SetScript("OnClick", function() PrevStation() end)

    local btnPlay = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    btnPlay:SetSize(80, 26)
    btnPlay:SetPoint("LEFT", btnPrev, "RIGHT", 8, 0)
    btnPlay:SetText(ProjectJaina_Radio_DB.isPlaying and "|| Pausa" or "> Play")
    btnPlay:SetScript("OnClick", function()
        if ProjectJaina_Radio_DB.isPlaying then
            PauseCurrentStation()
        else
            PlayCurrentStation()
        end
    end)
    mainFrame.btnPlay = btnPlay

    local btnNext = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    btnNext:SetSize(40, 26)
    btnNext:SetPoint("LEFT", btnPlay, "RIGHT", 8, 0)
    btnNext:SetText(">>")
    btnNext:SetScript("OnClick", function() NextStation() end)

    -- Botón de Modo (Web vs Local Jukebox)
    local btnMode = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    btnMode:SetSize(110, 26)
    btnMode:SetPoint("LEFT", btnNext, "RIGHT", 14, 0)
    btnMode:SetText(ProjectJaina_Radio_DB.mode == "web" and "Modo: Web 24/7" or "Modo: Local")
    btnMode:SetScript("OnClick", function()
        ToggleMode()
    end)
    mainFrame.btnMode = btnMode

    -- Selector de Emisora y Etiqueta
    local stationLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    stationLabel:SetPoint("TOPLEFT", btnPrev, "BOTTOMLEFT", 0, -12)
    stationLabel:SetText("Emisora: |cFF00FFCC" .. (EMISORAS[ProjectJaina_Radio_DB.station or 1].name) .. "|r")
    mainFrame.stationLabel = stationLabel

    -- Slider de Volumen
    local volSlider = CreateFrame("Slider", "ProjectJaina_RadioVolSlider", mainFrame, "OptionsSliderTemplate")
    volSlider:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -20, -108)
    volSlider:SetWidth(130)
    volSlider:SetMinMaxValues(0, 100)
    local initialVol = ProjectJaina_Radio_DB.volume or 70
    lastSentVolume = initialVol
    volSlider:SetValue(initialVol)
    volSlider:SetValueStep(5)
    _G[volSlider:GetName() .. "Low"]:SetText("0%")
    _G[volSlider:GetName() .. "High"]:SetText("100%")
    _G[volSlider:GetName() .. "Text"]:SetText("Volumen (" .. initialVol .. "%)")
    volSlider:SetScript("OnValueChanged", function(self, val)
        val = math.floor(val + 0.5)
        ProjectJaina_Radio_DB.volume = val
        _G[self:GetName() .. "Text"]:SetText("Volumen (" .. val .. "%)")
        if ProjectJaina_Radio_DB.mode == "local" then
            SetCVar("Sound_MusicVolume", tostring(val / 100))
        end
        if not self._suppressSync and val ~= lastSentVolume then
            lastSentVolume = val
            SendRadioCommand("VOL", val)
        end
    end)
    mainFrame.volSlider = volSlider

    -- Botón de Portal Web
    local btnPortal = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    btnPortal:SetSize(130, 20)
    btnPortal:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 12, 10)
    btnPortal:SetText("Abrir Portal Web")
    btnPortal:SetScript("OnClick", function()
        StaticPopup_Show("PROJECTJAINA_RADIO_URL")
        RadioPrint("Abre tu navegador en: |cFF00FFCChttps://darckrovert.github.io/ProjectJaina_Web/radio/|r")
    end)

    function mainFrame:UpdateUI()
        local isPlay = ProjectJaina_Radio_DB.isPlaying
        self.btnPlay:SetText(isPlay and "|| Pausa" or "> Play")
        self.btnMode:SetText(ProjectJaina_Radio_DB.mode == "web" and "Modo: Web 24/7" or "Modo: Local")
        local curSt = EMISORAS[ProjectJaina_Radio_DB.station or 1]
        self.stationLabel:SetText("Emisora: |cFF00FFCC" .. curSt.name .. "|r")
        self.marqueeText:SetText("|cFFFFFFFF" .. nowPlayingTitle .. "|r")
        local targetVol = ProjectJaina_Radio_DB.volume or 70
        lastSentVolume = targetVol
        self.volSlider._suppressSync = true
        self.volSlider:SetValue(targetVol)
        self.volSlider._suppressSync = false
    end

    local pos = ProjectJaina_Radio_DB.framePos
    if type(pos) == "table" and #pos == 5 then
        mainFrame:ClearAllPoints()
        mainFrame:SetPoint(pos[1], UIParent, pos[3], pos[4], pos[5])
    else
        mainFrame:ClearAllPoints()
        mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    end

    if not ProjectJaina_Radio_DB.shown then
        mainFrame:Hide()
    end
end

----------------------------------------------------------------------------
--  Botón de Minimapa
----------------------------------------------------------------------------
local function CreateMinimapButton()
    local btn = CreateFrame("Button", "ProjectJaina_RadioMinimapButton", Minimap)
    btn:SetSize(32, 32)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)

    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", 0, 0)
    icon:SetTexture("Interface\\Icons\\INV_Gizmo_02") -- Gramófono / Artefacto Arcano
    btn.icon = icon

    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT", 0, 0)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    local function Reposition(angle)
        local rad = math.rad(angle)
        local cos, sin = math.cos(rad), math.sin(rad)
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (80 * cos), (80 * sin) - 52)
    end

    local wasDragged = false
    local function OnDragUpdate(self)
        local mx, my = Minimap:GetCenter()
        local cx, cy = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        cx, cy = cx / scale, cy / scale
        local angle = math.deg(math.atan2(cy - my, cx - mx))
        if angle < 0 then angle = angle + 360 end
        ProjectJaina_Radio_DB.minimapAngle = angle
        Reposition(angle)
        wasDragged = true
    end

    btn:RegisterForClicks("LeftButtonUp")
    btn:RegisterForDrag("LeftButton")
    btn:SetScript("OnDragStart", function(self)
        wasDragged = false
        self:LockHighlight()
        self:SetScript("OnUpdate", OnDragUpdate)
    end)

    btn:SetScript("OnDragStop", function(self)
        self:UnlockHighlight()
        self:SetScript("OnUpdate", nil)
    end)

    btn:SetScript("OnClick", function()
        if wasDragged then
            wasDragged = false
            return
        end
        if not mainFrame then CreateRadioFrame() end
        if mainFrame:IsShown() then
            mainFrame:Hide()
            ProjectJaina_Radio_DB.shown = false
        else
            mainFrame:Show()
            ProjectJaina_Radio_DB.shown = true
        end
    end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("|cFFD4AF37Project Jaina Radio|r", 1, 1, 1)
        GameTooltip:AddLine("Emisora: |cFF00CCFF" .. (EMISORAS[ProjectJaina_Radio_DB.station or 1].name) .. "|r", 0.9, 0.9, 0.9)
        GameTooltip:AddLine("Estado: |cFFFFFF00" .. (ProjectJaina_Radio_DB.isPlaying and "En Reproducción" or "Pausado") .. "|r", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("|cFF808080Click para abrir o cerrar sintonizador.|r", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    Reposition(ProjectJaina_Radio_DB.minimapAngle or dbDefaults.minimapAngle)
end

----------------------------------------------------------------------------
--  Control de Eventos & AddOn Message
----------------------------------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")

eventFrame:SetScript("OnEvent", function(self, event, arg1, arg2, arg3, arg4)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        if RegisterAddonMessagePrefix then
            RegisterAddonMessagePrefix(PREFIJO_RADIO)
        end
        -- Inicializar SavedVariables
        for k, v in pairs(dbDefaults) do
            if ProjectJaina_Radio_DB[k] == nil then
                ProjectJaina_Radio_DB[k] = v
            end
        end

        CreateRadioFrame()
        CreateMinimapButton()

        RadioPrint("v" .. VERSION .. " cargado exitosamente. Escribe |cFF00FFCC/radio|r para sintonizar.")

    elseif event == "CHAT_MSG_ADDON" and arg1 == PREFIJO_RADIO then
        local msg = arg2
        if not msg then return end

        -- Formato: TITLE:<trackName>
        local titleMatch = msg:match("^TITLE:(.+)")
        if titleMatch then
            nowPlayingTitle = titleMatch
            if mainFrame and mainFrame.marqueeText then
                mainFrame.marqueeText:SetText("|cFFFFFFFF" .. nowPlayingTitle .. "|r")
            end
        end
    end
end)

----------------------------------------------------------------------------
--  Comandos /slash (/radio, /jainaradio)
----------------------------------------------------------------------------
function ProjectJaina_Radio_ToggleUI()
    if not mainFrame then CreateRadioFrame() end
    if mainFrame:IsShown() then
        mainFrame:Hide()
        ProjectJaina_Radio_DB.shown = false
    else
        mainFrame:Show()
        ProjectJaina_Radio_DB.shown = true
    end
end
_G.ProjectJaina_Radio_ToggleUI = ProjectJaina_Radio_ToggleUI

SLASH_PROJECTJAINA_RADIO1 = "/radio"
SLASH_PROJECTJAINA_RADIO2 = "/jainaradio"
SlashCmdList["PROJECTJAINA_RADIO"] = function(msg)
    local cmd, arg = strsplit(" ", strtrim(msg or ""), 2)
    cmd = (cmd or ""):lower()

    if cmd == "" then
        ProjectJaina_Radio_ToggleUI()
    elseif cmd == "play" then
        PlayCurrentStation()
    elseif cmd == "pause" or cmd == "stop" then
        PauseCurrentStation()
    elseif cmd == "next" then
        NextStation()
    elseif cmd == "prev" then
        PrevStation()
    elseif cmd == "station" or cmd == "emisora" then
        local idx = tonumber(arg)
        if idx then SetStation(idx)
        else RadioPrint("Uso: /radio station <1-" .. #EMISORAS .. ">") end
    elseif cmd == "vol" or cmd == "volume" then
        local v = tonumber(arg)
        if v then SetVolume(v)
        else RadioPrint("Uso: /radio vol <0-100>") end
    elseif cmd == "mode" or cmd == "modo" then
        ToggleMode()
    elseif cmd == "help" or cmd == "ayuda" then
        RadioPrint("=== Comandos de Kirin Tor Radio ===")
        RadioPrint("/radio - Abre o cierra la interfaz")
        RadioPrint("/radio play / pause / stop - Control de reproducción")
        RadioPrint("/radio next / prev - Siguiente o anterior emisora")
        RadioPrint("/radio station <1-7> - Cambia de emisora directamente")
        RadioPrint("/radio vol <0-100> - Ajusta el volumen")
        RadioPrint("/radio mode - Alterna entre streaming web y Jukebox local")
    else
        RadioPrint("Comando no reconocido. Escribe |cFF00FFCC/radio help|r para ayuda.")
    end
end


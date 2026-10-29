# 📡 Especificación de API y Protocolo — ProjectJaina_Radio

**Prefijo de Red:** `PJ_RADIO`  
**Backend:** `67_KirinTorRadioBridge.lua` (Eluna Engine)  
**Versión:** 1.0.0  
**Transporte:** `SendAddonMessage` / `CHAT_MSG_ADDON` (Canal: `WHISPER` local / Servidor)  

---

## 1. Definición de Paquetes de Red

### 1.1 Mensajes Emitidos por el Cliente (C -> S)

| Comando | Sintaxis | Descripción |
| :--- | :--- | :--- |
| `SET_STATION` | `SET_STATION:<id>` | Informa al servidor el dial de radio activo (entero 1 a 6) para sincronización de telemetría y título. |
| `VOLUME` | `VOLUME:<vol>` | Envía el volumen configurado por el jugador (entero 0 a 100). |

### 1.2 Mensajes Emitidos por el Servidor (S -> C)

| Comando | Sintaxis | Descripción |
| :--- | :--- | :--- |
| `TITLE` | `TITLE:<trackName>` | Notifica el título o programa actualmente en emisión para su despliegue en la barra de estado del AddOn. |

---

## 2. Esquema de Persistencia (`SavedVariablesPerCharacter: ProjectJaina_Radio_DB`)

El estado de la radio se almacena de forma independiente por cada personaje en `WTF\SavedVariables\ProjectJaina_Radio.lua`:

```lua
ProjectJaina_Radio_DB = {
    station = 1,                                       -- Emisora activa (entero 1..6)
    volume = 70,                                      -- Nivel de volumen (entero 0..100)
    mode = "web",                                     -- Modo acústico: 'web' | 'local'
    isPlaying = false,                                -- Estado del reproductor
    framePos = { "CENTER", "UIParent", "CENTER", 0, 100 }, -- Coordenadas de ventana
    minimapAngle = 45.0,                              -- Ángulo polar en el minimapa (grados)
    shown = false                                     -- Visibilidad de la ventana
}
```

---

## 3. Catálogo de Emisoras Locales (`EMISORAS`)

| ID | Nombre | Género | Ruta de Archivo Nativo (MP3) |
| :--- | :--- | :--- | :--- |
| 1 | Taberna de Theramore | Folk Medieval & Bardo | `Sound\Music\ZoneMusic\Dalaran\DC_Day01.mp3` |
| 2 | Apex Mythic Raider | Orquestal Épico & Batalla | `Sound\Music\GlueScreenMusic\WotLK_main_title.mp3` |
| 3 | Kirin Tor Lofi & Chill | Lo-Fi Beats & Relax | `Sound\Music\ZoneMusic\GrizzlyHills\GH_Day01.mp3` |
| 4 | Sintetizadores de Gnomeregan | Synthwave 80s | `Sound\Music\ZoneMusic\Ulduar\Ulduar_GeneralWalk.mp3` |
| 5 | Forja de Hierro Rock & Metal | Heavy Metal & Hard Rock | `Sound\Music\Musical Moments\L70ETC\` |
| 6 | Tierras Altas de Arathi | Naturaleza & RPG | `Sound\Music\ZoneMusic\DarkmoonFaire\DarkmoonFaire.mp3` |

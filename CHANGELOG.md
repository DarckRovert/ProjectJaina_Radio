# 📋 Registro de Cambios — ProjectJaina_Radio

Todos los cambios notables de este proyecto están documentados en este archivo siguiendo el estándar [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/).

---

## [1.0.0] — 2026-10-28
### Lanzamiento Oficial v1.0.0 — Sintonizador Kirin Tor FM y Jukebox Temático In-Game
- **Arquitectura de Audio Inmersivo (`ProjectJaina_Radio.lua`):**
  - Reproductor de audio nativo mediante APIs oficiales de Blizzard (`PlayMusic`, `StopMusic`) sin modificar binarios ni MPQs.
  - Deck flotante con estética Glassmorphism Kirin Tor, controles de reproducción (Play, Stop, Next, Previous) y deslizador de volumen maestro.
  - Sintonización directa de 7 estaciones temáticas exclusivas:
    1. *Dalaran Arcane Beats* (Lofi ambiental y orquesta arcana).
    2. *Ironforge Forge Metal* (Rock de taberna enano y forja).
    3. *Silvermoon Synthwave* (Sintetizadores y mística de Quel'Thalas).
    4. *Stormwind Royal Symphony* (Himnos y marchas de la Alianza).
    5. *Orgrimmar War Drums* (Percusión y cantos de guerra de la Horda).
    6. *Northrend Glacial Chills* (Atmósferas gélidas y coros de Rasganorte).
    7. *Jaina's Lullaby* (Baladas acústicas y tributo a Jaina Valiente).
- **Protocolo de Red y Sincronización (`67_KirinTorRadioBridge.lua`):**
  - Canal de red AddOn bajo el prefijo `PJ_RADIO` para emisión y sincronización de emisora comunitaria con el backend Eluna.
  - Soporte de enlace directo a la estación web en streaming de alta fidelidad (`/radio web`).
- **Comandos Slash Nativos:**
  - Registrados `/radio` y `/ktfm` con parámetros `play <1-7>`, `stop`, `vol <0-100>` y `web`.
- **Persistencia de Configuración:**
  - Almacenamiento seguro en `SavedVariables: ProjectJaina_RadioDB` (estación activa, volumen preferido, coordenadas del deck).
- **Homologación Documental L9:**
  - Incorporados `AGENTS.md`, `API.md`, `GOVERNANCE.md`, `ECOSYSTEM_REGISTRY.md`, `INSTALL.md`, `NOTICE.md`, `LICENSE` y `SECURITY.md`.

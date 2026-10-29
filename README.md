# 📻 ProjectJaina_Radio — Sintonizador Kirin Tor FM In-Game (WoW 3.3.5a)
## Radio Streaming 24/7 y Jukebox Clásico Integrado en el Cliente de Juego

[![GitHub](https://img.shields.io/badge/GitHub-DarckRovert%2FProjectJaina__Radio-black?logo=github)](https://github.com/DarckRovert/ProjectJaina_Radio)
[![Ecosystem](https://img.shields.io/badge/Project%20Jaina-3.3.5a%20(Build%2012340)-blue)](https://darckrovert.github.io/ProjectJaina_Web/)
[![Standard](https://img.shields.io/badge/Governance-L9%20Staff%20Engineer-gold)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Proyecto:** Project Jaina ([darckrovert.github.io/ProjectJaina_Web](https://darckrovert.github.io/ProjectJaina_Web/))  
**AddOn:** `ProjectJaina_Radio`  
**Cliente:** World of Warcraft: Wrath of the Lich King (3.3.5a, Build 12340)  
**Estándar:** Staff Software Engineer L9 (Claude Mythos 5)  
**Versión:** 1.0.0  

---

## 🏛️ 1. Misión y Capacidades

`ProjectJaina_Radio` es el reproductor de audio oficial integrado en el cliente de juego para **Project Jaina**. Proporciona a los jugadores una experiencia acústica inmersiva que combina la retransmisión continua de las emisoras oficiales del servidor con un modo Jukebox local que aprovecha los recursos orquestales y ambientales de Wrath of the Lich King sin requerir software externo ni saturar el ancho de banda.

### Características Principales:
1. **Doble Modo Operativo (Web Streaming vs Jukebox Local):**
   - **Modo Web:** Sincronización de metadatos en vivo de la emisora comunitaria 24/7 emitida desde el portal oficial ([darckrovert.github.io/ProjectJaina_Web/radio/](https://darckrovert.github.io/ProjectJaina_Web/radio/)).
   - **Modo Local:** Reproducción directa mediante el motor nativo de sonido de WoW 3.3.5a (`PlayMusic` / `StopMusic`) con 6 diales temáticos cuidadosamente orquestados.
2. **6 Emisoras Canónicas:**
   - Dial 1: *Taberna de Theramore* (Folk Medieval & Bardo) — Pista nativa `DC_Day01.mp3`
   - Dial 2: *Apex Mythic Raider* (Orquestal Épico & Batalla) — Pista nativa `WotLK_main_title.mp3`
   - Dial 3: *Kirin Tor Lofi & Chill* (Lo-Fi Beats & Relax) — Pista nativa `GH_Day01.mp3`
   - Dial 4: *Sintetizadores de Gnomeregan* (Synthwave 80s) — Pista nativa `Ulduar_GeneralWalk.mp3`
   - Dial 5: *Forja de Hierro Rock & Metal* (Heavy Metal & Hard Rock) — Pista nativa `L70ETC`
   - Dial 6: *Tierras Altas de Arathi* (Naturaleza, Lluvia & RPG) — Pista nativa `DarkmoonFaire.mp3`
3. **Control Deslizante de Volumen Gradual:** Rango entero de 0 a 100 con normalización matemática al canal de música del cliente sin alterar los efectos sonoros de hechizos ni alertas de combate.
4. **Acceso Dual:** Botón orbital en el minimapa con rotación trigonométrica suave y comando slash rápido (`/radio`).
5. **Cero Impacto de Rendimiento:** Desacoplado de bucles de evento pesado; los cambios de estado se gestionan mediante eventos discretos de interfaz.

---

## 📂 2. Estructura de Archivos del AddOn

| Archivo | Rol Arquitectónico |
| :--- | :--- |
| [`ProjectJaina_Radio.toc`](ProjectJaina_Radio.toc) | Descriptor del AddOn (Interface `30300`, versión `1.0.0`, SavedVariablesPerCharacter). |
| [`ProjectJaina_Radio.lua`](ProjectJaina_Radio.lua) | Implementación integral: ventana Kirin Tor, dial de emisoras, slider de volumen, gestión de `PlayMusic` y botón orbital. |
| [`API.md`](API.md) | Especificación del protocolo de red `PJ_RADIO` y esquema de persistencia. |
| [`AGENTS.md`](AGENTS.md) | Directrices para agentes de IA y restricciones del motor de sonido de WoW 3.3.5a. |
| [`GOVERNANCE.md`](GOVERNANCE.md) | Políticas de audio, preservación Blizzlike y ausencia de latencia. |
| [`ECOSYSTEM_REGISTRY.md`](ECOSYSTEM_REGISTRY.md) | Registro de dependencias cliente-servidor y endpoints del streaming web. |
| [`SECURITY.md`](SECURITY.md) | Blindaje contra picos de ganancia, sanitización de entradas y anti-taint. |
| [`INSTALL.md`](INSTALL.md) | Guía de instalación y configuración de canales de audio. |
| [`NOTICE.md`](NOTICE.md) | Atribución de archivos de sonido Blizzlike y licencia MIT. |
| [`CHANGELOG.md`](CHANGELOG.md) | Registro de versiones y notas de lanzamiento. |
| [`LICENSE`](LICENSE) | Términos de licenciamiento MIT. |
| [`Tests/validate_radio.py`](Tests/validate_radio.py) | Suite de verificación estática de sintaxis y compatibilidad con 3.3.5a. |

---

## 📡 3. Protocolo de Red (`PJ_RADIO`)

La sincronización de títulos de temas y estado de reproducción con el servidor (`67_KirinTorRadioBridge.lua`) opera a través de mensajes de AddOn:

* **Prefijo:** `PJ_RADIO`
* **Mensajes Enviados por el Cliente:**
  - `SET_STATION:<id>`: Informa al servidor el dial seleccionado para sincronizar metadatos.
  - `VOLUME:<vol>`: Notifica cambios de volumen de escucha (para telemetría opcional).
* **Mensajes Recibidos desde el Servidor:**
  - `TITLE:<nombrePista>`: Actualiza en vivo el texto del sintonizador ("En Reproducción: ...").

---

## ⌨️ 4. Comandos de Consola (Slash Commands)

* `/radio`: Abre o cierra la interfaz del sintonizador Kirin Tor FM.

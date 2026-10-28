# 📻 ProjectJaina_Radio — Sintonizador Kirin Tor FM (WoW 3.3.5a)
## Radio Streaming 24/7 y Jukebox Temática In-Game

**Proyecto:** [Project Jaina](https://darckrovert.github.io/ProjectJaina_Web/)  
**AddOn:** `ProjectJaina_Radio`  
**Cliente:** World of Warcraft: Wrath of the Lich King (3.3.5a, Build 12340)  
**Estándar de Ingeniería:** Staff Software Engineer L9 (Claude Mythos 5)  
**Versión:** 1.0.0  
**Fecha de Publicación:** Octubre 2026  

---

## 🎯 1. Visión y Capacidades

`ProjectJaina_Radio` es el reproductor de audio oficial integrado en el cliente para el ecosistema **Project Jaina**. Ofrece una experiencia auditiva inmersiva tanto mediante música ambiental de alta fidelidad integrada en el cliente (Jukebox nativo de WoW) como mediante sincronización con la estación web oficial **Kirin Tor FM** (WebRTC / Icecast).

### Estaciones Disponibles:
1. **Dalaran Arcane Beats:** Lofi ambiental y melodías orquestales arcanas.
2. **Ironforge Forge Metal:** Rock de taberna enano y temas épicos de forja.
3. **Silvermoon Synthwave:** Melodías místicas de Quel'Thalas en clave synth.
4. **Stormwind Royal Symphony:** Marchas e himnos clásicos de la Alianza.
5. **Orgrimmar War Drums:** Percusiones y cantos de guerra de la Horda.
6. **Northrend Glacial Chills:** Atmósferas gélidas y coros de Rasganorte.
7. **Jaina's Lullaby:** Baladas de fantasía acústica y tributo a Jaina Valiente.

---

## 🏗️ 2. Estructura de Archivos

| Archivo | Rol Arquitectónico |
| :--- | :--- |
| `ProjectJaina_Radio.toc` | Descriptor del AddOn (Interface 30300, SavedVariables, metadatos). |
| `ProjectJaina_Radio.lua` | Controlador de audio (`PlayMusic`, `StopMusic`), deck flotante Glassmorphism y puente de red `PJ_RADIO`. |
| `API.md` | Especificación de paquetes y eventos del reproductor. |
| `GOVERNANCE.md` | Marco de gobernanza técnica y estándares L9. |
| `ECOSYSTEM_REGISTRY.md` | Integración con `67_KirinTorRadioBridge.lua`. |
| `SECURITY.md` | Políticas de volumen seguro y anti-desbordamiento. |
| `Tests/validate_radio.py` | Suite de validación de sintaxis y compatibilidad. |

---

## ⚡ 3. Controles y Comandos

| Comando | Acción |
| :--- | :--- |
| `/radio` o `/ktfm` | Alterna la visibilidad de la consola de radio flotante. |
| `/radio play <1-7>` | Sintoniza directamente una de las 7 estaciones temáticas. |
| `/radio stop` | Detiene inmediatamente la reproducción de música. |
| `/radio vol <0-100>` | Ajusta el volumen maestro de la radio. |
| `/radio web` | Abre el enlace directo al streaming de audio de alta fidelidad. |

---

## 🛡️ 4. Cumplimiento Legal

100% libre de modificación de binarios ejecutables o MPQs. Distribuido bajo licencia **MIT** de acuerdo con la Blizzard Custom UI Policy (2009).\n
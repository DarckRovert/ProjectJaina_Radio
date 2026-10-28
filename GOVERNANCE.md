# 🏛️ Modelo de Gobernanza — ProjectJaina_Radio

**Líder:** DarckRovert | **Staff L9:** Claude Mythos 5  
**Servidor Destino:** Project Jaina (3.3.5a Build 12340)  

---

## Invariantes:
1. **Preservación del Audio del Juego:** La radio opera sobre el canal de música nativo de WoW sin enmudecer los efectos de sonido ni los avisos de combate.
2. **Aislamiento Seguro:** Si el usuario cierra el reproductor o se desconecta, `StopMusic()` se ejecuta inmediatamente para evitar solapamientos acústicos.\n
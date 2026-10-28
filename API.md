# 📡 Especificación de API y Protocolo — ProjectJaina_Radio

**Prefijo de Red:** `PJ_RADIO`  
**Canales:** `WHISPER`, `GUILD`, `PARTY`  
**Versión:** 1.0.0  

---

## 1. Comandos de Red del Servidor (`67_KirinTorRadioBridge.lua`)

El servidor puede sincronizar anuncios globales de radio o música para eventos específicos en Dalaran o bandas:

```
SYNC\t<stationId>\t<trackName>\t<timestamp>
```

- `stationId`: Identificador entero [1..7].
- `trackName`: Nombre amigable de la pista en reproducción.
- `timestamp`: Marca de tiempo del servidor para sincronización.

---

## 2. Persistencia (`SavedVariablesPerCharacter: ProjectJaina_Radio_DB`)

```lua
ProjectJaina_Radio_DB = {
    currentStation = 1,
    volume = 0.8,
    isMuted = false,
    autoPlayOnLogin = false,
    framePosition = { "CENTER", nil, "CENTER", 0, 0 }
}
```\n
# 🤖 Directrices para Agentes de IA — ProjectJaina_Radio

> **Documento Maestro de Arquitectura, Restricciones y Memoria Operativa**  
> **Ámbito:** `Client\Interface\AddOns\ProjectJaina_Radio\`  
> **Persona:** 'Claude Mythos 5' — Staff Software Engineer (L9)  

---

## 1. Leyes Inviolables de Implementación Acústica

1. **Uso Exclusivo del Canal de Música:**
   Toda reproducción local debe realizarse mediante `PlayMusic(path)` y detenerse con `StopMusic()`. Jamás utilizar `PlaySound()` ni `PlaySoundFile()` para música continua, ya que estos canales saturan el subsistema de efectos de sonido del motor del cliente.
2. **Cero Pistas Anacrónicas o Externas sin Empaquetar:**
   Las rutas asignadas en `EMISORAS` deben existir de forma garantizada dentro de los archivos MPQ de World of Warcraft: Wrath of the Lich King 3.3.5a (`Patch-WotLK.mpq` o `Common.mpq`).
3. **Persistencia por Personaje:**
   El AddOn utiliza `SavedVariablesPerCharacter: ProjectJaina_Radio_DB` en su `.toc`. Los agentes no deben renombrar esta tabla a `SavedVariables` globales sin considerar la experiencia individualizada por personaje.
4. **Resiliencia ante Desconexión o Cambio de Zona:**
   Al cerrar la ventana o cambiar de zona, si el usuario detiene la radio, debe invocarse `StopMusic()` inmediatamente para evitar solapamientos con la música ambiental del mundo.

# 🛡️ Política de Seguridad — ProjectJaina_Radio

**Proyecto:** Project Jaina  
**Estándar:** Staff Software Engineer L9 (Mythos 5)  

---

## 1. Normalización de Ganancia Acústica
El volumen configurado por el usuario se mapea a través de la C-API del cliente `SetCVar("Sound_MusicVolume", vol / 100)`. El valor está acotado estrictamente entre 0 y 100 enteros para impedir distorsiones de onda o saturación en el mezclador de sonido.

## 2. Sanitización de Strings de Servidor
El parámetro recibido por `TITLE:<trackName>` se procesa mediante expresiones regulares seguras para eliminar secuencias de control no deseadas antes de asignarlo a la etiqueta gráfica del sintonizador.

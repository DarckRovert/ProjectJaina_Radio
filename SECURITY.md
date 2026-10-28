# 🛡️ Política de Seguridad — ProjectJaina_Radio

**Proyecto:** Project Jaina  
**Estándar:** Staff Software Engineer L9 (Mythos 5)  

---

## 1. Rango Seguro de Volumen
El volumen está acotado estrictamente entre `0.0` y `1.0` en punto flotante para prevenir daños auditivos o distorsiones de ganancia en el motor de audio.

## 2. Higiene de Comandos
Todos los argumentos pasados por `/radio` son parseados numéricamente con validación de límites antes de invocar APIs del cliente.\n
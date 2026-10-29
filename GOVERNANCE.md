# 🏛️ Modelo de Gobernanza — ProjectJaina_Radio

**Líder del Proyecto & Autor:** DarckRovert (Ingame: `Elnazzareno`)  
**Staff AI Engineer:** Antigravity L9 (Mythos 5)  
**Servidor Destino:** [Project Jaina](https://darckrovert.github.io/ProjectJaina_Web/)  
**Versión:** 1.0.0  

---

## 1. Misión y Alcance
Proveer una solución musical integrada que enriquezca las sesiones de juego de la comunidad sin obligar al usuario a recurrir a navegadores web externos o reproductores pesados en segundo plano.

## 2. Invariantes de Calidad de Vida
1. **Preservación del Rendimiento:** El AddOn no ejecuta temporizadores continuos de alta frecuencia (`OnUpdate`) excepto durante el arrastre interactivo de la ventana o del botón del minimapa.
2. **No Intrusividad:** El reproductor inicia pausado por defecto (`isPlaying = false`) respetando la ambientación predeterminada del jugador hasta que decida activarlo manualmente.

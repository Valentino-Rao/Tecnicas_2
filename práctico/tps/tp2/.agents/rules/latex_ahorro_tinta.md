---
description: "Fuerza el uso de fuentes y estilos ecologicos para ahorrar tinta en documentos LaTeX."
trigger: "always_on"
---

# Regla de Ahorro de Tinta en LaTeX

Siempre que el usuario te pida crear, modificar o compilar un documento en LaTeX (`.tex`), DEBES aplicar las siguientes directivas para minimizar el consumo de tinta de impresora:

1. **Evitar cajas con fondos sólidos oscuros**: No uses colores de fondo (colback) fuertes en `tcolorbox`. Usa siempre fondos blancos (`colback=white`) o grises extremadamente claros (`gray!5`) si es indispensable.
2. **Fuentes finas (Light Fonts)**: Prioriza paquetes de fuentes más finas que la media para ahorrar tóner. (Ej: `\usepackage{lmodern}` con un grosor light, o fuentes sans-serif finas).
3. **Escala de grises**: A menos que se pida a color, fuerza esquemas de colores monocromáticos. 
4. **No incrustar la fuente Ecofont propietaria** a menos que el usuario tenga los archivos `.ttf` locales, pero usa estrategias de diseño "light" por defecto.

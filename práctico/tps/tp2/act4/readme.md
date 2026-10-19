# Técnicas Digitales 2 — Trabajo Práctico 2, Actividad 4

Este repositorio contiene el código fuente y el informe para la **Actividad 4 del Trabajo Práctico 2** de la materia **Técnicas Digitales 2**. 

El objetivo del proyecto es implementar una comunicación bidireccional asíncrona entre una computadora (Host Linux) y una placa de desarrollo **BluePill** (basada en el microcontrolador **STM32F103** de ARM Cortex-M3), utilizando programación bare-metal y el estándar CMSIS.

## Autores
* Braida Agustín (404621)
* Ernst Pedro (400624)
* Polizze Tomas (400793)
* Valentino Rao (402308)

---

## Estructura del Proyecto

* **`práctico/Tps/TP2/act4/src/main.c`**: Código fuente principal ejecutado en la BluePill. Configura el periférico USART1, el temporizador SysTick para retardos no bloqueantes, y la rutina de servicio de interrupción (ISR) para la recepción serie asíncrona.
* **`práctico/Tps/TP2/act4/lecturadesdePC.c`**: Aplicación interactiva en C para la PC (Linux). Configura el puerto serie en modo *raw* usando la librería `termios.h`, muestra un menú al usuario, envía las opciones seleccionadas y lee las respuestas devueltas por la placa.
* **`práctico/Tps/TP2/act4/informe/main.tex`**: Documento fuente en LaTeX con el informe técnico completo bajo el formato IEEE.
* **`práctico/Tps/TP2/act4/Makefile`**: Archivo de automatización para compilar y grabar el firmware del microcontrolador.

---

## Conexión Física (Pinout)

Para la comunicación, se requiere conectar la BluePill a la PC mediante un conversor USB-to-UART (como un CP2102 o FT232RL). La conexión eléctrica debe realizarse de forma cruzada e incluir una masa de referencia común:

| BluePill (STM32F103) | Dirección | Conversor USB-UART |
| :---: | :---: | :---: |
| **PA9 (TX)** | $\rightarrow$ | **RXD** |
| **PA10 (RX)** | $\leftarrow$ | **TXD** |
| **GND** | $\leftrightarrow$ | **GND** |

---

## Guía de Uso paso a paso

### 1. Compilar y Grabar la BluePill
Desde la terminal en el directorio del microcontrolador (`práctico/Tps/TP2/act4`):

1. **Compilar el código**:
   ```bash
   make
   ```
2. **Grabar el firmware** (requiere programador ST-Link conectado):
   ```bash
   make flash-openocd
   ```
   *Nota: Si utilizas otro programador, puedes modificar la receta de grabación en el `Makefile`.*

### 2. Ejecutar la Aplicación en la PC
Desde la terminal en el directorio donde se encuentra el archivo `lecturadesdePC.c`:

1. **Compilar la aplicación host**:
   ```bash
   gcc lecturadesdePC.c -o lecturadesdePC
   ```
2. **Ejecutar con permisos de superusuario** (necesarios para acceder al dispositivo serie `/dev/ttyUSB0`):
   ```bash
   sudo ./lecturadesdePC
   ```

### 3. Opciones del Menú de Control
Al iniciar la aplicación de la PC, se desplegará la siguiente consola interactiva:
* **`1`**: Enciende el LED incorporado de la BluePill (pin PC13 a nivel bajo). Retorna: *BluePill responde: LED encendido*.
* **`2`**: Apaga el LED de la placa (pin PC13 a nivel alto). Retorna: *BluePill responde: LED apagado*.
* **`3`**: Activa el parpadeo asíncrono no bloqueante del LED cada 500 ms controlado por SysTick. Retorna: *BluePill responde: LED parpadeando*.
* **`0`**: Apaga el LED, envía un acuse de recibo y cierra ordenadamente la aplicación de la PC.

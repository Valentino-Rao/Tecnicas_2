# Banco de Preguntas y Variantes de Examen Teórico — Técnicas Digitales II
**Universidad Tecnológica Nacional — Facultad Regional Córdoba (UTN FRC)**  
**Cátedra:** Dr. Ing. Steiner Guillermo  
**Hardware & Entorno:** STM32F103 (ARM Cortex-M3 @ 72 MHz), CMSIS & FreeRTOS v10.x  

---

## 📑 Índice de Contenidos
1. [Bloque 1: Preguntas de FreeRTOS (Nuevo Programa)](#bloque-1-preguntas-de-freertos-nuevo-programa)
   - [Categoría 1.1: Preguntas Conceptuales y de Desarrollo](#categoría-11-preguntas-conceptuales-y-de-desarrollo)
   - [Categoría 1.2: Comparación y Diferencias](#categoría-12-comparación-y-diferencias)
   - [Categoría 1.3: Múltiple Opción («Marque la/s afirmación/es»)](#categoría-13-múltiple-opción-marques-afirmaciones)
   - [Categoría 1.4: Interrupciones y Procesamiento Diferido (Con Incisos)](#categoría-14-interrupciones-y-procesamiento-diferido-con-incisos)
2. [Bloque 2: Versiones Alternativas / Cruzadas de Preguntas Tradicionales](#bloque-2-versiones-alternativas--cruzadas-de-preguntas-tradicionales)
   - [Grupo A: Arquitectura del Computador y CPU](#grupo-a-arquitectura-del-computador-y-cpu)
   - [Grupo B: Protocolos de Comunicación Serie (I2C ↔ SPI ↔ UART)](#grupo-b-protocolos-de-comunicación-serie-i2c--spi--uart)
   - [Grupo C: Toolchain, Compilación y Linker Script](#grupo-c-toolchain-compilación-y-linker-script)
   - [Grupo D: Interrupciones (NVIC) y GPIOs de la BluePill](#grupo-d-interrupciones-nvic-y-gpios-de-la-bluepill)
3. [Bloque 3: Solucionario y Respuestas Modelo Desarrolladas](#bloque-3-solucionario-y-respuestas-modelo-desarrolladas)
   - [Respuestas a Preguntas de FreeRTOS (Bloque 1)](#respuestas-a-preguntas-de-freertos-bloque-1)
   - [Respuestas a Preguntas Tradicionales y Variantes (Bloque 2)](#respuestas-a-preguntas-tradicionales-y-variantes-bloque-2)

---

# Bloque 1: Preguntas de FreeRTOS (Nuevo Programa)

### Categoría 1.1: Preguntas Conceptuales y de Desarrollo

#### Pregunta F1 (Definición RTOS y Tareas)
* **a)** ¿Qué es un Sistema Operativo en Tiempo Real (RTOS) y cuál es la diferencia conceptual entre un sistema *Hard Real-Time* y uno *Soft Real-Time*?
* **b)** ¿Por qué la función principal de una tarea (*Task*) nunca debe retornar mediante la instrucción `return`? ¿Cómo debe finalizar una tarea correctamente?

#### Pregunta F2 (FSM de Estados de Tarea)
Dibuje o describa la Máquina de Estados de una tarea en FreeRTOS (*Running*, *Ready*, *Blocked*, *Suspended*) indicando qué evento provoca la transición entre el estado *Ready* y *Blocked*, y qué ocurre cuando se cumple un retardo de tiempo o arriba un dato a una cola.

#### Pregunta F3 (Tarea Idle y Hooks)
* **a)** ¿Cuál es la función principal de la tarea *Idle*, con qué nivel de prioridad se ejecuta y por qué es indispensable que siempre exista al menos una tarea en estado *Ready*?
* **b)** ¿Para qué se utiliza la función `vApplicationIdleHook()` y qué regla de oro debe respetar obligatoriamente su implementación respecto a las funciones de bloqueo (*blocking calls*)?

---

### Categoría 1.2: Comparación y Diferencias

#### Pregunta F4 (vTaskDelay vs vTaskDelayUntil)
* **a)** ¿Cuál es la diferencia de funcionamiento entre `vTaskDelay()` y `vTaskDelayUntil()`?
* **b)** ¿A qué se denomina «deriva temporal» (*drift* acumulativo o *jitter*) y cuál de las dos funciones garantiza una frecuencia de ejecución periódica fija y exacta?

#### Pregunta F5 (Semáforo Binario vs Mutex)
* **a)** ¿Cuál es la diferencia conceptual entre un Semáforo Binario y un Mutex (*Mutual Exclusion*) en FreeRTOS?
* **b)** ¿Qué problema crítico de los sistemas en tiempo real soluciona el mecanismo de *Priority Inheritance* (Herencia de Prioridad) presente en los Mutex?

---

### Categoría 1.3: Múltiple Opción («Marque la/s afirmación/es»)

#### Pregunta F6 (Planificador y Prioridades)
Marque la/s afirmación/es que caracterizan al Planificador (*Scheduler*) de FreeRTOS:
* [ ] **a)** Una tarea de mayor prioridad numérica en ejecución desaloja (*preempts*) inmediatamente a una tarea de menor prioridad cuando esta última pasa a estado *Ready*.
* [ ] **b)** Si existen múltiples tareas en estado *Ready* con la misma prioridad, el planificador reparte el uso de la CPU entre ellas mediante *Time-Slicing* (Round-Robin en cada Tick).
* [ ] **c)** La prioridad 0 representa la máxima prioridad posible de asignación para tareas de usuario.
* [ ] **d)** Si una tarea de alta prioridad entra en un bucle infinito sin invocar funciones de bloqueo (como `vTaskDelay` o recepción de colas), las tareas de menor prioridad sufren *inanición* (*starvation*).

#### Pregunta F7 (Colas de Mensajes — Queues)
Marque la/s afirmación/es correctas sobre las Colas (*Queues*) en FreeRTOS:
* [ ] **a)** Los datos se almacenan en la cola por defecto mediante **Copia por Valor** (*Deep Copy*), permitiendo que la tarea emisora modifique o destruya su variable local inmediatamente tras el envío.
* [ ] **b)** Cuando una tarea intenta leer de una cola vacía con `xTicksToWait = portMAX_DELAY`, la tarea consume el 100% de los ciclos de CPU en espera activa (*polling*).
* [ ] **c)** Si se envían punteros a estructuras grandes por la cola para optimizar memoria, la memoria apuntada no debe residir en el *stack* de una función efímera.
* [ ] **d)** Las colas de FreeRTOS no permiten el acceso sincronizado desde múltiples tareas simultáneas.

---

### Categoría 1.4: Interrupciones y Procesamiento Diferido (Con Incisos)

#### Pregunta F8 (Interrupciones y la API `...FromISR`)
En relación a la interacción entre interrupciones de hardware (ISRs) y FreeRTOS:
* **a)** ¿Por qué no se pueden utilizar las funciones estándar de la API (ej. `xQueueSend`, `xSemaphoreGive`) dentro de una ISR y debe usarse obligatoriamente la variante con sufijo `...FromISR`?
* **b)** ¿Cuál es el propósito del parámetro `pxHigherPriorityTaskWoken` y qué efecto produce invocar la macro `portYIELD_FROM_ISR()` al finalizar la rutina de interrupción?
* **c)** Describa el patrón de diseño de **«Procesamiento Diferido de Interrupciones»** (*Deferred Interrupt Processing*) indicando qué operaciones ejecuta la mitad rápida (*Top-Half*) y la mitad lenta (*Bottom-Half*).

---
---

# Bloque 2: Versiones Alternativas / Cruzadas de Preguntas Tradicionales

### Grupo A: Arquitectura del Computador y CPU

#### Pregunta 1 (Original): ¿Qué es un microcontrolador?
* 👉 **Variante 1A (Microcontrolador vs Microprocesador):**  
  ¿Cuál es la diferencia fundamental entre un **Microprocesador** y un **Microcontrolador** en cuanto a su nivel de integración física (CPU, memorias, periféricos), costo y campo de aplicación típica?
* 👉 **Variante 1B (Sistemas Embebidos vs Computación General):**  
  Defina qué es un **Sistema Embebido** y mencione cuatro restricciones críticas de diseño que lo diferencian de una computadora de uso general (PC).

#### Preguntas 2 y 4 (Originales): Arquitectura Load/Store
* 👉 **Variante 2A (Filosofías RISC vs CISC):**  
  Compare las filosofías de arquitectura **RISC (ej. ARM)** y **CISC (ej. x86)** respecto a:
  * **a)** Longitud y complejidad de las instrucciones de máquina.
  * **b)** Modos de acceso a la memoria RAM para operaciones aritmético-lógicas.
  * **c)** Cantidad promedio de ciclos de reloj por instrucción (CPI).
* 👉 **Variante 4A (Múltiple Opción — ARM Cortex-M3 y Buses):**  
  Marque la/s afirmación/es correctas sobre la arquitectura interna del ARM Cortex-M3:
  * [ ] **a)** Implementa una arquitectura Harvard Modificada con buses independientes para instrucciones (I-Code) y datos (D-Code).
  * [ ] **b)** Todas las instrucciones del juego Thumb-2 tienen una longitud fija y estricta de 64 bits.
  * [ ] **c)** El procesador accede a los registros de periféricos mapeados en memoria utilizando las mismas instrucciones de carga y almacenamiento (`LDR` / `STR`) que usa para la RAM.
  * [ ] **d)** El modelo de memoria es plano (*flat*) con un espacio direccionable de 4 GiB (32 bits de direcciones).

---

### Grupo B: Protocolos de Comunicación Serie (I2C ↔ SPI ↔ UART)

#### Pregunta 3 (Original): En I2C, describa el propósito del 9no bit
* 👉 **Variante 3A (I2C: START, STOP y Drenador Abierto):**  
  En el bus I2C:
  * **a)** ¿Cómo se generan físicamente las condiciones de **START** y **STOP** en relación a los estados de las líneas SDA y SCL?
  * **b)** ¿Por qué las líneas I2C deben configurarse obligatoriamente en modo **Drenador Abierto (*Open-Drain*) con resistencias Pull-Up** y qué ventaja ofrece la lógica *Wired-AND* resultante (arbitraje multimaestro y *clock stretching*)?
* 👉 **Variante 3B (Cambio I2C → SPI: Modos CPOL y CPHA):**  
  En el protocolo SPI:
  * **a)** ¿Qué función cumplen los parámetros de configuración **CPOL** (*Clock Polarity*) y **CPHA** (*Clock Phase*)?
  * **b)** Complete el nivel de reposo de `SCK` y el flanco de captura de dato para los modos:
    * **Modo 0:** $\text{CPOL}=0, \text{CPHA}=0$.
    * **Modo 3:** $\text{CPOL}=1, \text{CPHA}=1$.

#### Pregunta 5 (Original): En RS-232: Sincronización, Baud rate vs Bit rate, Trama
* 👉 **Variante 5A (UART: Sobremuestreo x16 y Trama 8N1):**  
  En una interfaz UART asíncrona:
  * **a)** ¿Cómo logra el receptor sincronizarse con el transmisor sin línea de reloj compartida y para qué se utiliza el **sobremuestreo por 16** ($\times 16$)?
  * **b)** Dibuje y describa la trama completa de un carácter transmitido en formato **8N1** (Start, Datos, Paridad, Stop), indicando el orden de transmisión de los bits (LSB primero).
  * **c)** Si se transmite a 9600 baudios en formato 8N1, ¿cuántos caracteres útiles por segundo se envían como máximo?
* 👉 **Variante 5B (Gran Cuadro Comparativo de Protocolos Serie):**  
  Elabore un cuadro comparativo entre **SPI, I2C y UART/RS-232** indicando para cada uno:
  1. Tipo de sincronismo (Síncrono / Asíncrono).
  2. Cantidad de líneas físicas requeridas.
  3. Modo de transmisión (Full-Duplex / Half-Duplex).
  4. Método de selección o direccionamiento del esclavo (Hardware por pin CS / Software por trama).

#### Pregunta 10 (Original): Trama SPI e Inicio de Comunicación
* 👉 **Variante 10A (Topologías de Red SPI):**  
  En un sistema SPI con un microcontrolador Maestro y 4 Esclavos:
  * **a)** Describa la diferencia entre la topología en **Estrella (*Independent Slave Select*)** y la topología en **Cascada (*Daisy-Chain*)**.
  * **b)** ¿Cuántos pines GPIO del maestro se consumen en cada topología para controlar los 4 esclavos?

---

### Grupo C: Toolchain, Compilación y Linker Script

#### Pregunta 6 (Original): Diferencia entre compilador y enlazador
* 👉 **Variante 6A (Las 4 Fases de GNU GCC):**  
  Describa las cuatro etapas secuenciales que transforman el código fuente en C (`.c`) en un binario ejecutable (`.elf`), indicando la herramienta responsable de cada etapa:
  1. Preprocesamiento (`cpp`)
  2. Compilación (`cc1`)
  3. Ensamblado (`as`)
  4. Enlazado (`ld`)
* 👉 **Variante 6B (Linker Script y Dualidad LMA vs VMA):**  
  En el archivo *Linker Script* (`.ld`):
  * **a)** ¿Cuál es la diferencia entre la dirección de carga (**LMA**) y la dirección de ejecución (**VMA**)?
  * **b)** ¿Por qué la sección `.data` debe tener su LMA en memoria Flash y su VMA en memoria RAM?

#### Pregunta 9 (Original): Lenguaje Máquina vs Ensamblador
* 👉 **Variante 9A (El Ensamblador de 2 Pasadas):**  
  * **a)** ¿Qué diferencia existe entre un archivo fuente en ensamblador (`.s`) y un archivo objeto relocable (`.o`)?
  * **b)** ¿Por qué el ensamblador (`as`) necesita realizar **dos pasadas** sobre el código fuente para resolver las referencias a etiquetas?
* 👉 **Variante 9B (Secciones de un archivo objeto ELF):**  
  Explique qué contenido almacena cada una de las siguientes secciones en un ejecutable ELF y en qué memoria física (Flash o RAM) reside cada una:
  * `.text`
  * `.rodata`
  * `.data`
  * `.bss`

---

### Grupo D: Interrupciones (NVIC) y GPIOs de la BluePill

#### Pregunta 7 (Original): Tabla de Vectores de Interrupción
* 👉 **Variante 7A (Auto-Stacking y EXC_RETURN en Cortex-M3):**  
  En el manejo de excepciones del ARM Cortex-M3:
  * **a)** ¿Qué 8 registros apila automáticamente el hardware en el *Stack* al ingresar a una interrupción y por qué esto evita tener que salvar registros en ensamblador?
  * **b)** ¿Qué valor especial se carga en el registro `LR` al entrar a la interrupción (`EXC_RETURN`) y cómo sabe la CPU si debe retornar a *Thread Mode* usando MSP o PSP?
* 👉 **Variante 7B (Prioridades NVIC y Tail-Chaining):**  
  * **a)** En el NVIC, ¿qué diferencia existe entre la **Prioridad de Grupo (*Preemption Priority*)** y la **Sub-prioridad**?
  * **b)** ¿Qué es la optimización de **Tail-Chaining** (*Encadenamiento de cola*) y cuántos ciclos de reloj ahorra en transiciones entre interrupciones consecutivas?

#### Pregunta 8 (Original): Configuración de GPIO en BluePill
* 👉 **Variante 8A (Decodificación de CNF y MODE en STM32):**  
  En los registros de configuración de GPIO del STM32 (`GPIOx->CRL` y `GPIOx->CRH`):
  * **a)** ¿Qué función cumplen los bits `MODE[1:0]` y los bits `CNF[1:0]` para cada pin?
  * **b)** Indique qué valores de bits `CNF` y `MODE` se deben escribir para configurar:
    1. **Entrada Analógica** (para el ADC).
    2. **Salida Push-Pull digital** a 10 MHz.
    3. **Salida Función Alternativa Push-Pull** a 50 MHz (para USART1 TX).

---
---

# Bloque 3: Solucionario y Respuestas Modelo Desarrolladas

### Respuestas a Preguntas de FreeRTOS (Bloque 1)

#### Respuesta F1 (RTOS y Tareas)
* **a)** Un **RTOS** (*Real-Time Operating System*) es un sistema operativo cuyo planificador (*Scheduler*) garantiza **determinismo temporal** (tiempos de respuesta acotados, predecibles y repetibles ante eventos del entorno).
  * **Hard Real-Time:** El cumplimiento del plazo (*deadline*) es una restricción funcional estricta. Un solo fallo o retraso (incluso de microsegundos) representa una **falla catastrófica total del sistema** con riesgo de daños materiales o vidas humanas (ej. disparo de airbag, marcapasos, frenos ABS).
  * **Soft Real-Time:** El incumplimiento esporádico de un plazo degrada la calidad del servicio percibida por el usuario, pero el sistema continúa operando de forma segura y estable (ej. actualización de pantalla LCD, streaming de audio).
* **b)** Una tarea en FreeRTOS ejecuta un bucle infinito `for(;;)` o `while(1)`. Si la función ejecutara un `return`, intentaría saltar a una dirección de retorno inexistente en su stack, provocando un fallo de hardware irrecuperable (**`HardFault`**). Para finalizar una tarea correctamente, debe destruirse de forma explícita invocando `vTaskDelete(NULL)`.

#### Respuesta F2 (FSM de Estados)
Los 4 estados de una tarea son:
1. **Running (En Ejecución):** La CPU está ejecutando las instrucciones de la tarea (solo 1 tarea a la vez en procesadores mononúcleo).
2. **Ready (Lista):** La tarea tiene todos los recursos disponibles para ejecutarse, pero espera que el Scheduler le asigne la CPU porque actualmente corre otra tarea de igual o mayor prioridad.
3. **Blocked (Bloqueada):** La tarea está a la espera de un evento temporal (transcurso de un `vTaskDelay`) o de sincronización (llegada de un dato a una Queue, entrega de un Semáforo o Mutex). **No consume ciclos de CPU.**
4. **Suspended (Suspendida):** Tarea detenida explícitamente mediante `vTaskSuspend()`. Solo reanuda si otra tarea o ISR ejecuta `vTaskResume()`.
* *Transición Ready → Blocked:* Ocurre cuando la tarea en ejecución invoca una función bloqueante con tiempo de espera mayor a cero (ej. `vTaskDelay(100)` o `xQueueReceive(..., portMAX_DELAY)`). Al expirar el tiempo o arribar el evento, el kernel la mueve automáticamente a estado *Ready*.

#### Respuesta F3 (Tarea Idle y Hooks)
* **a)** La tarea **Idle** es creada automáticamente por el kernel al iniciar el scheduler (`vTaskStartScheduler()`) con la **Prioridad 0** (mínima). Es indispensable para garantizar que siempre exista al menos una tarea en estado *Ready* y que la CPU nunca quede flotante sin código a ejecutar cuando todas las tareas de usuario estén bloqueadas. Además, es la responsable de **liberar la memoria dinámica (Stack y TCB)** de las tareas que hayan sido eliminadas con `vTaskDelete()`.
* **b)** `vApplicationIdleHook()` es una función de enganche ejecutada en cada ciclo de la tarea Idle. Sirve para poner el microcontrolador en modo de bajo consumo (`__WFI()` — *Wait For Interrupt*) o refrescar el perro guardián (*Watchdog*). **Regla de oro obligatoria:** No debe contener bajo ningún concepto llamadas a funciones bloqueantes (`vTaskDelay`, esperas de colas/semáforos), ya que si la tarea Idle se bloquea, el kernel colapsa y no se puede liberar memoria.

#### Respuesta F4 (vTaskDelay vs vTaskDelayUntil)
* **a)** `vTaskDelay(n)` genera un retardo **relativo** contado a partir del momento en que se ejecuta la llamada. `vTaskDelayUntil(&xLastWakeTime, periodo)` calcula el instante de despertar respecto al inicio del período anterior de forma **absoluta**.
* **b)** La **deriva temporal (*drift*)** es el corrimiento acumulativo del período debido al tiempo que la tarea tarda en ejecutarse más el tiempo que otras tareas de mayor prioridad le quitan a la CPU. `vTaskDelay()` acumula deriva; **`vTaskDelayUntil()` es libre de deriva (*drift-free*)**, garantizando una frecuencia de ejecución fija y exacta (ideal para lazos de control PID y muestreo ADC).

#### Respuesta F5 (Semáforo Binario vs Mutex)
* **a)** El **Semáforo Binario** se utiliza para **sincronización y señalización de eventos** (una ISR o tarea *entrega* el semáforo para avisar que terminó un evento, y otra tarea lo *toma*). No existe concepto de propiedad (*ownership*). El **Mutex** se utiliza para **exclusión mutua sobre recursos compartidos** (la misma tarea que toma el Mutex debe ser obligatoriamente quien lo libere).
* **b)** El Mutex implementa **Herencia de Prioridad (*Priority Inheritance*)**: si una tarea de baja prioridad retiene un Mutex que es solicitado por una tarea de alta prioridad, el kernel eleva temporalmente la prioridad de la tarea baja a la de la alta, evitando que tareas de prioridad media se interpongan y provoquen el fenómeno de **Inversión de Prioridad No Acotada**.

#### Respuesta F6 (Múltiple Opción Planificador)
* **Respuestas Correctas: a, b y d.**
  * *Justificación de c (Falsa):* La prioridad 0 es la prioridad mínima (la de Idle); la máxima es `configMAX_PRIORITIES - 1`.

#### Respuesta F7 (Múltiple Opción Queues)
* **Respuestas Correctas: a y c.**
  * *Justificación de b (Falsa):* La tarea se bloquea inmediatamente pasando a estado *Blocked* (consumo 0% de CPU).
  * *Justificación de d (Falsa):* Las colas son estructuras concurrentes (*Thread-Safe*) con colas de espera automáticas para múltiples tareas emisoras y receptoras.

#### Respuesta F8 (Interrupciones y Procesamiento Diferido)
* **a)** Las funciones estándar pueden bloquear a la tarea llamadora si el recurso no está disponible; las rutinas de servicio de interrupción (ISRs) de hardware **no tienen contexto de tarea y nunca pueden bloquearse**. Las versiones `...FromISR` nunca se bloquean y son atómicas.
* **b)** `pxHigherPriorityTaskWoken` es una variable que la función `...FromISR` pone en `pdTRUE` si la acción realizada desbloqueó a una tarea de mayor prioridad a la interrumpida. La macro `portYIELD_FROM_ISR()` solicita la excepción `PendSV` para forzar un cambio de contexto inmediato al retornar de la ISR, ejecutando la tarea de alta prioridad sin esperar al siguiente Tick de SysTick.
* **c)** **Top-Half (ISR de hardware):** Es ultracorta (microsegundos); atiende el periférico físico, limpia el flag de interrupción, entrega un semáforo o encola el dato con `...FromISR` y sale. **Bottom-Half (Tarea Servidora):** Tarea de alta prioridad que despierta inmediatamente con el semáforo y realiza todo el procesamiento pesado a nivel de hilo (*Thread Mode*), manteniendo el sistema receptivo a nuevas interrupciones.

---

### Respuestas a Preguntas Tradicionales y Variantes (Bloque 2)

#### Respuesta 1 / 1A / 1B (Microcontrolador y Sistemas Embebidos)
* **Microcontrolador vs Microprocesador:** El microprocesador integra únicamente la CPU (ALU, banco de registros, unidad de control) y requiere memorias RAM, Flash y controladores de periféricos externos en la placa base. El microcontrolador integra en un **único chip de silicio (*Single-Chip*)** la CPU, memoria no volátil (Flash), memoria volátil (SRAM), osciladores y periféricos (GPIO, ADC, Timers, UART, SPI, I2C), optimizando costo, consumo de energía y espacio.
* **Sistema Embebido:** Sistema computacional diseñado para realizar una función dedicada dentro de un sistema eléctrico o mecánico mayor. **Restricciones:** 1) Costo unitario estricto; 2) Consumo de potencia y energía limitado (batería); 3) Confiabilidad y seguridad funcional (*safety-critical*); 4) Determinismo temporal en tiempo real.

#### Respuesta 2 / 4 / 2A / 4A (Arquitectura Load/Store y RISC vs CISC)
* **Arquitectura Load/Store (RISC):** Las operaciones aritmético-lógicas (`ADD`, `SUB`, `AND`) operan **exclusivamente sobre registros internos de la CPU**. La memoria RAM no puede intervenir directamente como operando aritmético; el acceso a RAM se realiza únicamente mediante instrucciones explícitas de carga (`LDR`) y almacenamiento (`STR`).
* **Comparación RISC vs CISC:**
  * *Instrucciones:* RISC tiene instrucciones de longitud fija (16/32 bits en Thumb-2), simples y ortogonales. CISC tiene instrucciones de longitud variable (1 a 15 bytes en x86) y complejas.
  * *Acceso a RAM:* RISC es Load/Store estricto. CISC permite operaciones con operandos en memoria (ej. `ADD [EBX], EAX`).
  * *CPI:* RISC tiene un $\text{CPI} \approx 1$. CISC tiene un CPI alto y variable (de 2 a decenas de ciclos).
* **Múltiple Opción Original:** **Correcta: b** (*las operaciones que acceden a memoria no permiten operaciones aritméticas simultáneas*).
* **Múltiple Opción 4A:** **Correctas: a, c y d.** *(La b es falsa porque Thumb-2 usa 16 y 32 bits, no 64 bits)*.

#### Respuesta 3 / 3A / 3B (Bus I2C y SPI)
* **Propósito del 9no bit en I2C:** Es el bit de **Reconocimiento (ACK / NACK)**. Tras transmitir los 8 bits de datos, en el 9no ciclo de reloj de SCL, el emisor libera la línea SDA y el receptor debe responder forzando SDA a **nivel bajo (0V = ACK)** para confirmar recepción correcta, o dejarla en **nivel alto (3.3V = NACK)** para indicar fin de lectura, dispositivo ocupado o dirección inexistente.
* **Drenador Abierto (*Open-Drain*) y Wired-AND:** Ningún nodo puede forzar activamente un nivel alto (3.3V); solo pueden drenar a masa (0V) o quedar en alta impedancia (Hi-Z), siendo el nivel alto provisto por resistencias *Pull-Up* pasivas. Esto evita cortocircuitos si dos nodos transmiten a la vez y permite la lógica *Wired-AND* indispensable para el **Arbitraje Multimaestro** (quien envía 1 pero lee 0 pierde el arbitraje sin corromper la trama) y el **Clock Stretching** (un esclavo lento mantiene SCL en 0 para pausar al maestro).
* **SPI CPOL y CPHA:**
  * **CPOL (Polaridad):** Nivel de reposo de SCK ($0 = \text{Bajo } 0\text{V}$; $1 = \text{Alto } 3.3\text{V}$).
  * **CPHA (Fase):** Flanco de muestreo ($0 = \text{Muestreo en 1er flanco}$; $1 = \text{Muestreo en 2do flanco}$).
  * **Modo 0 (0,0):** Reposo en BAJO, captura de dato en el **primer flanco ascendente (subida)**.
  * **Modo 3 (1,1):** Reposo en ALTO, captura de dato en el **segundo flanco ascendente (subida)**.

#### Respuesta 5 / 5A / 5B (RS-232 / UART)
* **a) Sincronización y Sobremuestreo $\times 16$:** Al ser asíncrono (sin señal de reloj compartida), la línea reposa en nivel alto ($1$ lógico). La sincronización se logra con el flanco de bajada del **Bit de START** ($0$ lógico). El hardware receptor ejecuta un reloj interno a $16 \times \text{BaudRate}$; al detectar el flanco de START, cuenta 8 ciclos para posicionarse en el **centro geométrico del bit** y toma las muestras 8, 9 y 10 aplicando **votación por mayoría de 2 sobre 3** para eliminar ruido.
* **b) Baud Rate vs Bit Rate:** **Baud Rate** es el número de cambios de estado eléctrico (símbolos) por segundo en el medio físico. **Bit Rate** es la tasa de bits de información útil transmitidos por segundo. En modulación binaria TTL/RS-232, $1\text{ baudio} = 1\text{ bps}$.
* **c) Trama 8N1 y Tasa Útil:** Cada carácter contiene **10 bits totales**: 1 bit Start + 8 bits Datos (LSB primero) + 0 bits Paridad + 1 bit Stop.  
  A 9600 baudios: $\frac{9600\text{ baudios}}{10\text{ bits/carácter}} = \mathbf{960\text{ caracteres útiles por segundo}}$.
* **d) Gran Cuadro Comparativo:**
  | Parámetro | SPI | I2C | UART / RS-232 |
  | :--- | :--- | :--- | :--- |
  | **Sincronismo** | Síncrono (línea SCK) | Síncrono (línea SCL) | Asíncrono (acuerdo previo de baudios) |
  | **Líneas Físicas** | 4 (MOSI, MISO, SCK, CS) | 2 (SDA, SCL) | 2 (TX, RX) |
  | **Modo de Transmisión** | Full-Duplex | Half-Duplex | Full-Duplex |
  | **Direccionamiento** | Hardware (pin CS dedicado) | Software (7 o 10 bits en la trama) | Punto a punto (sin direccionamiento) |

#### Respuesta 6 / 6A / 6B (Toolchain y Linker Script)
* **Compilador vs Enlazador:** El **Compilador (`cc1`)** traduce el código fuente de alto nivel (`.c`) a código ensamblador (`.s`), realizando análisis léxico, sintáctico, semántico y optimización. El **Enlazador (`ld`)** toma múltiples archivos objeto (`.o`) y librerías (`.a`), resuelve las referencias cruzadas de símbolos externos, agrupa las secciones homogéneas y asigna las direcciones físicas de memoria definitivas según el *Linker Script*.
* **Las 4 Fases de GNU GCC:**
  1. *Preprocesador (`cpp`):* Expande macros `#define`, resuelve `#include` y directivas condicionales (`.c` → `.i`).
  2. *Compilador (`cc1`):* Traduce C a ensamblador ARMv7-M (`.i` → `.s`).
  3. *Ensamblador (`as`):* Traduce mnemónicos a código máquina binario en dos pasadas (`.s` → `.o`).
  4. *Enlazador (`ld`):* Resuelve símbolos y genera el ejecutable reubicable (`.o` → `.elf`).
* **LMA vs VMA:** **LMA (*Load Memory Address*)** es la dirección física en memoria Flash no volátil donde se graba la sección. **VMA (*Virtual/Execution Memory Address*)** es la dirección física en memoria RAM donde la CPU lee y modifica los datos durante la ejecución. La sección `.data` requiere LMA en Flash (para no perder sus valores iniciales ante cortes de energía) y VMA en RAM (para que el procesador pueda modificar sus valores en tiempo de ejecución).

#### Respuesta 7 / 7A / 7B (Tabla de Vectores y NVIC Cortex-M3)
* **Tabla de Vectores:** Arreglo continuo de punteros de 32 bits ubicado en el inicio de la Flash (`0x0800_0000`). Contiene el valor inicial del puntero de pila (`_estack` en posición 0) y las direcciones de entrada (*Handlers*) de todas las excepciones e interrupciones del microcontrolador.
* **Auto-Stacking (8 Registros):** Al ocurrir una interrupción, el hardware apila automáticamente en exactamente 12 ciclos los registros *Caller-Saved* según el estándar AAPCS: **`R0, R1, R2, R3, R12, LR, PC, xPSR`**. Esto permite escribir rutinas de interrupción (ISRs) como funciones estándar de C sin necesidad de código ensamblador para salvar el contexto.
* **EXC_RETURN:** Código de 32 bits con formato `0xFFFFFFFx` cargado por hardware en el registro `LR` al entrar a una ISR. Al ejecutar la instrucción de retorno `bx lr`, el procesador detecta el patrón y realiza el desapilamiento automático restaurando el contexto previo (retornando a *Thread Mode* con MSP o PSP según los bits de `EXC_RETURN`).
* **Prioridad de Grupo vs Sub-prioridad:** La **Prioridad de Grupo (*Preemption Priority*)** determina si una interrupción entrante puede **desalojar y anidarse** sobre una ISR en ejecución. La **Sub-prioridad** solo desempata el orden de atención cuando dos interrupciones del mismo grupo se disparan de forma estrictamente simultánea.
* **Tail-Chaining:** Optimización por hardware donde, al terminar una ISR y haber otra pendiente, la CPU **no desapila ni vuelve a apilar los 8 registros**, saltando directamente al nuevo handler en solo **6 ciclos de reloj** (ahorrando 18 ciclos de sobrecarga).

#### Respuesta 8 / 8A (Configuración de GPIOs en STM32)
* **Registros CRL y CRH:** Cada puerto dispone de 32 bits en `CRL` (pines 0 a 7) y `CRH` (pines 8 a 15), asignando 4 bits a cada pin: `MODE[1:0]` (dirección y velocidad máxima) y `CNF[1:0]` (configuración de entrada o salida).
* **Combinaciones de bits:**
  1. **Entrada Analógica (ADC):** `CNF = 00`, `MODE = 00` (`0x0`).
  2. **Salida Push-Pull Digital (10 MHz):** `CNF = 00`, `MODE = 01` (`0x1`).
  3. **Salida Función Alternativa Push-Pull (50 MHz, USART1 TX):** `CNF = 10`, `MODE = 11` (`0xB`).

#### Respuesta 9 / 9A / 9B (Lenguaje Máquina vs Ensamblador y Secciones ELF)
* **Lenguaje Máquina vs Ensamblador:** El **lenguaje ensamblador** es un lenguaje textual compuesto por mnemónicos legibles por el programador (`MOV R0, #1`, `LDR`, `STR`). El **lenguaje máquina** es el código binario nativo (ceros y unos) que el hardware decodifica y ejecuta directamente.
* **Ensamblador de Dos Pasadas:** En la **1ra pasada**, construye la *Tabla de Símbolos* asignando un offset a cada etiqueta y detecta referencias hacia adelante (*forward references*). En la **2da pasada**, traduce cada instrucción a binario reemplazando las etiquetas por sus valores y emite el archivo `.o`.
* **Secciones ELF:**
  * `.text`: Código de máquina ejecutable de las funciones (Flash).
  * `.rodata`: Constantes declaradas con `const` y cadenas literales de texto (Flash).
  * `.data`: Variables globales y estáticas con valor inicial distinto de cero (LMA en Flash, VMA en RAM).
  * `.bss`: Variables globales y estáticas no inicializadas o inicializadas a cero (RAM, limpiada a 0 en el arranque por el `Reset_Handler`).

#### Respuesta 10 / 10A (SPI Inicio y Topologías)
* **Inicio de Comunicación SPI:** El maestro baja la línea **Chip Select (`CS / NSS = 0`)** del esclavo seleccionado, activa el generador de reloj `SCK` y transfiere datos bit a bit simultáneamente por `MOSI` (salida del maestro) y `MISO` (entrada del maestro).
* **Topologías SPI:**
  * **Topología Estrella (*Independent CS*):** Las líneas `SCK`, `MOSI` y `MISO` se comparten en paralelo y cada esclavo tiene una línea `CS` dedicada. Para 4 esclavos consume **7 pines en el maestro** (3 de bus + 4 de CS).
  * **Topología Cascada (*Daisy-Chain*):** Una sola línea `CS` compartida activa a todos los esclavos; el pin `MOSI` entra al primer esclavo, su `MISO` se conecta al `MOSI` del siguiente y el último vuelve al maestro como un gran registro de desplazamiento serie. Consume **únicamente 4 pines en el maestro**, sin importar la cantidad de esclavos.

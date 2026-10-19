#include <stdint.h>
#include <stdio.h>
#include "stm32f1xx.h"
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"

/* ==========================================================================
 * PRÁCTICA GUIADA PARA EL SEGUNDO PARCIAL PRÁCTICO - TÉCNICAS DIGITALES 2
 * PARTE 1: TP4 - SISTEMAS OPERATIVOS EN TIEMPO REAL (FreeRTOS v10.x + CMSIS)
 * ==========================================================================
 * Instrucciones:
 * - Completá únicamente los bloques que están entre los comentarios:
 *   // ===== TU CODIGO AQUI =====
 * - Podés usar tu cheatsheet de FreeRTOS y CMSIS para guiarte.
 * - Los ejercicios van de menor a mayor dificultad, guiándote paso a paso
 *   a construir desde una tarea elemental hasta el sistema completo del TP4.
 * ========================================================================== */

/* --------------------------------------------------------------------------
 * EJERCICIO 1: Tarea Elemental y Retardos No Bloqueantes (Blinky a 5 Hz)
 * Objetivo: Crear una tarea que haga parpadear el LED de la placa (PC13) a
 * una frecuencia de 5 Hz (período = 200 ms -> 100 ms ON, 100 ms OFF) usando
 * vTaskDelay() para liberar el uso de la CPU.
 * -------------------------------------------------------------------------- */

void vTareaBlinky(void *pvParameters) {
    (void)pvParameters;

    /* ===== TU CODIGO AQUI ===== */
    // 1. Configurar el pin PC13 como Salida Push-Pull a 2MHz en CMSIS:
    //    a) Habilitar el reloj del puerto C en RCC->APB2ENR (bit 4)
    //    b) Limpiar los bits 20..23 del registro GPIOC->CRH
    //    c) Configurar modo = 0x2 (Salida Push-Pull a 2 MHz) en GPIOC->CRH
    
    
    // 2. Bucle infinito de la tarea (¡NUNCA debe retornar!)
    while (1) {
        // a) Invertir (toggle) el estado del pin PC13 usando GPIOC->ODR (bit 13)
        

        // b) Bloquear la tarea durante exactamente 100 ms usando vTaskDelay()
        //    Tip: Usá la macro pdMS_TO_TICKS(100) para convertir ms a ticks.
        
    }
    /* ========================== */
}

void ej1_crear_tarea_blinky(void) {
    /* ===== TU CODIGO AQUI ===== */
    // 3. Crear la tarea Blinky en el kernel usando xTaskCreate():
    //    - Función: vTareaBlinky
    //    - Nombre: "Blinky"
    //    - Stack: configMINIMAL_STACK_SIZE (en palabras de 32 bits)
    //    - Parámetro: NULL
    //    - Prioridad: tskIDLE_PRIORITY + 2
    //    - Handle: NULL (no necesitamos guardarlo)
    

    /* ========================== */
}


/* --------------------------------------------------------------------------
 * EJERCICIO 2: Concurrencia, Prioridades y Telemetría Serie (UART)
 * Objetivo: Crear la Tarea B de Telemetría que transmita periódicamente
 * una cadena de texto por USART1 cada 2 segundos, con menor prioridad que
 * la Tarea A de Blinky (tskIDLE_PRIORITY + 1).
 * -------------------------------------------------------------------------- */

static void usart1_init_cmsis(void) {
    /* ===== TU CODIGO AQUI ===== */
    // 1. Habilitar relojes de GPIOA y USART1 en RCC->APB2ENR
    

    // 2. Configurar PA9 (TX) como Función Alternativa Push-Pull a 50 MHz (Modo = 0xB) en GPIOA->CRH
    

    // 3. Configurar Baud Rate a 115200 bps con clock de bus a 72 MHz en USART1->BRR (0x0271)
    

    // 4. Habilitar Transmisor (TE) y Módulo USART (UE) en USART1->CR1
    

    /* ========================== */
}

static void uart_enviar_cadena(const char *cadena) {
    /* ===== TU CODIGO AQUI ===== */
    // 5. Recorrer la cadena y transmitir caracter por caracter:
    //    a) Esperar que el buffer esté vacío (flag TXE en USART1->SR)
    //    b) Escribir el caracter en USART1->DR
    

    /* ========================== */
}

void vTareaTelemetria(void *pvParameters) {
    (void)pvParameters;

    /* ===== TU CODIGO AQUI ===== */
    // 6. Bucle infinito de la tarea:
    while (1) {
        // a) Transmitir la cadena fija: "Sistema Operativo FreeRTOS Activo\r\n"
        

        // b) Bloquear la tarea durante 2 segundos (2000 ms) usando vTaskDelay()
        
    }
    /* ========================== */
}


/* --------------------------------------------------------------------------
 * EJERCICIO 3: Monitor de CPU Ociosa mediante Idle Hook
 * Objetivo: Medir el tiempo que la CPU permanece sin carga real utilizando
 * la función vApplicationIdleHook() e informar el contador por telemetría.
 * -------------------------------------------------------------------------- */

volatile uint32_t g_idle_cycles_counter = 0;

void vApplicationIdleHook(void) {
    /* ===== TU CODIGO AQUI ===== */
    // 1. Incrementar el contador global de ciclos ociosos en cada vuelta:
    //    ¡REGLA DE ORO DE FREERTOS!: En esta función JAMÁS se debe llamar a
    //    funciones bloqueantes (vTaskDelay, xQueueReceive con espera, etc.).
    

    /* ========================== */
}

void vTareaTelemetriaConIdle(void *pvParameters) {
    (void)pvParameters;
    char buffer_msg[64];

    /* ===== TU CODIGO AQUI ===== */
    // 2. Bucle infinito:
    while (1) {
        // a) Guardar y resetear de forma atómica el valor de g_idle_cycles_counter
        

        // b) Formatear el mensaje: "CPU Idle count: %lu\r\n" usando snprintf
        

        // c) Transmitir el mensaje formateado por UART
        

        // d) Bloquear la tarea durante 2000 ms
        
    }
    /* ========================== */
}


/* --------------------------------------------------------------------------
 * EJERCICIO 4: Comunicación entre Tareas mediante Colas (Queue)
 * Objetivo: Resolver un patrón Productor-Consumidor.
 * - Tarea Productora: Lee un valor analógico (simulado o ADC) cada 100 ms y
 *   lo envía a una Cola (FIFO) de 10 elementos de 16 bits.
 * - Tarea Consumidora: Espera en la cola y al recibir el valor lo envía por UART.
 * -------------------------------------------------------------------------- */

QueueHandle_t xAdcQueue = NULL;

void ej4_crear_cola(void) {
    /* ===== TU CODIGO AQUI ===== */
    // 1. Crear una cola para 10 elementos de tipo uint16_t usando xQueueCreate()
    //    Guardar el handle en xAdcQueue y verificar que no retorne NULL.
    

    /* ========================== */
}

void vTareaProductor(void *pvParameters) {
    (void)pvParameters;
    uint16_t muestra_adc = 0;

    /* ===== TU CODIGO AQUI ===== */
    // 2. Bucle infinito del Productor:
    while (1) {
        // a) Simular una lectura incrementando o leyendo el sensor:
        muestra_adc = (muestra_adc + 10) % 4096;

        // b) Enviar la variable 'muestra_adc' (por copia de valor) a xAdcQueue:
        //    Timeout de espera: 10 ms (pdMS_TO_TICKS(10))
        

        // c) Pausar la tarea durante 100 ms antes de la siguiente muestra
        
    }
    /* ========================== */
}

void vTareaConsumidor(void *pvParameters) {
    (void)pvParameters;
    uint16_t dato_recibido = 0;
    char buffer[32];

    /* ===== TU CODIGO AQUI ===== */
    // 3. Bucle infinito del Consumidor:
    while (1) {
        // a) Esperar de forma bloqueante a que llegue un dato a xAdcQueue:
        //    Usar xQueueReceive() con timeout = portMAX_DELAY (la tarea pasa a
        //    Blocked sin consumir ciclos de CPU hasta que haya un elemento).
        

        // b) Si se recibió correctamente el dato, formatear y enviar por UART:
        //    "ADC = %u\r\n"
        
    }
    /* ========================== */
}


/* --------------------------------------------------------------------------
 * EJERCICIO 5: Sincronización entre ISR y Tarea con Semáforo Binario
 * Objetivo: Cuando el ADC finaliza una conversión por hardware, la rutina
 * de interrupción entrega un semáforo binario mediante xSemaphoreGiveFromISR()
 * y solicita un cambio de contexto inmediato con portYIELD_FROM_ISR().
 * -------------------------------------------------------------------------- */

SemaphoreHandle_t xAdcBinarySem = NULL;
volatile uint16_t g_adc_raw_value = 0;

void ej5_crear_semaforo_binario(void) {
    /* ===== TU CODIGO AQUI ===== */
    // 1. Crear el semáforo binario usando xSemaphoreCreateBinary()
    //    Guardar en xAdcBinarySem.
    

    /* ========================== */
}

// Rutina de Servicio de Interrupción del ADC1 (Top-Half)
void ADC1_2_IRQHandler(void) {
    /* ===== TU CODIGO AQUI ===== */
    // 2. Declarar la variable de desalojo iniciada en pdFALSE:
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;

    // 3. Verificar si la interrupción fue por Fin de Conversión (bit EOC en ADC1->SR)
    if (ADC1->SR & ADC_SR_EOC) {
        // a) Leer el registro de datos del ADC y guardarlo en g_adc_raw_value
        //    (La lectura de ADC1->DR limpia automáticamente la bandera EOC)
        

        // b) Entregar el semáforo binario usando la versión segura para ISR:
        //    xSemaphoreGiveFromISR(xAdcBinarySem, &xHigherPriorityTaskWoken);
        

        // c) Solicitar al planificador el cambio de contexto si una tarea de
        //    mayor prioridad fue desbloqueada:
        //    portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
        
    }
    /* ========================== */
}

// Tarea consumidora del semáforo (Bottom-Half)
void vTareaProcesarADC(void *pvParameters) {
    (void)pvParameters;
    uint16_t copia_muestra = 0;

    /* ===== TU CODIGO AQUI ===== */
    // 4. Bucle infinito:
    while (1) {
        // a) Tomar el semáforo con espera infinita: xSemaphoreTake(xAdcBinarySem, portMAX_DELAY)
        

        // b) Al desbloquearse, tomar una copia local segura de g_adc_raw_value
        

        // c) Enviar la copia local a la cola xAdcQueue
        
    }
    /* ========================== */
}


/* --------------------------------------------------------------------------
 * EJERCICIO 6: Integración Completa del TP4 (main.c)
 * Objetivo: Escribir la función principal main() que inicializa el hardware,
 * crea los objetos del kernel (cola, semáforo, tareas) y arranca el scheduler.
 * -------------------------------------------------------------------------- */

int main(void) {
    /* ===== TU CODIGO AQUI ===== */
    // 1. Inicializar periféricos hardware (USART1, ADC1 en PA4, LED en PC13)
    

    // 2. Crear objetos de sincronización y comunicación (Semáforo Binario y Cola)
    

    // 3. Crear las tareas del sistema con sus prioridades:
    //    - Tarea Blinky        (Prioridad = tskIDLE_PRIORITY + 3)
    //    - Tarea Procesar ADC  (Prioridad = tskIDLE_PRIORITY + 2)
    //    - Tarea Telemetría    (Prioridad = tskIDLE_PRIORITY + 1)
    

    // 4. Iniciar el Planificador de FreeRTOS
    //    vTaskStartScheduler();
    

    // 5. Trampa de error si el scheduler retorna por falta de memoria (heap)
    while (1);
    /* ========================== */
}

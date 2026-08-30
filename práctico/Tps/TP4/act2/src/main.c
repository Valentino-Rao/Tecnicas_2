#include <stdint.h>
#include <stdio.h>
#include "stm32f1xx.h"
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"

/* -------------------------------------------------------------------------
 * Handles de Sincronizacion y Comunicacion FreeRTOS
 * ------------------------------------------------------------------------- */
static SemaphoreHandle_t xAdcBinarySem = NULL;
static QueueHandle_t     xAdcQueue     = NULL;

/* Variable compartida para almacenar la muestra leida en la ISR */
static volatile uint16_t g_adc_raw_value = 0;

/* -------------------------------------------------------------------------
 * Funciones de Inicializacion de Hardware (CMSIS)
 * ------------------------------------------------------------------------- */

// Inicializacion de USART1 (PA9 TX a 115200 bps)
static void usart1_init(void)
{
    // Habilitar reloj de GPIOA y USART1
    RCC->APB2ENR |= RCC_APB2ENR_IOPAEN | RCC_APB2ENR_USART1EN;

    // Configurar PA9 como Salida Funcion Alternativa Push-Pull (50 MHz) -> 0xB
    GPIOA->CRH &= ~(GPIO_CRH_CNF9 | GPIO_CRH_MODE9);
    GPIOA->CRH |= (GPIO_CRH_CNF9_1 | GPIO_CRH_MODE9_0 | GPIO_CRH_MODE9_1);

    // Baud Rate a 115200 bps con APB2 a 72 MHz (USARTDIV = 39.0625 -> BRR = 0x0271)
    USART1->BRR = 0x0271;

    // Habilitar Transmisor y Modulo
    USART1->CR1 |= USART_CR1_TE | USART_CR1_UE;
}

static void uart_send_char(char c)
{
    while (!(USART1->SR & USART_SR_TXE));
    USART1->DR = (uint8_t)c;
}

static void uart_send_str(const char *str)
{
    while (*str)
    {
        uart_send_char(*str++);
    }
}

// Inicializacion de ADC1 (Canal 4 en PA4 - Potenciometro)
static void adc1_init(void)
{
    // 1. Habilitar reloj de GPIOA y ADC1
    RCC->APB2ENR |= RCC_APB2ENR_IOPAEN | RCC_APB2ENR_ADC1EN;

    // 2. Prescaler de reloj ADC: 72 MHz / 6 = 12 MHz (maximo permitido 14 MHz)
    RCC->CFGR &= ~RCC_CFGR_ADCPRE;
    RCC->CFGR |= RCC_CFGR_ADCPRE_DIV6;

    // 3. Configurar PA4 como Entrada Analogica (CNF4 = 00, MODE4 = 00)
    GPIOA->CRL &= ~(GPIO_CRL_CNF4 | GPIO_CRL_MODE4);

    // 4. Configurar secuencia: 1 sola conversion en Canal 4 (PA4)
    ADC1->SQR1 = 0; // L = 0 (1 conversion)
    ADC1->SQR3 = 4; // Canal 4 en 1ra posicion

    // 5. Tiempo de muestreo: 239.5 ciclos para Canal 4 (SMP4 = 111)
    ADC1->SMPR2 |= (ADC_SMPR2_SMP4_0 | ADC_SMPR2_SMP4_1 | ADC_SMPR2_SMP4_2);

    // 6. Habilitar Interrupcion por Fin de Conversion (EOCIE)
    ADC1->CR1 |= ADC_CR1_EOCIE;

    // 7. Encender ADC1
    ADC1->CR2 |= ADC_CR2_ADON;

    // Pequeño retardo de estabilizacion
    for (volatile int i = 0; i < 5000; i++);

    // 8. Calibracion del ADC
    ADC1->CR2 |= ADC_CR2_RSTCAL;
    while (ADC1->CR2 & ADC_CR2_RSTCAL);
    ADC1->CR2 |= ADC_CR2_CAL;
    while (ADC1->CR2 & ADC_CR2_CAL);

    // 9. Configurar prioridad en el NVIC (prioridad logica 6 >= SYSCALL_PRIORITY) y habilitar IRQ
    NVIC_SetPriority(ADC1_2_IRQn, 6);
    NVIC_EnableIRQ(ADC1_2_IRQn);
}

/* -------------------------------------------------------------------------
 * Rutina de Interrupcion ADC1 y ADC2 (ISR)
 * ------------------------------------------------------------------------- */
void ADC1_2_IRQHandler(void)
{
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;

    if (ADC1->SR & ADC_SR_EOC)
    {
        // Leer el valor del ADC (la lectura del registro DR limpia la bandera EOC)
        g_adc_raw_value = (uint16_t)(ADC1->DR & 0x0FFF);

        // Notificar a la Tarea Productora entregando el Semaforo Binario
        if (xAdcBinarySem != NULL)
        {
            xSemaphoreGiveFromISR(xAdcBinarySem, &xHigherPriorityTaskWoken);
        }
    }

    // Forzar cambio de contexto si una tarea de mayor prioridad se desbloqueo
    portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
}

/* -------------------------------------------------------------------------
 * Tarea Productora (Producer)
 * - Se ejecuta periodicamente cada 100 ms sin deriva temporal
 * - Dispara la conversion ADC
 * - Espera al Semaforo Binario de fin de conversion
 * - Envia la muestra a la Queue
 * - Prioridad: 2 (Mayor que Consumer)
 * ------------------------------------------------------------------------- */
static void vTaskProducerADC(void *pvParameters)
{
    (void)pvParameters;
    TickType_t xLastWakeTime = xTaskGetTickCount();
    const TickType_t xPeriod = pdMS_TO_TICKS(100); // 100 ms de periodo

    for (;;)
    {
        // 1. Iniciar conversion por software
        ADC1->CR2 |= ADC_CR2_ADON;

        // 2. Esperar a que la ISR entregue el Semaforo Binario
        if (xSemaphoreTake(xAdcBinarySem, pdMS_TO_TICKS(50)) == pdTRUE)
        {
            uint16_t muestra = g_adc_raw_value;

            // 3. Enviar la muestra a la Cola (Queue)
            xQueueSend(xAdcQueue, &muestra, 0);

            // Toggle LED PC13 para indicar produccion
            GPIOC->ODR ^= (1 << 13);
        }

        // 4. Bloquearse hasta el proximo periodo exacto de 100 ms (libre de deriva)
        vTaskDelayUntil(&xLastWakeTime, xPeriod);
    }
}

/* -------------------------------------------------------------------------
 * Tarea Consumidora (Consumer)
 * - Espera datos de la Queue
 * - Formatea y envia el valor de tension por UART1
 * - Prioridad: 1 (Menor que Producer)
 * ------------------------------------------------------------------------- */
static void vTaskConsumerUART(void *pvParameters)
{
    (void)pvParameters;
    uint16_t adc_val = 0;
    char msg_buf[64];

    for (;;)
    {
        // Esperar bloqueado hasta que arribe un dato a la cola
        if (xQueueReceive(xAdcQueue, &adc_val, portMAX_DELAY) == pdPASS)
        {
            // Calculo de tension en milivoltios: V = (ADC * 3300) / 4095
            uint32_t milivolts = ((uint32_t)adc_val * 3300UL) / 4095UL;
            uint32_t volts_ent = milivolts / 1000;
            uint32_t volts_dec = milivolts % 1000;

            // Formatear mensaje
            snprintf(msg_buf, sizeof(msg_buf),
                     "ADC PA4: %4u | Tension: %lu.%03lu V\r\n",
                     adc_val, (unsigned long)volts_ent, (unsigned long)volts_dec);

            // Transmitir por UART
            uart_send_str(msg_buf);
        }
    }
}

/* -------------------------------------------------------------------------
 * Funcion Principal (main)
 * ------------------------------------------------------------------------- */
int main(void)
{
    // Actualizar frecuencia de CPU a 72 MHz
    SystemCoreClockUpdate();

    // Habilitar reloj de GPIOC para LED integrado PC13
    RCC->APB2ENR |= RCC_APB2ENR_IOPCEN;
    GPIOC->CRH &= ~GPIO_CRH_CNF13;
    GPIOC->CRH |= GPIO_CRH_MODE13_0; // Salida 10 MHz Push-Pull
    GPIOC->BSRR = GPIO_BSRR_BS13;   // Apagado inicial

    // Inicializar Perifericos CMSIS
    usart1_init();
    adc1_init();

    uart_send_str("\r\n=== TP4 Ejercicio 2: Productor-Consumidor (ADC + Queue + Semaforo) ===\r\n");

    // 1. Crear el Semaforo Binario para sincronizacion de la conversion
    xAdcBinarySem = xSemaphoreCreateBinary();

    // 2. Crear la Cola (Queue) para almacenar hasta 8 muestras de 16 bits
    xAdcQueue = xQueueCreate(8, sizeof(uint16_t));

    if ((xAdcBinarySem != NULL) && (xAdcQueue != NULL))
    {
        // Crear Tarea Productora (Prioridad 2)
        xTaskCreate(vTaskProducerADC, "Producer_ADC", 256, NULL, 2, NULL);

        // Crear Tarea Consumidora (Prioridad 1)
        xTaskCreate(vTaskConsumerUART, "Consumer_UART", 256, NULL, 1, NULL);

        // Iniciar Scheduler de FreeRTOS
        vTaskStartScheduler();
    }

    // Nunca debe alcanzarse
    for (;;);
}

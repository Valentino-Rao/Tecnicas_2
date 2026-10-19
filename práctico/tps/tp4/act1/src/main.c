#include <stdint.h>
#include <stdio.h>
#include "stm32f1xx.h"
#include "FreeRTOS.h"
#include "task.h"

/* -------------------------------------------------------------------------
 * Variable Global para el Monitor de Sistema (Tarea C / Idle Hook)
 * ------------------------------------------------------------------------- */
volatile uint32_t ulIdleCycleCount = 0;

/* -------------------------------------------------------------------------
 * Funciones Auxiliares de USART1 (PA9 TX)
 * ------------------------------------------------------------------------- */
static void usart1_init(void)
{
    // 1. Habilitar reloj de GPIOA y USART1 (ambos en bus APB2)
    RCC->APB2ENR |= RCC_APB2ENR_IOPAEN | RCC_APB2ENR_USART1EN;

    // 2. Configurar PA9 como Salida Funcion Alternativa Push-Pull (50 MHz)
    //    CNF9 = 10 (AF Push-Pull), MODE9 = 11 (Salida 50 MHz) -> 0xB
    GPIOA->CRH &= ~(GPIO_CRH_CNF9 | GPIO_CRH_MODE9);
    GPIOA->CRH |= (GPIO_CRH_CNF9_1 | GPIO_CRH_MODE9_0 | GPIO_CRH_MODE9_1);

    // 3. Configurar Baud Rate a 115200 bps (APB2 a 72 MHz)
    //    USARTDIV = 72000000 / (16 * 115200) = 39.0625
    //    Mantisa = 39 = 0x27, Fraccion = round(0.0625 * 16) = 1 = 0x1 -> 0x0271
    USART1->BRR = 0x0271;

    // 4. Habilitar Transmisor (TE) y el modulo USART (UE)
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

/* -------------------------------------------------------------------------
 * Tarea A: Blinky de Alta Prioridad
 * - PC13 (LED integrado, logica negativa)
 * - Frecuencia: 5 Hz (Periodo: 200 ms -> 100 ms ON, 100 ms OFF)
 * - Prioridad: 2 (Mayor que Tarea B)
 * ------------------------------------------------------------------------- */
static void vTaskBlinky(void *pvParameters)
{
    (void)pvParameters;

    for (;;)
    {
        // LED ON (activo en bajo)
        GPIOC->BSRR = GPIO_BSRR_BR13;
        vTaskDelay(pdMS_TO_TICKS(100));

        // LED OFF (inactivo en alto)
        GPIOC->BSRR = GPIO_BSRR_BS13;
        vTaskDelay(pdMS_TO_TICKS(100));
    }
}

/* -------------------------------------------------------------------------
 * Tarea B: Telemetria por UART
 * - Envia cada 2 segundos el estado y la cuenta del Idle Hook
 * - Prioridad: 1 (Menor que Tarea A)
 * ------------------------------------------------------------------------- */
static void vTaskTelemetry(void *pvParameters)
{
    (void)pvParameters;
    char buffer[64];

    for (;;)
    {
        // Espera 2 segundos cediendo la CPU
        vTaskDelay(pdMS_TO_TICKS(2000));

        // Formatea y transmite la telemetria
        snprintf(buffer, sizeof(buffer), "Sistema Operativo Ejecutando idle:%lu\r\n", (unsigned long)ulIdleCycleCount);
        uart_send_str(buffer);
    }
}

/* -------------------------------------------------------------------------
 * Tarea C: Monitor de Sistema / Idle Hook
 * - Se invoca automaticamente en cada ciclo de la tarea Idle de FreeRTOS
 * - Mide el tiempo/ciclos que la CPU no tiene tareas listas en ejecucion
 * ------------------------------------------------------------------------- */
void vApplicationIdleHook(void)
{
    ulIdleCycleCount++;
}

/* -------------------------------------------------------------------------
 * Funcion Principal (main)
 * ------------------------------------------------------------------------- */
int main(void)
{
    // Actualizar variable SystemCoreClock a 72 MHz
    SystemCoreClockUpdate();

    // Habilitar reloj de GPIOC para el LED de la placa (PC13)
    RCC->APB2ENR |= RCC_APB2ENR_IOPCEN;

    // Configurar PC13 como salida push-pull 10 MHz
    GPIOC->CRH &= ~GPIO_CRH_CNF13;
    GPIOC->CRH |= GPIO_CRH_MODE13_0;
    GPIOC->BSRR = GPIO_BSRR_BS13; // Apagado inicial

    // Inicializar USART1 para telemetria
    usart1_init();

    // Enviar mensaje de bienvenida inicial
    uart_send_str("\r\n=== TP4 Ejercicio 1: Tareas y Planificacion FreeRTOS ===\r\n");

    // Crear Tarea A (Blinky 5 Hz, Prioridad 2 - Alta)
    xTaskCreate(vTaskBlinky, "Blinky_5Hz", 128, NULL, 2, NULL);

    // Crear Tarea B (Telemetria 2s, Prioridad 1 - Baja)
    xTaskCreate(vTaskTelemetry, "Telemetry", 256, NULL, 1, NULL);

    // Iniciar el planificador de FreeRTOS
    vTaskStartScheduler();

    // Nunca debe alcanzar este punto
    for (;;);
}

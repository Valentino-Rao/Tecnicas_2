#include "stm32f1xx.h"
#include <stdint.h>

// --- Definición de Estados del LED ---
typedef enum {
    LED_STATE_OFF = 0,
    LED_STATE_ON,
    LED_STATE_BLINK
} led_state_t;

// --- Variables Globales Volátiles ---
volatile led_state_t led_mode = LED_STATE_OFF;
volatile uint32_t tick_led = 0;
volatile char command_received = 0;
volatile uint8_t new_command = 0;

// --- Prototipos de Funciones ---
void delay_dummy(volatile uint32_t limite);
void UART_send_char(char c);
void UART_send_string(const char *str);

// =====================================================================
// RUTINAS DE SERVICIO DE INTERRUPCIÓN (ISRs)
// =====================================================================

// Base de tiempo SysTick para el parpadeo asíncrono
void SysTick_Handler(void) {
    if (led_mode == LED_STATE_BLINK) {
        tick_led++;
        if (tick_led >= 500) { // Alternar cada 500 ms (1 Hz de ciclo completo)
            GPIOC->ODR ^= (1 << 13);
            tick_led = 0;
        }
    }
}

// Interrupción de recepción de USART1
void USART1_IRQHandler(void) {
    // Si la interrupción es por recepción (RXNE)
    if (USART1->SR & USART_SR_RXNE) {
        command_received = (char)(USART1->DR & 0xFF);
        new_command = 1;
    }
}

// =====================================================================
// FUNCIONES AUXILIARES
// =====================================================================

void delay_dummy(volatile uint32_t limite) {
    for (volatile uint32_t i = 0; i < limite; i++);
}

// Envía un carácter por USART1
void UART_send_char(char c) {
    while (!(USART1->SR & USART_SR_TXE)); // Esperar a que DR esté vacío
    USART1->DR = c;
}

// Envía una cadena de caracteres por USART1
void UART_send_string(const char *str) {
    while (*str) {
        UART_send_char(*str);
        str++;
    }
}

// =====================================================================
// PROGRAMA PRINCIPAL (MAIN)
// =====================================================================
int main(void) {
    // 1. Habilitar Clocks (GPIOC para el LED, GPIOA para TX/RX, USART1 y AFIO)
    RCC->APB2ENR |= RCC_APB2ENR_IOPCEN | RCC_APB2ENR_IOPAEN | 
                    RCC_APB2ENR_USART1EN | RCC_APB2ENR_AFIOEN;

    // 2. Configurar SysTick a 1ms usando la fuente externa (System clock / 8 = 1MHz)
    SysTick->CTRL &= ~SysTick_CTRL_CLKSOURCE_Msk; 
    SysTick->LOAD = 999; // 1000 ciclos de 1us = 1ms
    SysTick->VAL = 0; 
    SysTick->CTRL |= SysTick_CTRL_TICKINT_Msk | SysTick_CTRL_ENABLE_Msk; 

    // 3. Configurar Pin PC13 (LED integrado) como salida push-pull de 2MHz
    GPIOC->CRH &= ~GPIO_CRH_CNF13_Msk;
    GPIOC->CRH |= GPIO_CRH_MODE13_1; // Mode = 10 (Output 2MHz), CNF = 00 (Push-Pull)
    
    // Inicializar el LED apagado (PC13 es activo bajo en la BluePill)
    GPIOC->ODR |= (1 << 13); 

    // 4. Configurar Pines de USART1:
    // PA9 (TX) -> Alternate Function Push-Pull (CNF = 10, Mode = 11 -> 0xB)
    GPIOA->CRH &= ~(0xF << 4);
    GPIOA->CRH |= (0xB << 4);

    // PA10 (RX) -> Input Floating (CNF = 01, Mode = 00 -> 0x4)
    GPIOA->CRH &= ~(0xF << 8);
    GPIOA->CRH |= (0x4 << 8);

    // 5. Configurar la trama USART1 (8N1 @ 9600 baudios)
    USART1->CR1 &= ~USART_CR1_M;     // M = 0 (8 bits de datos)
    USART1->CR1 &= ~USART_CR1_PCE;   // PCE = 0 (Sin paridad)
    USART1->CR2 &= ~USART_CR2_STOP;  // STOP = 00 (1 bit de stop)
    USART1->BRR = 0x0341;            // 9600 baudios para frecuencia de 8MHz (default HSI)

    // Habilitar USART1, Transmisión (TE) y Recepción (RE)
    USART1->CR1 |= USART_CR1_UE | USART_CR1_TE | USART_CR1_RE;

    // Habilitar interrupción de recepción de USART1 (RXNEIE)
    USART1->CR1 |= USART_CR1_RXNEIE;

    // 6. Configurar el NVIC para la interrupción de USART1
    NVIC_SetPriority(USART1_IRQn, 2); // Prioridad intermedia
    NVIC_EnableIRQ(USART1_IRQn);

    // Bucle principal
    while (1) {
        if (new_command) {
            new_command = 0;
            char cmd = command_received;

            if (cmd == '1') {
                led_mode = LED_STATE_ON;
                GPIOC->ODR &= ~(1 << 13); // Encender LED (Activo Bajo)
                UART_send_string("LED encendido\n");
            } 
            else if (cmd == '2') {
                led_mode = LED_STATE_OFF;
                GPIOC->ODR |= (1 << 13);  // Apagar LED (Activo Bajo)
                UART_send_string("LED apagado\n");
            } 
            else if (cmd == '3') {
                led_mode = LED_STATE_BLINK;
                UART_send_string("LED parpadeando\n");
            } 
            else if (cmd == '0') {
                // Si el usuario elige salir, apagamos el LED y respondemos
                led_mode = LED_STATE_OFF;
                GPIOC->ODR |= (1 << 13);
                UART_send_string("Saliendo\n");
            }
        }
    }
}

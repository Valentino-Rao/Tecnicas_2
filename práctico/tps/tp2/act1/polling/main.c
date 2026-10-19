#include <stdint.h>

// register address
#define RCC_BASE 0x40021000
#define GPIOC_BASE 0x40011000
#define GPIOA_BASE 0x40010800

#define RCC_APB2ENR *(volatile uint32_t *)(RCC_BASE + 0x18)

#define GPIOA_CRL *(volatile uint32_t *)(GPIOA_BASE + 0x00)
#define GPIOA_IDR *(volatile uint32_t *)(GPIOA_BASE + 0x08) // <-- Agregado para leer las entradas
#define GPIOA_ODR *(volatile uint32_t *)(GPIOA_BASE + 0x0C)

#define GPIOC_CRH *(volatile uint32_t *)(GPIOC_BASE + 0x04)
#define GPIOC_ODR *(volatile uint32_t *)(GPIOC_BASE + 0x0C)

// bit fields
#define RCC_IOPCEN (1 << 4)
#define RCC_IOPAEN (1 << 2)
#define GPIOC13 (1UL << 13)
#define GPIOA0 (1UL << 0)
#define GPIOA1 (1UL << 1)

// --- Registros del SysTick (Cortex-M Core) ---
#define SysTick_BASE 0xE000E010
#define SysTick_CTRL *(volatile uint32_t *)(SysTick_BASE + 0x00)
#define SysTick_LOAD *(volatile uint32_t *)(SysTick_BASE + 0x04)
#define SysTick_VAL  *(volatile uint32_t *)(SysTick_BASE + 0x08)

// Bits de control de SysTick
#define SysTick_CTRL_ENABLE    (1 << 0) 
#define SysTick_CTRL_TICKINT   (1 << 1)
#define SysTick_CTRL_CLKSOURCE (1 << 2) 
#define SysTick_CTRL_COUNTFLAG (1 << 16)

volatile uint32_t tick;

void SysTick_Handler(void)
{
    tick++;
}

void systick_init_ms(void)
{
    tick = 0;
    SysTick_CTRL &= ~SysTick_CTRL_CLKSOURCE; 
    SysTick_LOAD = 999; 
    SysTick_VAL = 0; 
    SysTick_CTRL |= SysTick_CTRL_TICKINT | SysTick_CTRL_ENABLE; 
}

// función delay modificada con Polling activo
void delay_ms_bloqueante(uint32_t ms)
{
    uint32_t tiempo_inicio = tick;
    
// Cambiamos la condición para poder controlar el tiempo de forma relativa al inicio
    while ((tick - tiempo_inicio) < ms) 
    {
        // POLLING: Como usamos pull-down interno, el pin lee '0' en reposo.
        // Al presionar el botón, se conecta a VCC (3.3V) y pasa a '1' lógico[cite: 30, 31, 32].
        if (GPIOA_IDR & GPIOA1) 
        {
            // 1. Guardamos el estado actual de los LEDs para poder restaurarlos al soltar
            uint32_t estado_previo_c = GPIOC_ODR & GPIOC13;
            uint32_t estado_previo_a = GPIOA_ODR & GPIOA0;

            // 2. Apagamos de forma obligatoria ambos LEDs inmediatamente
            GPIOC_ODR |= GPIOC13;   // En la BluePill, el '1' apaga el LED integrado (PC13)
            GPIOA_ODR &= ~GPIOA0;  // El '0' apaga el LED externo (PA0)

            // 3. Bucle de congelamiento: El código se detiene acá MIENTRAS el botón siga apretado
            while (GPIOA_IDR & GPIOA1);

            // 4. Al soltar el botón, restauramos los LEDs a como estaban antes del freeze
            GPIOC_ODR = (GPIOC_ODR & ~GPIOC13) | estado_previo_c;
            GPIOA_ODR = (GPIOA_ODR & ~GPIOA0) | estado_previo_a;

            // 5. Reseteamos el tiempo de inicio para que el delay vuelva a contar desde cero 
            // y no se saltee el tiempo remanente por culpa de los ticks acumulados de fondo.
            tiempo_inicio = tick;
        }
    }
}

void main(void)
{
    RCC_APB2ENR |= RCC_IOPCEN | RCC_IOPAEN;

    // Configuración PC13 como Salida (LED integrado)
    GPIOC_CRH &= 0xFF0FFFFF;
    GPIOC_CRH |= 0x00200000;

    // Configuración de los pines de GPIOA (PA0 y PA1)
    // PA0 -> Salida (0x3) para el LED externo
    // PA1 -> Entrada con Pull-up/Pull-down (0x8) para el botón
    GPIOA_CRL &= 0xFFFFFF00; // Limpiamos los bits de PA0 y PA1
    GPIOA_CRL |= 0x00000083; // PA1 = 1000 (Input PUPD) | PA0 = 0011 (Output 50MHz) 

    // Para elegir específicamente PULL-DOWN en PA1, escribimos un 0 en su bit de ODR [cite: 38, 40]
    GPIOA_ODR &= ~GPIOA1; 

    systick_init_ms();
    
    while (1)
    {
        // Encender el LED integrado (poner PC13 en BAJO)
        GPIOC_ODR &= ~GPIOC13;
        delay_ms_bloqueante(500); 
        
        // Apagar el LED integrado (poner PC13 en ALTO)
        GPIOC_ODR |= GPIOC13;
        delay_ms_bloqueante(500); 

        // Encender LED externo
        GPIOA_ODR |= GPIOA0;
        delay_ms_bloqueante(500);
        
        // Apagar LED externo
        GPIOA_ODR &= ~GPIOA0;
        delay_ms_bloqueante(500);
    }
}

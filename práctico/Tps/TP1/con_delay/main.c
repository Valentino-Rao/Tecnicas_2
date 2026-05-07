#include <stdint.h>

// Definiciones de registros (STM32F103)
#define RCC_APB2ENR  (*(volatile uint32_t *)0x40021018)
#define GPIOC_CRH    (*(volatile uint32_t *)0x40011004)
#define GPIOA_CRL    (*(volatile uint32_t *)0x40010800)
#define GPIOC_ODR    (*(volatile uint32_t *)0x4001100C)
#define GPIOA_ODR    (*(volatile uint32_t *)0x4001080C)

// Registros de SysTick
#define STK_CTRL     (*(volatile uint32_t *)0xE000E010)
#define STK_LOAD     (*(volatile uint32_t *)0xE000E014)
#define STK_VAL      (*(volatile uint32_t *)0xE000E018)

void SysTick_Handler(void) {
    // Alternamos PC13 (Led placa) y PA0 (Led externo
    // El operador ^= (XOR) cambia el estado del bit
    GPIOC_ODR ^= (1 << 13);
    GPIOA_ODR ^= (1 << 0);
}

int main(void) {
    // 1. Habilitar relojes para GPIOA y GPIOC
    RCC_APB2ENR |= (1 << 2) | (1 << 4);

    // 2. Configurar PC13 como salida push-pull (General purpose output)
    GPIOC_CRH &= ~(0xF << 20); // Limpiar bits
    GPIOC_CRH |= (0x2 << 20);  // Output 2MHz, Push-pull

    // 3. Configurar PA0 como salida push-pull
    GPIOA_CRL &= ~(0xF << 0);  // Limpiar bits
    GPIOA_CRL |= (0x2 << 0);   // Output 2MHz, Push-pull

    // Inicializar estados opuestos para que alternen
    GPIOC_ODR |= (1 << 13);    // Uno encendido
    GPIOA_ODR &= ~(1 << 0);    // El otro apagado

    // 4. Configurar SysTick
    // Si el clock es 8MHz, 8.000.000 / 2 = 4.000.000 para medio segundo
    STK_LOAD = 4000000 - 1; 
    STK_VAL = 0;
    // Habilitar: Bit 0 (Enable), Bit 1 (Interrupt), Bit 2 (Processor Clock)
    STK_CTRL = 0x07;

    while (1) {
        // El procesador puede dormir o hacer otras tareas aquí
        __asm("wfi"); 
    }
}

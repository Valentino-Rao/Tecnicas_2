#include <stdint.h>

// --- Direcciones Base ---
#define RCC_BASE      0x40021000
#define GPIOA_BASE    0x40010800
#define GPIOC_BASE    0x40011000
#define AFIO_BASE     0x40010000
#define EXTI_BASE     0x40010400
#define NVIC_BASE     0xE000E100
#define SysTick_BASE  0xE000E010 // Agregado para el Timer de la placa

// --- Registros RCC ---
#define RCC_APB2ENR *(volatile uint32_t *)(RCC_BASE + 0x18)

// --- Registros GPIO ---
#define GPIOA_CRL   *(volatile uint32_t *)(GPIOA_BASE + 0x00)
#define GPIOA_CRH   *(volatile uint32_t *)(GPIOA_BASE + 0x04) // Necesario para el pin PA8
#define GPIOA_IDR   *(volatile uint32_t *)(GPIOA_BASE + 0x08)
#define GPIOA_ODR   *(volatile uint32_t *)(GPIOA_BASE + 0x0C)

#define GPIOC_CRH   *(volatile uint32_t *)(GPIOC_BASE + 0x04)
#define GPIOC_ODR   *(volatile uint32_t *)(GPIOC_BASE + 0x0C)

// --- Registros AFIO ---
#define AFIO_EXTICR1 *(volatile uint32_t *)(AFIO_BASE + 0x08)

// --- Registros EXTI ---
#define EXTI_IMR    *(volatile uint32_t *)(EXTI_BASE + 0x00) 
#define EXTI_RTSR   *(volatile uint32_t *)(EXTI_BASE + 0x08) 
#define EXTI_PR     *(volatile uint32_t *)(EXTI_BASE + 0x14) 

// --- Registros NVIC ---
#define NVIC_ISER0  *(volatile uint32_t *)(NVIC_BASE + 0x000) 
#define NVIC_IPR1   *(volatile uint32_t *)(NVIC_BASE + 0x304) // Prioridades IRQ 4 a 7

// --- Registros SysTick ---
#define SysTick_CTRL *(volatile uint32_t *)(SysTick_BASE + 0x00)
#define SysTick_LOAD *(volatile uint32_t *)(SysTick_BASE + 0x04)
#define SysTick_VAL  *(volatile uint32_t *)(SysTick_BASE + 0x08)

// =====================================================================
// FUNCIONES AUXILIARES
// =====================================================================
void delay_dummy(volatile uint32_t limite) {
    for (volatile uint32_t i = 0; i < limite; i++);
}

// =====================================================================
// RUTINAS DE SERVICIO DE INTERRUPCIÓN (ISRs)
// =====================================================================

// --- SysTick: Maneja el LED PC13 en segundo plano ---
volatile uint32_t tick_led = 0;
void SysTick_Handler(void)
{
    tick_led++;
    if (tick_led >= 500) // Cambia cada 500ms
    {
        GPIOC_ODR ^= (1 << 13); // Invierte PC13
        tick_led = 0;
    }
}

// --- Botón 1 en PA0 (EXTI0) - PRIORIDAD BAJA ---
void EXTI0_IRQHandler(void)
{
    // Parpadeo del LED débil (PA2)
    for (int i = 0; i < 5; i++) { 
        GPIOA_ODR |= (1 << 2);     
        delay_dummy(400000);        
        GPIOA_ODR &= ~(1 << 2);    
        delay_dummy(400000);        
    }
    // Limpiar bandera EXTI0
    EXTI_PR = (1 << 0);
}

// --- Botón 2 en PA1 (EXTI1) - PRIORIDAD ALTA ---
void EXTI1_IRQHandler(void)
{
    // Prender LED fuerte (PA3)
    GPIOA_ODR |= (1 << 3);
    
    // Retardo largo demostrativo
    delay_dummy(1500000); 
    
    // Apagar LED fuerte
    GPIOA_ODR &= ~(1 << 3);

    // Limpiar bandera EXTI1
    EXTI_PR = (1 << 1);
}

// =====================================================================
// MAIN
// =====================================================================
void main(void)
{
    // 1. Relojes: Puerto A, Puerto C y AFIO
    RCC_APB2ENR |= (1 << 4) | (1 << 2) | (1 << 0);

    // 2. SysTick a 1ms (Para el LED de la placa)
    SysTick_CTRL &= ~(1 << 2); // Reloj HCLK/8
    SysTick_LOAD = 999; 
    SysTick_VAL = 0; 
    SysTick_CTRL |= (1 << 1) | (1 << 0); // TICKINT y ENABLE

    // 3. Configurar Pines
    // PC13 como salida
    GPIOC_CRH &= 0xFF0FFFFF;
    GPIOC_CRH |= 0x00200000;

    // Puerto A:
    // PA0, PA1: Entradas con Pull-Up/Pull-Down ('8')
    // PA2 a PA7: Salidas push-pull a 50MHz ('3')
    GPIOA_CRL = 0x33333388; 
    
    // PA8 (El 7mo LED del punto 2) está en la parte alta (CRH)
    GPIOA_CRH &= 0xFFFFFFF0;
    GPIOA_CRH |= 0x00000003; 

    // Forzar resistencias Pull-Down internas para PA0 y PA1
    GPIOA_ODR &= ~((1 << 0) | (1 << 1));

    // 4. Configurar AFIO
    // Queremos que EXTI0 apunte a PA0 y EXTI1 a PA1. 
    // Ponemos en cero los primeros 8 bits del registro EXTICR1.
    AFIO_EXTICR1 &= ~(0x000000FF);

    // 5. Configurar EXTI (Activar líneas 0 y 1, flanco de subida)
    EXTI_IMR  |= (1 << 0) | (1 << 1);  
    EXTI_RTSR |= (1 << 0) | (1 << 1);  

    // 6. Configurar NVIC (Gestor de Prioridades a mano)
    // El registro IPR1 maneja las prioridades de los IRQ 4 al 7. Cada uno usa 8 bits.
    
    // EXTI0 (IRQ 6): Ocupa los bits 23 al 16 de IPR1. Prioridad BAJA (0xF0)
    NVIC_IPR1 &= ~(0xFF << 16); // Limpiamos la zona
    NVIC_IPR1 |=  (0xF0 << 16); // Asignamos la prioridad

    // EXTI1 (IRQ 7): Ocupa los bits 31 al 24 de IPR1. Prioridad ALTA (0x00)
    NVIC_IPR1 &= ~(0xFF << 24); // Limpiamos la zona
    NVIC_IPR1 |=  (0x00 << 24); // Asignamos la prioridad (0x00 es la máxima)

    // Habilitar IRQ 6 y 7 en el ISER0 (que maneja del 0 al 31)
    NVIC_ISER0 |= (1 << 6) | (1 << 7);

    // 7. Bucle Infinito
    while (1)
    {
        // ¡El main queda vacío y eficiente! 
        // El SysTick titila el LED y los botones responden al instante.
    }
}

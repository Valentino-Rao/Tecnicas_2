#include <stdint.h>

// --- Direcciones Base ---
#define RCC_BASE    0x40021000
#define GPIOA_BASE  0x40010800
#define GPIOC_BASE  0x40011000
#define AFIO_BASE   0x40010000
#define EXTI_BASE   0x40010400
#define NVIC_BASE   0xE000E100

// --- Registros RCC ---
#define RCC_APB2ENR *(volatile uint32_t *)(RCC_BASE + 0x18)

// --- Registros GPIO ---
#define GPIOA_CRL   *(volatile uint32_t *)(GPIOA_BASE + 0x00)
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
#define NVIC_IPR1   *(volatile uint32_t *)(NVIC_BASE + 0x304) 
#define NVIC_IPR2   *(volatile uint32_t *)(NVIC_BASE + 0x308) 

// --- Función de retardo bloqueante ---
void delay_dummy(volatile uint32_t limite) {
    for (volatile uint32_t i = 0; i < limite; i++);
}

// =====================================================================
// RUTINAS DE SERVICIO DE INTERRUPCIÓN (ISRs)
// =====================================================================
// Botón 1 en PA1 (EXTI1) - PRIORIDAD BAJA
void EXTI1_IRQHandler(void)
{
    // 1. Prender LED en PA0
    GPIOA_ODR |= (1 << 0);
    
    // 2. Retardo MUY largo (simula una tarea pesada de 3 segundos)
    delay_dummy(3000000); 
    
    // 3. Apagar LED en PA0
    GPIOA_ODR &= ~(1 << 0);

    // 4. Limpiar bandera AL FINAL (esto ignora todos los rebotes del botón)
    EXTI_PR = (1 << 1);
}

// Botón 2 en PA2 (EXTI2) - PRIORIDAD ALTA
void EXTI2_IRQHandler(void)
{
    // 1. Prender LED en PA4
    GPIOA_ODR |= (1 << 4);
    
    // 2. Retardo corto
    delay_dummy(500000); 
    
    // 3. Apagar LED en PA4
    GPIOA_ODR &= ~(1 << 4);

    // 4. Limpiar bandera AL FINAL
    EXTI_PR = (1 << 2);
}



// =====================================================================
// MAIN
// =====================================================================
void main(void)
{
    // 1. Relojes: Habilitamos puerto C (LED placa), puerto A (Botones/Leds externos) y AFIO (Gestor EXTI)
    RCC_APB2ENR |= (1 << 4) | (1 << 2) | (1 << 0);

    // 2. Configurar PC13 como salida (LED Integrado de la placa)
    GPIOC_CRH &= 0xFF0FFFFF;
    GPIOC_CRH |= 0x00200000;

    // 3. Configurar pines de GPIOA
    // PA4 (Salida) | PA2 (Entrada) | PA1 (Entrada) | PA0 (Salida)
    GPIOA_CRL = 0x44434883;

    // Forzar resistencias Pull-Down internas para PA1 y PA2
    GPIOA_ODR &= ~((1 << 1) | (1 << 2));

    // 4. Configurar AFIO (Conectar PA1 a EXTI1 y PA2 a EXTI2)
    AFIO_EXTICR1 &= ~(0x0FF0);

    // 5. Configurar EXTI (Activar interrupciones y disparar por flanco de subida)
    EXTI_IMR  |= (1 << 1) | (1 << 2);  
    EXTI_RTSR |= (1 << 1) | (1 << 2);  

    // 6. Configurar NVIC (Gestor de Prioridades)
    
    // IRQ 7 pertenece a EXTI1 (Botón 1). Le damos Prioridad BAJA (0xF0)
    NVIC_IPR1 |= (0xF0 << 24);

    // IRQ 8 pertenece a EXTI2 (Botón 2). Le damos Prioridad ALTA (0x00)
    NVIC_IPR2 &= ~(0x000000FF); 

    // Habilitar IRQ 7 y 8 en el procesador
    NVIC_ISER0 |= (1 << 7) | (1 << 8);

    // 7. Bucle Infinito (Main Thread)
    while (1)
    {
        // El LED integrado (PC13) parpadea sin frenarse, demostrando que el código no se bloquea
        GPIOC_ODR ^= (1 << 13); 
        delay_dummy(1500000);
    }
}

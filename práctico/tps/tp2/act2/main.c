#include <stdint.h>

// --- Direcciones Base ---
#define RCC_BASE      0x40021000
#define GPIOA_BASE    0x40010800
#define GPIOB_BASE    0x40010C00 // Agregado para PB10 y PB11
#define GPIOC_BASE    0x40011000
#define AFIO_BASE     0x40010000
#define EXTI_BASE     0x40010400
#define NVIC_BASE     0xE000E100
#define SysTick_BASE  0xE000E010
#define ADC1_BASE     0x40012400 // Agregado para el Conversor ADC

// --- Registros RCC ---
#define RCC_APB2ENR *(volatile uint32_t *)(RCC_BASE + 0x18)

// --- Registros GPIO ---
#define GPIOA_CRL   *(volatile uint32_t *)(GPIOA_BASE + 0x00)
#define GPIOA_CRH   *(volatile uint32_t *)(GPIOA_BASE + 0x04)
#define GPIOA_ODR   *(volatile uint32_t *)(GPIOA_BASE + 0x0C)

#define GPIOB_CRH   *(volatile uint32_t *)(GPIOB_BASE + 0x04)
#define GPIOB_ODR   *(volatile uint32_t *)(GPIOB_BASE + 0x0C)

#define GPIOC_CRH   *(volatile uint32_t *)(GPIOC_BASE + 0x04)
#define GPIOC_ODR   *(volatile uint32_t *)(GPIOC_BASE + 0x0C)

// --- Registros AFIO, EXTI y NVIC ---
#define AFIO_EXTICR1 *(volatile uint32_t *)(AFIO_BASE + 0x08)
#define EXTI_IMR    *(volatile uint32_t *)(EXTI_BASE + 0x00) 
#define EXTI_RTSR   *(volatile uint32_t *)(EXTI_BASE + 0x08) 
#define EXTI_PR     *(volatile uint32_t *)(EXTI_BASE + 0x14) 
#define NVIC_ISER0  *(volatile uint32_t *)(NVIC_BASE + 0x000) 
#define NVIC_IPR1   *(volatile uint32_t *)(NVIC_BASE + 0x304) 

// --- Registros SysTick ---
#define SysTick_CTRL *(volatile uint32_t *)(SysTick_BASE + 0x00)
#define SysTick_LOAD *(volatile uint32_t *)(SysTick_BASE + 0x04)
#define SysTick_VAL  *(volatile uint32_t *)(SysTick_BASE + 0x08)

// --- Registros ADC1 ---
#define ADC_SR      *(volatile uint32_t *)(ADC1_BASE + 0x00) // Status (Para leer EOC)
#define ADC_CR2     *(volatile uint32_t *)(ADC1_BASE + 0x08) // Control 2 (Encendido y Triggers)
#define ADC_SMPR1   *(volatile uint32_t *)(ADC1_BASE + 0x0C) // Tiempo de muestreo (Canales 10 a 17)
#define ADC_SMPR2   *(volatile uint32_t *)(ADC1_BASE + 0x10) // Tiempo de muestreo (Canales 0 a 9)
#define ADC_SQR3    *(volatile uint32_t *)(ADC1_BASE + 0x34) // Secuencia regular
#define ADC_DR      *(volatile uint32_t *)(ADC1_BASE + 0x4C) // Data Register

// =====================================================================
// VARIABLES GLOBALES Y FUNCIONES AUXILIARES
// =====================================================================
volatile uint8_t modo_adc = 0; // 0: Sensor Interno | 1: Potenciómetro Externo

void delay_dummy(volatile uint32_t limite) {
    for (volatile uint32_t i = 0; i < limite; i++);
}

// =====================================================================
// RUTINAS DE SERVICIO DE INTERRUPCIÓN (ISRs)
// =====================================================================

// SysTick: Parpadeo asíncrono del TP1
volatile uint32_t tick_led = 0;
void SysTick_Handler(void)
{
    tick_led++;
    if (tick_led >= 500) {
        GPIOC_ODR ^= (1 << 13);
        tick_led = 0;
    }
}

// Botón 1 en PA0 (EXTI0) - PRIORIDAD BAJA
void EXTI0_IRQHandler(void)
{
    // Cambiamos el modo de lectura del ADC
    modo_adc = !modo_adc; 

    // Mantenemos la demostración de prioridad (Parpadeo en PA2)
    for (int i = 0; i < 5; i++) { 
        GPIOA_ODR |= (1 << 2);     
        delay_dummy(400000);        
        GPIOA_ODR &= ~(1 << 2);    
        delay_dummy(400000);        
    }
    EXTI_PR = (1 << 0);
}

// Botón 2 en PA1 (EXTI1) - PRIORIDAD ALTA
void EXTI1_IRQHandler(void)
{
    GPIOA_ODR |= (1 << 3);
    delay_dummy(1500000); 
    GPIOA_ODR &= ~(1 << 3);
    EXTI_PR = (1 << 1);
}

// =====================================================================
// MAIN
// =====================================================================
void main(void)
{
    // 1. Relojes: ADC1(bit 9), IOPC(bit 4), IOPB(bit 3), IOPA(bit 2) y AFIO(bit 0)
    RCC_APB2ENR |= (1 << 9) | (1 << 4) | (1 << 3) | (1 << 2) | (1 << 0);

    // 2. SysTick a 1ms
    SysTick_CTRL &= ~(1 << 2); 
    SysTick_LOAD = 999; 
    SysTick_VAL = 0; 
    SysTick_CTRL |= (1 << 1) | (1 << 0); 

    // 3. Configurar Pines
    GPIOC_CRH &= 0xFF0FFFFF;
    GPIOC_CRH |= 0x00200000;

    // Puerto A Inferior: 
    // PA7, PA6, PA5 (LEDs ADC) -> Salidas (3)
    // PA4 (Potenciómetro) -> Entrada Analógica (0)
    // PA3, PA2 (LEDs Botón) -> Salidas (3)
    // PA1, PA0 (Botones) -> Entradas PUPD (8)
    GPIOA_CRL = 0x33303388; 
    
    // Puerto B: PB10, PB11 (LEDs ADC 4 y 5) -> Salidas (3)
    GPIOB_CRH &= 0xFFFF00FF;
    GPIOB_CRH |= 0x00003300; 

    // Pull-Down en botones
    GPIOA_ODR &= ~((1 << 0) | (1 << 1));

    // 4. Configurar Interrupciones y Prioridades
    AFIO_EXTICR1 &= ~(0x000000FF);
    EXTI_IMR  |= (1 << 0) | (1 << 1);  
    EXTI_RTSR |= (1 << 0) | (1 << 1);  
    NVIC_IPR1 &= ~(0xFF << 16); 
    NVIC_IPR1 |=  (0xF0 << 16); 
    NVIC_IPR1 &= ~(0xFF << 24); 
    NVIC_IPR1 |=  (0x00 << 24); 
    NVIC_ISER0 |= (1 << 6) | (1 << 7);

    // 5. Configurar ADC1
    ADC_CR2 |= (1 << 0);    // ADON: Encender el ADC
    ADC_CR2 |= (1 << 23);   // TSVREFE: Despertar el sensor de Temperatura Interno
    
    // Configurar tiempo de muestreo (El sensor de temp requiere un tiempo de muestreo largo)
    ADC_SMPR1 |= (0x7 << 18); // SMP16 = 111 (239.5 ciclos para temperatura)
    ADC_SMPR2 |= (0x7 << 12); // SMP4 = 111 (239.5 ciclos para el potenciómetro en PA4)
    
    // Configurar el Trigger por Software (SWSTART)
    ADC_CR2 |= (0x7 << 17); // EXTSEL = 111
    ADC_CR2 |= (1 << 20);   // EXTTRIG = 1 (Necesario en la BluePill para arrancar por soft)

    // 6. Bucle Principal (Según Diagrama de Flujo)
    while (1)
    {
        // A. Seleccionar el canal según la interrupción
        if (modo_adc == 0) {
            ADC_SQR3 = 16; // Canal 16: Sensor de Temperatura Interno
        } else {
            ADC_SQR3 = 4;  // Canal 4: Potenciómetro en PA4
        }

        // B. Iniciar conversión (Setear bit 22 SWSTART)
        ADC_CR2 |= (1 << 22);

        // C. Esperar a que termine (Polling del flag EOC - bit 1)
        while (!(ADC_SR & (1 << 1)));

        // D. Leer el dato digital (0 a 4095)
        uint16_t adc_val = ADC_DR & 0xFFFF;

        // E. Apagar los 5 LEDs antes de actualizar
        GPIOA_ODR &= ~((1 << 5) | (1 << 6) | (1 << 7));
        GPIOB_ODR &= ~((1 << 10) | (1 << 11));

        // F. Encender LEDs tipo "Barra" según el valor del ADC
        // El máximo es 4095. Dividimos en 5 tramos.
        if(adc_val > 682)  GPIOA_ODR |= (1 << 5);  // LED 1
        if(adc_val > 1365) GPIOA_ODR |= (1 << 6);  // LED 2
        if(adc_val > 2048) GPIOA_ODR |= (1 << 7);  // LED 3
        if(adc_val > 2730) GPIOB_ODR |= (1 << 10); // LED 4
        if(adc_val > 3412) GPIOB_ODR |= (1 << 11); // LED 5
        
        // Retardo para no colapsar la actualización visual
        delay_dummy(200000);
    }
}

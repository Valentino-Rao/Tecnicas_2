#include "stm32f1xx.h"

// --- Variables Globales ---
volatile uint8_t modo_adc = 0; 
volatile uint32_t tick_led = 0;

void delay_dummy(volatile uint32_t limite) {
    for (volatile uint32_t i = 0; i < limite; i++);
}

// =====================================================================
// RUTINAS DE SERVICIO DE INTERRUPCIÓN (ISRs)
// (Los nombres de estas funciones ya están definidos en el startup de ST)
// =====================================================================

// Parpadeo asíncrono del LED integrado (PC13) via SysTick
void SysTick_Handler(void) {
    tick_led++;
    if (tick_led >= 500) {
        GPIOC->ODR ^= (1 << 13);
        tick_led = 0;
    }
}

// Botón Débil en PA0 (EXTI0) -> Prioridad BAJA
void EXTI0_IRQHandler(void) {
    modo_adc = !modo_adc; // Alterna la fuente del ADC

    for (int i = 0; i < 5; i++) { 
        GPIOA->ODR |= (1 << 2);     
        delay_dummy(400000);        
        GPIOA->ODR &= ~(1 << 2);    
        delay_dummy(400000);        
    }
    EXTI->PR = EXTI_PR_PR0; // CMSIS: Limpiamos la bandera
}

// Botón Fuerte en PA1 (EXTI1) -> Prioridad ALTA
void EXTI1_IRQHandler(void) {
    GPIOA->ODR |= (1 << 3);
    delay_dummy(1500000); 
    GPIOA->ODR &= ~(1 << 3);
    
    EXTI->PR = EXTI_PR_PR1; // CMSIS: Limpiamos la bandera
}

// =====================================================================
// MAIN PROGRAM
// =====================================================================
int main(void) {
    // 1. Clocks: Habilitar ADC1, GPIOC, GPIOB, GPIOA y AFIO usando las macros de CMSIS
    RCC->APB2ENR |= RCC_APB2ENR_ADC1EN | RCC_APB2ENR_IOPCEN | 
                    RCC_APB2ENR_IOPBEN | RCC_APB2ENR_IOPAEN | 
                    RCC_APB2ENR_AFIOEN;

    // 2. Inicializar SysTick a 1ms (Manual para no usar SystemCoreClock)
    SysTick->CTRL &= ~SysTick_CTRL_CLKSOURCE_Msk; 
    SysTick->LOAD = 999; 
    SysTick->VAL = 0; 
    SysTick->CTRL |= SysTick_CTRL_TICKINT_Msk | SysTick_CTRL_ENABLE_Msk; 

    // 3. Configurar Pines
    GPIOC->CRH &= ~GPIO_CRH_CNF13_Msk;
    GPIOC->CRH |= GPIO_CRH_MODE13_1; // Salida 2MHz

    // PA7, PA6, PA5 (Salidas), PA4 (Analógico), PA3, PA2 (Salidas), PA1, PA0 (Entradas PUPD)
    GPIOA->CRL = 0x33303388; 
    
    // PB10 y PB11 (Salidas)
    GPIOB->CRH &= 0xFFFF00FF;
    GPIOB->CRH |= 0x00003300; 

    // Pull-down interno para PA0 y PA1
    GPIOA->ODR &= ~((1 << 0) | (1 << 1));

    // 4. Configurar AFIO e interrupciones externas
    AFIO->EXTICR[0] &= ~(AFIO_EXTICR1_EXTI0_Msk | AFIO_EXTICR1_EXTI1_Msk);
    EXTI->IMR  |= EXTI_IMR_MR0 | EXTI_IMR_MR1;  
    EXTI->RTSR |= EXTI_RTSR_TR0 | EXTI_RTSR_TR1;  

    // 5. Configurar Prioridades NVIC usando funciones estándar de CMSIS
    NVIC_SetPriority(EXTI0_IRQn, 15); // Prioridad Baja (Número alto)
    NVIC_SetPriority(EXTI1_IRQn, 0);  // Prioridad Alta (0 es máxima)
    NVIC_EnableIRQ(EXTI0_IRQn);
    NVIC_EnableIRQ(EXTI1_IRQn);

    // 6. Configurar e iniciar ADC1
    ADC1->CR2 |= ADC_CR2_ADON;    // Enciende el módulo
    ADC1->CR2 |= ADC_CR2_TSVREFE; // Despierta el termómetro interno
    
    ADC1->SMPR1 |= (0x7 << ADC_SMPR1_SMP16_Pos); // Muestreo largo para Temp
    ADC1->SMPR2 |= (0x7 << ADC_SMPR2_SMP4_Pos);  // Muestreo largo para Pote
    
    ADC1->CR2 |= (0x7 << ADC_CR2_EXTSEL_Pos); // Disparo por SWSTART
    ADC1->CR2 |= ADC_CR2_EXTTRIG;

    while (1) {
        // A. Selección de canal
        if (modo_adc == 0) {
            ADC1->SQR3 = 16; 
        } else {
            ADC1->SQR3 = 4;  
        }

        // B. Lanzar conversión
        ADC1->CR2 |= ADC_CR2_SWSTART;

        // C. Esperar EOC (End of Conversion)
        while (!(ADC1->SR & ADC_SR_EOC));

        // D. Guardar valor
        uint16_t adc_val = ADC1->DR & 0xFFFF;

        // E. Limpiar barra de LEDs (Lógica Negativa: '1' es Apagado)
        GPIOA->ODR |= (1 << 5) | (1 << 6) | (1 << 7);
        GPIOB->ODR |= (1 << 10) | (1 << 11);

        // F. Actualizar barra (Lógica Negativa: '0' es Encendido)
        if (adc_val > 682)  GPIOA->ODR &= ~(1 << 5);  
        if (adc_val > 1365) GPIOA->ODR &= ~(1 << 6);  
        if (adc_val > 2048) GPIOA->ODR &= ~(1 << 7);  
        if (adc_val > 2730) GPIOB->ODR &= ~(1 << 10); 
        if (adc_val > 3412) GPIOB->ODR &= ~(1 << 11); 
        
        delay_dummy(100000); 
    }
}

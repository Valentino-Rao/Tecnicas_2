#include "stm32f1xx.h"
#include <stdint.h>

/* ==========================================================================
 * PRÁCTICA GUIADA PARA EL PARCIAL PRÁCTICO - TÉCNICAS DIGITALES 2
 * ==========================================================================
 * Instrucciones:
 * - Completá únicamente los bloques que están entre los comentarios:
 *   /* ===== TU CODIGO AQUI ===== */
/* - Podés usar tu cheatsheet impresa para guiarte.
 * - Los ejercicios van de menor a mayor dificultad.
 * ========================================================================== */

/* --------------------------------------------------------------------------
 * EJERCICIO 1: Lo más básico (Bare Metal)
 * Objetivo: Configurar el pin PA4 como entrada analógica.
 * Solo tenés que prender el clock del puerto y configurar el modo del pin.
 * -------------------------------------------------------------------------- */
#define RCC_APB2ENR (*(volatile uint32_t *)(0x40021000 + 0x18))
#define GPIOA_CRL   (*(volatile uint32_t *)(0x40010800 + 0x00))

void ej1_configurar_pa4_analogico(void) {
    /* ===== TU CODIGO AQUI ===== */
    // 1. Prender el reloj del puerto A (Bit 2 del APB2ENR)
    //
    RCC_APB2ENR |= (0x1<<2);
    
    // 2. Limpiar la configuración actual del pin PA4 (bits 16 a 19 del CRL)
    GPIOA_CRL &= ~(0xF<<16);
    // 3. Configurar PA4 como Entrada Analógica (Modo = 0x0)
    GPIOA_CRL |= (0x0<<16);

    /* ========================== */
}


/* --------------------------------------------------------------------------
 * EJERCICIO 2: Salida y Bucle (CMSIS)
 * Objetivo: Configurar el pin PC13 (LED de la placa) como salida push-pull 
 * a 2MHz y hacerlo parpadear en un bucle infinito.
 * -------------------------------------------------------------------------- */
void ej2_parpadeo_pc13_cmsis(void) {
    /* ===== TU CODIGO AQUI ===== */
    // 1. Prender el reloj del puerto C usando estructuras CMSIS
    
    RCC->APB2ENR |= (1<<4);
    
    // 2. Limpiar configuración del pin PC13 en el registro CRH

    GPIOC->CRH &= ~(0xF<<20);
    
    // 3. Configurar PC13 como Salida Push-Pull 2MHz (Modo = 0x2)

    GPIO->CRH &= (0x2<<20);
    
    /* ========================== */

    while (1) {
        /* ===== TU CODIGO AQUI ===== */
        // 4. Invertir (toggle) el estado del pin PC13 usando ODR
        
        GPIO->ODR ^= (0x1<<13);
        
        // 5. Armar un retardo bloqueante muy simple (ej: un for de 1000000 vueltas)
        for(int i=0;i<100000;i++);


/* --------------------------------------------------------------------------
 * EJERCICIO 3: Base de tiempos con SysTick (CMSIS)
 * Objetivo: Configurar el SysTick para generar una interrupción cada 1 ms.
 * Asumir que la frecuencia del procesador es 72 MHz (HCLK).
 * -------------------------------------------------------------------------- */
volatile uint32_t milisegundos = 0;

void ej3_systick_init_1ms(void) {
    /* ===== TU CODIGO AQUI ===== */
    // 1. Seleccionar la fuente de reloj del SysTick (Core clock / AHB)
    
    SysTick->CTRL |= (1<<2) ;
    
    // 2. Cargar el valor necesario para 1 ms en el registro LOAD
       
    SysTick->LOAD ^= (71999<<23);
    
    // 3. Resetear el valor actual del contador (registro VAL)
    
    SysTick->VAL &= 0;
    
    // 4. Habilitar la interrupción (TICKINT) y arrancar el timer (ENABLE)
    SysTick->CTRL |=(1<<0);
    SysTick->CTRL |=(1<<1);
    /* ========================== */
}

void SysTick_Handler(void) {
    /* ===== TU CODIGO AQUI ===== */
    // 5. Incrementar la variable global 'milisegundos'
    milisegundos++;
    /* ========================== */
}


/* --------------------------------------------------------------------------
 * EJERCICIO 4: Interrupción Externa Básica (CMSIS)
 * Objetivo: Configurar un pulsador en PB0 (flanco descendente) con pull-up.
 * Que la pulsación dispare la interrupción EXTI0.
 * -------------------------------------------------------------------------- */
void ej4_exti0_pb0_init(void) {
    /* ===== TU CODIGO AQUI ===== */
    // 1. Prender relojes: GPIOB y AFIO
    //
    RCC->APB2ENR |=(1<<0);
    RCC->APB2ENR |=(1<<3);
    // 2. Configurar PB0 como Entrada con Pull-Up/Pull-Down (Modo = 0x8)
    GPIOB->CRL &= ~(0xF<<0);
    GPIOB->CRL |=(0x8<<0);

    // 3. Activar la resistencia de Pull-Up escribiendo un 1 en el ODR del pin 0
    GPIOB->ODR |=(GPIO_ODR_ODRB);
    
    // 4. Enrutar el pin PB0 hacia la línea EXTI0 en el registro AFIO->EXTICR[0]
    AFIO->EXTICR[0] &= ~(0xF<<0);
    AFIO->EXTICR[0] |= (0x1<<0);
    
    // 5. Desenmascarar la línea EXTI0 en el registro IMR
    EXTI->IMR |=(EXTI_IMR_MR0);
    
    // 6. Configurar el disparo por flanco DESCENDENTE en el registro FTSR
    EXTI->FTSR |=(EXTI_FTSR_TR0);
    // 7. Habilitar la interrupción EXTI0_IRQn en el NVIC
    
    NVIC_EnableIRQ(EXTI0_IRQn);

    /* ========================== */
}

void EXTI0_IRQHandler(void) {
    /* ===== TU CODIGO AQUI ===== */
    // 8. ¡MUY IMPORTANTE! Limpiar la bandera de interrupción pendiente en PR

    EXIT->PR &=EXTI_PR_PR0;
    
    // 9. (Simular que acá prendemos un LED, no hace falta código)
    /* ========================== */
}


/* --------------------------------------------------------------------------
 * EJERCICIO 5: Conversor Analógico Digital (ADC1)
 * Objetivo: Leer un potenciómetro en el canal 1 (PA1) mediante Polling.
 * -------------------------------------------------------------------------- */
void ej5_adc_init_y_leer(void) {
    /* ===== TU CODIGO AQUI ===== */
    // --- INIT ---
    // 1. Prender relojes de GPIOA y ADC1
    RCC->APB2ENR |=(RCC_APB2ENR_IOAEN);
    RCC->APB2ENR |=(RCC_APB2ENR_ADC1EN);
    
    // 2. Configurar PA1 como Entrada Analógica (Modo = 0x0)

    GPIOA->CRL &= ~(0xF<<4);
    GPIOA->CRL |= (0x0<<4);
    
    // 3. Encender el módulo ADC1 (bit ADON en CR2)
    ADC1->CR2 |=ADC_CR2_ADON;
    
    // 4. Configurar el disparo por software (EXTSEL = 111 y EXTTRIG = 1 en CR2)
    ADC1->CR2 |=ADC_CR2_EXTSEL;
    ADC1->CR2 |=ADC_CR2_EXTTRIG;
    
    /* ========================== */
    
    int16_t lectura;
    while(1) {
        /* ===== TU CODIGO AQUI ===== */
        // --- LOOP DE LECTURA ---
        // 5. Seleccionar el Canal 1 como el primero en la secuencia (SQR3)
        ADC1->SQR3 |=(1);
        
        // 6. Iniciar la conversión por software (SWSTART en CR2)
        ADC1->CR2 |=(ADC_CR2_SWTART);
        // 7. Esperar (bucle while) hasta que la bandera EOC (End Of Conversion) esté en 1
    while(!(ADC1->SR & ADC_SR_EOC));
        // 8. Leer el resultado de la conversión del registro DR y guardarlo en 'lectura'
        lectura = ADC1->DR;
        /* ========================== */
    }
}


/* --------------------------------------------------------------------------
 * EJERCICIO 6: Comunicación Serie (USART1)
 * Objetivo: Configurar USART1 a 9600 baudios (asumir clock de 72MHz) 
 * y armar una función para transmitir un caracter.
 * -------------------------------------------------------------------------- */
void ej6_usart1_init(void) {
    /* ===== TU CODIGO AQUI ===== */
    // 1. Prender relojes de GPIOA, USART1 y AFIO

    RCC->APB2ENR |=(RCC_APB2ENR_IOPA);
    RCC->APB2ENR |=(RCC_APB2ENR_USART1EN);
    RCC->APB2ENR |=(RCC_APB2ENR_AFIOEN);

    // 2. Configurar PA9 (TX) como Función Alternativa Push-Pull (Modo = 0xB, la hoja de franco dice 10>00)
    GPIOA->CRL &=~(0xF<<4);
    GPIOA->CRL |=(0xB<<4);
    
    // 3. Configurar PA10 (RX) como Entrada Flotante (Modo = 0x4)
    
    GPIOA->CRL &=~(0xF<<8);
    GPIOA->CRL |=(0x4<<8);

    // 4. Configurar el Baud Rate a 9600 en el registro BRR (Usa tu cheatsheet para el valor Hex)
    
    USART1->BRR |= 

    
    // 5. Habilitar USART (UE), Transmisor (TE) y Receptor (RE) en CR1
    USART1->CR1 |=(USART_CR1_UE);
    USART1->CR1 |=(USART_CR1_TE);
    USART1->CR1 |=(USART_CR1_RE);
    /* ========================== */
}

void enviar_caracter(char c) {
    /* ===== TU CODIGO AQUI ===== */
    // 6. Esperar a que el buffer de transmisión esté vacío (flag TXE en SR)
    while(!(USART1->SR & USART_SR_TXE));
    
    // 7. Escribir el caracter 'c' en el registro de datos (DR)
    USART1->DR = c;
    
    /* ========================== */
}


/* --------------------------------------------------------------------------
 * EJERCICIO 7: Temporizador y PWM por Hardware (TIM2 Canal 3 en PA2)
 * Objetivo: Configurar TIM2 para generar una señal PWM de 1 kHz con un 
 * ciclo de trabajo (duty cycle) del 50% en el pin PA2 (TIM2_CH3).
 * Frecuencia del Timer: 72 MHz.
 * -------------------------------------------------------------------------- */
void ej7_pwm_tim2_init(void) {
    /* ===== TU CODIGO AQUI ===== */
    // 1. Prender relojes: GPIOA (APB2) y TIM2 (APB1)
    RCC->APB2ENR |=(RCC_APB2ENR_IOPAEN);
    RCC->APB1ENR |=(RCC_APB1ENR_TIM2EN);
    // 2. Configurar PA2 como Función Alternativa Push-Pull 50MHz (Modo = 0xB) en CRL
    GPIOA->CRL &= ~(0xF<<8);
    GPIOA->CRL |=(0xB<<8);
    // 3. Configurar Prescaler (PSC) y Auto-Reload (ARR) para 1 kHz


    //    PSC = 71  (72MHz / 72 = 1MHz)
    //    ARR = 999 (1MHz / 1000 = 1kHz)
    
    TIM2->PSC = 71;
    TIM2->ARR = 999;
    // 4. Configurar el Duty Cycle inicial al 50% en CCR3 (50% de 1000 = 500)
    
    TIM2->CCR3 = 500;

    // 5. Configurar PWM Modo 1 en Canal 3 (OC3M = 110 en CCMR2) y activar Preload (OC3PE)
    
    TIM2->CCMR2 &= ~(0x7<<4);
    TIM2->CCMR2 |=(0x6<<4);
    TIM2->CCMR2 |=(1<<3);

    // 6. Habilitar la salida del Canal 3 en el registro CCER (bit CC3E)

    TIM2->CCER |=(1<<8);

    
    // 7. Generar evento de actualización (UG en EGR) y arrancar el timer (CEN en CR1)
    TIM2->EGR |=(1<<0);
    TIM2->CR1 |=(1<<0);
    /* ========================== */
}


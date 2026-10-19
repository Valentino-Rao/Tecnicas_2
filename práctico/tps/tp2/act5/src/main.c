#include "stm32f1xx.h"
#include <stdint.h>

volatile uint32_t pwm_counter = 0;
volatile int16_t pwm_duty = 0;
volatile int8_t pwm_step = 1;

volatile uint32_t tick_fade = 0;
volatile uint32_t tick_green = 0;

void SysTick_Handler(void) {
    // SysTick corre cada 100 microsegundos (10 kHz)
    pwm_counter++;
    if (pwm_counter >= 100) {
        pwm_counter = 0; // Periodo PWM de 10 ms (100 Hz)
    }

    // --- 1. Generación del PWM por Software en PA2 ---
    if (pwm_counter < pwm_duty) {
        GPIOA->ODR |= (1 << 2);  // Encender LED Rojo 1
    } else {
        GPIOA->ODR &= ~(1 << 2); // Apagar LED Rojo 1
    }

    // --- 2. Actualizar Fading cada 20 ms ---
    if (pwm_counter == 0) {
        tick_fade++;
        if (tick_fade >= 2) { 
            tick_fade = 0;
            pwm_duty += pwm_step;
            // Limites del fading (0% a 100%)
            if (pwm_duty <= 0 || pwm_duty >= 100) {
                pwm_step = -pwm_step;
            }
        }
    }

    // --- 3. Parpadeo del LED Verde cada 500 ms ---
    tick_green++;
    if (tick_green >= 5000) { 
        tick_green = 0;
        GPIOC->ODR ^= (1 << 13);
    }
}

int main(void) {
    // 1. Habilitar Clocks de Puertos A y C
    RCC->APB2ENR |= RCC_APB2ENR_IOPCEN | RCC_APB2ENR_IOPAEN;

    // 2. SysTick a 100 us (Clock de 72 MHz)
    SysTick->CTRL |= SysTick_CTRL_CLKSOURCE_Msk; // Core clock (72 MHz)
    SysTick->LOAD = 7199; // (72MHz / 10kHz) - 1
    SysTick->VAL = 0;
    SysTick->CTRL |= SysTick_CTRL_TICKINT_Msk | SysTick_CTRL_ENABLE_Msk; 

    // 3. PC13 (LED Verde) como Salida Push-Pull
    GPIOC->CRH &= ~GPIO_CRH_CNF13_Msk;
    GPIOC->CRH |= GPIO_CRH_MODE13_1;

    // 4. PA2 (LED Rojo 1) como SALIDA NORMAL (Push-Pull)
    // Aca NO usamos modo alternativo (Hardware PWM), usamos GPIO normal
    GPIOA->CRL &= ~(0xF << 8); 
    GPIOA->CRL |= (0x3 << 8);  // Output push-pull 50MHz (Modo 3, CNF 0)

    // Bucle infinito, todo el trabajo lo hace SysTick
    while (1) {
    }
}

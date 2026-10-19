#include <stdint.h>

#define RCC_BASE      0x40021000
#define GPIOA_BASE    0x40010800
#define GPIOB_BASE    0x40010C00
#define GPIOC_BASE    0x40011000

#define RCC_APB2ENR *(volatile uint32_t *)(RCC_BASE + 0x18)

#define GPIOA_CRL   *(volatile uint32_t *)(GPIOA_BASE + 0x00)
#define GPIOA_CRH   *(volatile uint32_t *)(GPIOA_BASE + 0x04)
#define GPIOA_ODR   *(volatile uint32_t *)(GPIOA_BASE + 0x0C)

#define GPIOB_CRH   *(volatile uint32_t *)(GPIOB_BASE + 0x04)
#define GPIOB_ODR   *(volatile uint32_t *)(GPIOB_BASE + 0x0C)

#define GPIOC_CRH   *(volatile uint32_t *)(GPIOC_BASE + 0x04)
#define GPIOC_ODR   *(volatile uint32_t *)(GPIOC_BASE + 0x0C)

void main(void) {
    // 1. Habilitar reloj para IOPC (bit 4), IOPB (bit 3) e IOPA (bit 2)
    RCC_APB2ENR |= (1 << 4) | (1 << 3) | (1 << 2);

    // 2. Configurar Pines como Salidas (Modo Push-Pull, 50MHz -> 0x3)
    
    // PA2, PA3, PA5, PA6, PA7
    // Limpiamos los bloques correspondientes
    GPIOA_CRL &= ~(0xFFF0FF00); 
    // Ponemos '3' en cada bloque (Output)
    GPIOA_CRL |=  (0x33303300); 

    // PB10, PB11
    GPIOB_CRH &= ~(0x0000FF00);
    GPIOB_CRH |=  (0x00003300);

    // PC13 (LED integrado)
    GPIOC_CRH &= ~(0x00F00000);
    GPIOC_CRH |=  (0x00300000);

    // 3. PRENDER TODOS LOS LEDS EXTERNOS (Lógica Positiva: 1 = Prender)
    GPIOA_ODR |= (1 << 2) | (1 << 3) | (1 << 5) | (1 << 6) | (1 << 7);
    GPIOB_ODR |= (1 << 10) | (1 << 11);

    // 4. PRENDER LED INTERNO DE LA PLACA (Lógica Negativa: 0 = Prender)
    GPIOC_ODR &= ~(1 << 13);

    // Bucle infinito
    while(1) {
    }
}

#include <stdint.h>

// register address

#define RCC_BASE 0x40021000
#define GPIOC_BASE 0x40011000
#define GPIOA_BASE 0x40010800

#define RCC_APB2ENR *(volatile uint32_t *)(RCC_BASE + 0x18)
#define GPIOC_CRH *(volatile uint32_t *)(GPIOC_BASE + 0x04)
#define GPIOA_CRL *(volatile uint32_t *)(GPIOA_BASE + 0x00)
#define GPIOC_ODR *(volatile uint32_t *)(GPIOC_BASE + 0x0C)
#define GPIOA_ODR *(volatile uint32_t *)(GPIOA_BASE + 0x0C)
// bit fields

#define RCC_IOPCEN (1 << 4)
#define RCC_IOPAEN (1 << 2)

#define GPIOC13 (1UL << 13)
#define GPIOA0 (1UL << 0)

void main(void)
{

RCC_APB2ENR |= RCC_IOPCEN;
RCC_APB2ENR |= RCC_IOPAEN;

GPIOC_CRH &= 0xFF0FFFFF;
GPIOC_CRH |= 0x00200000;

GPIOA_CRL &= 0xFFFFFFF0;
GPIOA_CRL |= 0x00000002;

while (1)
    {

    GPIOC_ODR |= GPIOC13;
    for (int i = 0; i < 500000; i++); // arbitrary delay
    GPIOC_ODR &= ~GPIOC13;
    for (int i = 0; i < 50000; i++); // arbitrary delay
    
    GPIOA_ODR |= GPIOA0;
    for (int i = 0; i < 500000; i++); // arbitrary delay
    GPIOA_ODR &= ~GPIOA0;
    for (int i = 0; i < 50000; i++); // arbitrary delay
    }
}



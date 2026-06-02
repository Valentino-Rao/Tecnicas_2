.syntax unified
.cpu cortex-m3
.thumb
.extern _esstack

.section .text.manejadores

.thumb_func
.weak Default_Handler
Default_Handler:
    b .             /* Bucle infinito donde te estás quedando atrapado ahora */

.weak NMI_Handler
.thumb_set NMI_Handler, Default_Handler
.weak SysTick_Handler
.thumb_set SysTick_Handler, Default_Handler
.weak HardFault_Handler
.thumb_set HardFault_Handler, Default_Handler

// --- ESTOS SON LOS ALIAS QUE TE DEBEN ESTAR FALTANDO ---
.weak EXTI1_IRQHandler
.thumb_set EXTI1_IRQHandler, Default_Handler
.weak EXTI2_IRQHandler
.thumb_set EXTI2_IRQHandler, Default_Handler

.section .isr_vector,"a",%progbits
.word _esstack
.word _reset
.word NMI_Handler
.word HardFault_Handler
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word SysTick_Handler

// --- ESTA ES LA EXTENSIÓN DE LA TABLA QUE EL MICRO NECESITA LEER ---
.word 0                   /* 16: IRQ 0 - WWDG */
.word 0                   /* 17: IRQ 1 - PVD */
.word 0                   /* 18: IRQ 2 - TAMPER */
.word 0                   /* 19: IRQ 3 - RTC */
.word 0                   /* 20: IRQ 4 - FLASH */
.word 0                   /* 21: IRQ 5 - RCC */
.word 0                   /* 22: IRQ 6 - EXTI0 */
.word EXTI1_IRQHandler    /* 23: IRQ 7 - EXTI1 (Botón PA1) */
.word EXTI2_IRQHandler    /* 24: IRQ 8 - EXTI2 (Botón PA2) */

.section .text.reset
.thumb_func
.global _reset
_reset:
    bl main
    b .

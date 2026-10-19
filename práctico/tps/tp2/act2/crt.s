.syntax unified
.cpu cortex-m3
.thumb
.extern _esstack

.section .text.manejadores // definimos la seccion text.manejadores

// función básica para manejar los punteros
.thumb_func
.weak Default_Handler
Default_Handler:
    b .             /* Bucle infinito */

// definir los vectores internos
.weak NMI_Handler
.thumb_set NMI_Handler, Default_Handler
.weak SysTick_Handler
.thumb_set SysTick_Handler, Default_Handler
.weak HardFault_Handler
.thumb_set HardFault_Handler, Default_Handler

// Definir los vectores para los botones (Interrupciones Externas 0 y 1)
.weak EXTI0_IRQHandler
.thumb_set EXTI0_IRQHandler, Default_Handler
.weak EXTI1_IRQHandler
.thumb_set EXTI1_IRQHandler, Default_Handler

// vectores
.section .isr_vector,"a",%progbits
.word _esstack
.word _reset
.word NMI_Handler         /* 2:  NMI (Non-Maskable Interrupt) */
.word HardFault_Handler   /* 3:  HardFault (falla grave) */
.word 0                   /* 4:  MemManage (falla de memoria) */
.word 0                   /* 5:  BusFault (falla de bus) */
.word 0                   /* 6:  UsageFault (falla de uso) */
.word 0                   /* 7:  Reservado */
.word 0                   /* 8:  Reservado */
.word 0                   /* 9:  Reservado */
.word 0                   /* 10: Reservado */
.word 0                   /* 11: SVCall (Llamada al Supervisor) */
.word 0                   /* 12: Debug Monitor */
.word 0                   /* 13: Reservado */
.word 0                   /* 14: PendSV (Interrupción pendiente del sistema) */
.word SysTick_Handler     /* 15: El handler del SysTick */

// Interrupciones de Periféricos (IRQs)
.word 0                   /* 16: IRQ 0 - WWDG */
.word 0                   /* 17: IRQ 1 - PVD */
.word 0                   /* 18: IRQ 2 - TAMPER */
.word 0                   /* 19: IRQ 3 - RTC */
.word 0                   /* 20: IRQ 4 - FLASH */
.word 0                   /* 21: IRQ 5 - RCC */
.word EXTI0_IRQHandler    /* 22: IRQ 6 - EXTI0 (Botón PA0) */
.word EXTI1_IRQHandler    /* 23: IRQ 7 - EXTI1 (Botón PA1) */

// declaramos la función _reset dentro de la seccion text.reset
.section .text.reset
.thumb_func
.global _reset
_reset:
    bl main
    b .

/*
Here are some common GCC directives for ARM Cortex-M0 assembly:

.align: Specifies the byte alignment of the following instruction or data item.
.ascii: Specifies a string of characters to be included in the output file.
.asciz: Specifies a zero-terminated string of characters to be included in the output file.
.byte: Specifies one or more bytes of data to be included in the output file.
.data: Marks the start of a data section.
.global: Marks a symbol as visible outside of the current file.
.section: Specifies the section of memory where the following instructions or data items should be placed.
.space: Reserves a block of memory with a specified size.
.thumb: Instructs the assembler to generate Thumb code.
.thumb_func: Marks a function as using the Thumb instruction set.
.word: Specifies one or more words of data to be included in the output file.

Note that this is not an exhaustive list, and different versions of GCC may support additional or different directives.
*/
#include "timer_11xx_asm.h"
#include "iocon_11xx_asm.h"
#include "gpio_11xx_2_asm.h"

#define LED1_PORT LPC_GPIO_PORT0_BASE
#define LED1_BIT  7
#define LED2_PORT LPC_GPIO_PORT1_BASE
#define LED2_BIT  0
#define LED3_PORT LPC_GPIO_PORT1_BASE
#define LED3_BIT  4
#define LED4_PORT LPC_GPIO_PORT1_BASE
#define LED4_BIT  5

#define SW1_PORT	LPC_GPIO_PORT1_BASE
#define SW1_BIT 8
#define SW2_PORT	LPC_GPIO_PORT1_BASE
#define SW2_BIT 9
#define SW3_PORT LPC_GPIO_PORT0_BASE
#define SW3_BIT  1
#define SW4_PORT LPC_GPIO_PORT0_BASE
#define SW4_BIT  3

.extern SW_Status_Read_Request;
.extern LED_Set_Request;

    .syntax unified

.section .bss
    .align 2
    count:
    .space 2

     .text
    .global  TIMER16_0_IRQHandler
	.thumb_func
    .type	TIMER16_0_IRQHandler, %function
TIMER16_0_IRQHandler:
	push	{lr}
	ldr		r1, =LPC_TIMER16_0_BASE
	ldr		r2, =TIMER_OFFSET_IR
	ldr		r3, [r1, r2]
	ldr 	r4, =1 << 0
	ands	r3, r4
	beq	CHECK_MR1
	str		r4, [r1, r2]
	movs r0, #0
	bl SW_Status_Read_Request
	movs r3, #0
	cmp r0, r3
	bne true
	movs r1, #1
	bl false
true:
	movs r1, #0
false:
	movs r0, #0
	bl LED_Set_Request
CHECK_MR1:
	ldr		r1, =LPC_TIMER16_0_BASE
	ldr		r2, =TIMER_OFFSET_IR
	ldr		r3, [r1, r2]
	ldr 	r4, =1 << 1
	ands	r3, r4
	beq	CHECK_MR2
	str		r4, [r1, r2]
CHECK_MR2:
	ldr 	r4, =1 << 2
	ands	r3, r4
	beq	CHECK_MR3
	str		r4, [r1, r2]
CHECK_MR3:
	ldr 	r4, =1 << 3
	ands	r3, r4
	beq	CHECK_END
	str		r4, [r1, r2]
CHECK_END:
	nop
	pop	{pc}
	.size	TIMER16_0_IRQHandler, .-TIMER16_0_IRQHandler


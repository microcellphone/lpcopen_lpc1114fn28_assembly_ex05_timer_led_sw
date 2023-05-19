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
#include "sysctl_11xx_asm.h"

#define PCLK_CLOCK 48000000UL

    .syntax unified

    .text
	.thumb
	.thumb_func
    .type	NVIC_EnableIRQ, %function
NVIC_EnableIRQ:
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	movs	r2, r0
	adds	r3, r7, #7
	strb	r2, [r3]
	adds	r3, r7, #7
	ldrb	r3, [r3]
	movs	r2, r3
	movs	r3, #31
	ands	r3, r2
	movs	r2, #1
	lsls	r2, r2, r3
	ldr	r3, .L2
	str	r2, [r3]
	nop
	mov	sp, r7
	add	sp, sp, #8
	@ sp needed
	pop	{r7, pc}
.L3:
	.align	2
.L2:
	.word	-536813312
	.size	NVIC_EnableIRQ, .-NVIC_EnableIRQ

    .text
    .global  TIMER16B0_Config_Request
	.thumb
	.thumb_func
    .type	TIMER16B0_Config_Request, %function
TIMER16B0_Config_Request:
	push	{lr}
//    LPC_SYSCTL->SYSAHBCLKCTRL |= (1 << 7);   // enable timer16b0 clock
	ldr		r1, =LPC_SYSCTL_BASE
	ldr		r2, =SYSCTL_OFFSET_SYSAHBCLKCTRL
	ldr 	r3, [r1, r2]
	ldr		r4, =(1 << 7)
	orrs 	r3, r3, r4
	str		r3, [r1, r2]

//    LPC_TIMER16_0->PR  = 0;                  // Set prescaler to 0
	ldr		r1, =LPC_TIMER16_0_BASE
	ldr		r2, =TIMER_OFFSET_PR
	movs 	r3, #0
	str		r3, [r1, r2]

//    LPC_TIMER16_0->MR[MR0] = (PCLK_CLOCK * interval_ms / 1000);  // Set match register
	ldr		r2, =TIMER_OFFSET_MR0
	ldr		r3, =PCLK_CLOCK
	movs	r4, r0      // r4 = interval_ms
	ldr	r5, =1000
	movs	r6, #0
div:
	cmp r3, r5
	blt millisecond
	subs r3, r3, r5
	adds r6, r6, #1
	bl div
millisecond:
	muls r4, r4, r6
	str	 r4, [r1, r2]

//    LPC_TIMER16_0->MCR |= (1 << MR0) | (1 << 1); // interrupt and reset on match
	ldr		r2, =TIMER_OFFSET_MCR
	ldr 	r3, [r1, r2]
	ldr		r4, =(1 << 0)
	ldr		r5, =(1 << 1)
	orrs 	r4, r4, r5
	orrs 	r3, r3, r4
	str		r3, [r1, r2]

//    LPC_TIMER16_0->TCR |= (1 << MR0);
	ldr		r2, =TIMER_OFFSET_TCR
	ldr 	r3, [r1, r2]
	ldr		r4, =(1 << 0)
	orrs 	r3, r3, r4
	str		r3, [r1, r2]

	movs	r0, #16
	bl	NVIC_EnableIRQ

	pop {pc}
	.size	TIMER16B0_Config_Request, .-TIMER16B0_Config_Request

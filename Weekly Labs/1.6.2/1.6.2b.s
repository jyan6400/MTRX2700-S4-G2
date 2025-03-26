.syntax unified

.thumb

#include "initialise.s"

.global main

.text

main:
	@ Enabling GPIO clocks, Timer 2 and initialising the board
	BL enable_timer2_clock
	BL enable_peripheral_clocks
	BL initialise_discovery_board


	@ Setting up TIM2
	LDR R0, =TIM2
	MOV R1, #0b10000001      @ Enabling clock and ARPE
	STR R1, [R0, TIM_CR1]


	MOV R1, #799             @ Prescaler value to set 0.1ms intervals
	STR R1, [R0, TIM_PSC]
loop:

	MOV R1, #5000            @ Creates 500ms delay
	BL timer_delay

	@ Toggle LEDs
	LDR R0, =GPIOE
	LDR R2, [R0, #ODR+1]
	EOR R2, R2, #0b10101010
	STR R2, [R0, #ODR+1]

	B loop

timer_delay:
	LDR R0, =TIM2
	STR R1, [R0, TIM_ARR]    @ Store 500ms delay into auto-reload register

	MOV R2, #1
    STR R2, [R0, #0x14]      @ Enable update generation in event generation register

	MOV R2, #0
    STR R2, [R0, TIM_CNT]    @ Reset counter
    STR R2, [R0, TIM_SR]     @ Clearing update interrupt flag

wait_loop:
    LDR R2, [R0, TIM_SR]
    TST R2, #1               @ Checking update interrupt flag
    BEQ wait_loop            @ Wait for counter overflow

    STR R2, [R0, TIM_SR]     @ Clear update interrupt again

    BX LR                    @ Return

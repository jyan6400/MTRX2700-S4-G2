.syntax unified
.thumb

#include "initialise.s"

.global main

.data

.text

main:

	BL enable_timer2_clock
	BL enable_peripheral_clocks
	BL initialise_discovery_board

	LDR R0, =TIM2                     @load base address of the TIME2
	MOV R1, #0b1                      @setting the TIM2 EN =1
	STR R1, [R0, TIM_CR1]             @Enable TIM2

	BL milliseconds_delay             @setting milliseconds delay
    @BL microsecond_delay             @setting micoseconds delay
    @BL second_delay                  @setting seconds delay
    @BL hour_delay                    @setting hour delay

	BL trigger_prescaler

main_loop:


    BL delay    @Skip to delay
     @LED  Flashing
    LDR R0, =GPIOE
    LDR R3, [R0, #ODR]
    EOR R3, R3, #(1 << 9 | 1 << 15 | 1 << 13 | 1 << 11) @LD3,LD6,LD10,LD7 Enable
    STR R3, [R0, #ODR]
    B main_loop


delay:
    @Reset the TIM2 counter
    LDR R0, =TIM2
    MOV R4, #0x0000
    STR R4, [R0, TIM_CNT]

Counter:
 @ Counter the TIM_CNT = R6's value Jump out
    LDR R5, [R0, TIM_CNT]
    CMP R5, R6        @ Compare R5 <= R6?
    BGE return_TO_delay  @If R5<= R6 true return to delay function
    B Counter

return_TO_delay:
    BX LR @skip to delay

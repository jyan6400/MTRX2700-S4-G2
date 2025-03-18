.syntax unified
.thumb

#include "initialise.s"
.global main

.data
delay_time: .word 1000000  @ 1*10^6us=1s
hardware_parameter: .word 8 @ The hardware clock parameters (STM32F3=8)

.text

main:
    BL enable_timer2_clock
    BL enable_peripheral_clocks
    BL initialise_discovery_board

    LDR R0, =TIM2 @load base address of the TIME2
    MOV R1, #1    @setting the TIM2 EN =1
    STR R1, [R0, TIM_CR1]  @ Enable TIM2

main_loop:

    LDR R1, =delay_time @load the data from delay_time to R1
    LDR R1, [R1]   @Dereferencing address

    LDR R2, =hardware_parameter @load the data from hardware_parameter to R2
    LDR R2, [R2]   @Dereferencing address

    MUL R1, R2     @R1=R1*R2
    BL delay   @Skip to delay
    @LED  Flashing
    LDR R0, =GPIOE
    LDR R3, [R0, #ODR]
    EOR R3, #1 << 9 | 1 << 15 | 1 << 13 | 1 << 11   @LD3,LD6,LD10,LD7 Enable
    STR R3, [R0, #ODR]

    delay:
    @Reset the TIM2 counter
    LDR R0, =TIM2
    MOV R4, #0x0000
    STR R4, [R0, TIM_CNT]

       Counter:
       @ Counter the TIM_CNT = R1's value Jump out
       LDR R5, [R0, TIM_CNT]
       CMP R5, R1    @ Compare R5 <= R1?
       BGE return_TO_delay @If R5<= R1 true return to delay function
       B Counter

return_TO_delay:
    BX LR     @skip to delay_function

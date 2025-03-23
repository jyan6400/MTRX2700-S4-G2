.syntax unified
.thumb

.global main

#include "initialise.s"
#include "definitions.s"

.data
recv_buffer: .space 64
recv_index:  .word 0

delay_time: .word 500000          @ 1s delay
hardware_parameter: .word 8        @ 8 MHz multiplier

.text

main:
    BL enable_timer2_clock
    BL enable_peripheral_clocks
    BL initialise_discovery_board
    BL enable_uart2

    @ Enable Timer2
    LDR R0, =TIM2
    MOV R1, #1
    STR R1, [R0, TIM_CR1]

    LDR R4, =recv_buffer
    LDR R5, =recv_index
    MOV R6, #0x21     @ '!' character

read_loop:
    LDR R0, =UART2
    LDR R1, [R0, #USART_ISR]
    TST R1, #(1 << UART_RXNE)
    BEQ read_loop

    LDRB R2, [R0, #USART_RDR]
    CMP R2, R6
    BEQ run_count_program

    LDR R3, [R5]
    STRB R2, [R4, R3]
    ADD R3, R3, #1
    STR R3, [R5]
    B read_loop

run_count_program:
    @ Null-terminate the string
    LDR R3, [R5]
    LDR R0, =recv_buffer
    ADD R0, R0, R3
    MOV R1, #0
    STRB R1, [R0]

    @ Reset variables
    MOV R1, #0       @ (unused for vowels)
    MOV R2, #0       @ consonant count
    MOV R5, #0       @ toggle (unused)

    LDR R0, =recv_buffer
    BL count_loop


    B main_loop

count_loop:
    LDRB R3, [R0], #1
    CMP R3, #0
    BEQ done_count

    @ Skip vowels
    CMP R3, #'A'
    BEQ count_loop
    CMP R3, #'E'
    BEQ count_loop
    CMP R3, #'I'
    BEQ count_loop
    CMP R3, #'O'
    BEQ count_loop
    CMP R3, #'U'
    BEQ count_loop
    CMP R3, #'a'
    BEQ count_loop
    CMP R3, #'e'
    BEQ count_loop
    CMP R3, #'i'
    BEQ count_loop
    CMP R3, #'o'
    BEQ count_loop
    CMP R3, #'u'
    BEQ count_loop

    @ Count consonants
    CMP R3, #'A'
    BLT count_loop
    CMP R3, #'Z'
    BLE increment_consonant
    CMP R3, #'a'
    BLT count_loop
    CMP R3, #'z'
    BLE increment_consonant
    B count_loop

increment_consonant:
    ADD R2, R2, #1
    B count_loop

done_count:
	MOV R7, R2       @ Save consonant count into R7 (preserve it)
    BX LR

@ -------------------------
main_loop:
    LDR R1, =delay_time
    LDR R1, [R1]

    LDR R2, =hardware_parameter
    LDR R2, [R2]

    MUL R1, R2
    BL delay

    @ Toggle LEDs showing consonant count from R7
    LDR R0, =GPIOE
    LDR R3, [R0, #ODR]
    EOR R3, R3, R7, LSL #8      @ Toggle bits PE8–PE15
    STR R3, [R0, #ODR]

    B main_loop

@ -------------------------
delay:
    @ Reset Timer2 counter
    LDR R0, =TIM2
    MOV R4, #0
    STR R4, [R0, TIM_CNT]

Counter:
    LDR R5, [R0, TIM_CNT]
    CMP R5, R1
    BGE return_TO_delay
    B Counter

return_TO_delay:
    BX LR

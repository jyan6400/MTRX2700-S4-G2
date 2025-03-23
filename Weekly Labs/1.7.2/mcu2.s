.syntax unified
.thumb

.global main

#include "initialise.s"
#include "definitions.s"

.data
recv_buffer: .space 64
recv_index:  .word 0

delay_time: .word 500000          @ 0.5s delay
hardware_parameter: .word 8       @ 8 MHz multiplier

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

    @ Reset vowel and consonant counters
    MOV R1, #0     @ vowel count
    MOV R2, #0     @ consonant count
    MOV R5, #1     @ toggle: 1 = vowel, 0 = consonant

    LDR R0, =recv_buffer
    BL count_loop

    MOV R6, R1     @ Save vowel count to R6
    MOV R7, R2     @ Save consonant count to R7

    B main_loop

count_loop:
    LDRB R3, [R0], #1
    CMP R3, #0
    BEQ done_count

    CMP R3, #'A'
    BEQ increment_vowel
    CMP R3, #'E'
    BEQ increment_vowel
    CMP R3, #'I'
    BEQ increment_vowel
    CMP R3, #'O'
    BEQ increment_vowel
    CMP R3, #'U'
    BEQ increment_vowel
    CMP R3, #'a'
    BEQ increment_vowel
    CMP R3, #'e'
    BEQ increment_vowel
    CMP R3, #'i'
    BEQ increment_vowel
    CMP R3, #'o'
    BEQ increment_vowel
    CMP R3, #'u'
    BEQ increment_vowel

    CMP R3, #'A'
    BLT count_loop
    CMP R3, #'Z'
    BLE increment_consonant
    CMP R3, #'a'
    BLT count_loop
    CMP R3, #'z'
    BLE increment_consonant
    B count_loop

increment_vowel:
    ADD R1, #1
    B count_loop

increment_consonant:
    ADD R2, #1
    B count_loop

done_count:
    BX LR

@ -------------------------
main_loop:
    CMP R5, #1
    BEQ display_vowels
    B display_consonants

display_vowels:
    MOV R3, R6        @ R6 = vowel count
    B display_leds

display_consonants:
    MOV R3, R7        @ R7 = consonant count

display_leds:
    LSL R3, R3, #8
    LDR R0, =GPIOE
    STR R3, [R0, #ODR]   @ Turn on LEDs
    BL delay

    MOV R3, #0
    STR R3, [R0, #ODR]   @ Turn off LEDs
    BL delay

    EOR R5, R5, #1       @ ✅ Toggle mode (after full cycle)
    B main_loop



@ -------------------------
delay:
    LDR R0, =delay_time
    LDR R1, [R0]

    LDR R0, =hardware_parameter
    LDR R2, [R0]

    MUL R1, R1, R2

    LDR R0, =TIM2
    MOV R4, #0
    STR R4, [R0, TIM_CNT]

delay_counter:
    LDR R8, [R0, TIM_CNT]
    CMP R8, R1
    BGE delay_done
    B delay_counter

delay_done:
    BX LR

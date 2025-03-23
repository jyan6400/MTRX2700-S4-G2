.syntax unified
.thumb

.global main

#include "initialise.s"
#include "definitions.s"

.data
recv_buffer: .space 64
recv_index:  .word 0

.text

main:
    BL enable_peripheral_clocks
    BL initialise_discovery_board
    BL enable_uart2

    LDR R4, =recv_buffer
    LDR R5, =recv_index
    MOV R6, #0x21          @ '!' character

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
    @ Null-terminate string
    LDR R3, [R5]
    LDR R0, =recv_buffer
    ADD R0, R0, R3
    MOV R1, #0
    STRB R1, [R0]

    @ Reset index
    MOV R1, #0         @ not used anymore (vowel)
    MOV R2, #0         @ consonant counter
    MOV R5, #0         @ no toggling needed

    LDR R0, =recv_buffer
    BL count_loop

program_loop:
    LDR R0, =GPIOE
    STRB R2, [R0, #0x15]   @ Display consonant count
    B program_loop

check_button:
    B program_loop

pressed:
    B program_loop

released:
    BX LR

count_loop:
    LDRB R3, [R0], #1
    CMP R3, #0
    BEQ program_loop

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

    @ Count consonants only
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
    ADD R2, #1
    B count_loop

.syntax unified
.thumb

.global main

#include "initialise.s"

.data
input_buffer:     .space 64
reversed_buffer:  .space 64
buffer_index:     .word 0

.text
main:
    BL initialise_power
    BL enable_peripheral_clocks
    BL enable_discovery_board
    BL enable_uart        @ USART1 (PC)
    BL enable_uart2       @ USART2 (to MCU2)

    LDR R4, =input_buffer
    LDR R5, =buffer_index
    MOV R6, #0x21         @ '!' character

read_loop:
    LDR R0, =UART
    LDR R1, [R0, #USART_ISR]
    TST R1, #(1 << UART_RXNE)
    BEQ read_loop

    LDRB R2, [R0, #USART_RDR]
    LDR R3, [R5]
    STRB R2, [R4, R3]
    ADD R3, R3, #1
    STR R3, [R5]

    CMP R2, R6
    BEQ check_palindrome
    B read_loop

check_palindrome:
    LDR R0, =input_buffer
    LDR R5, =buffer_index
    LDR R4, [R5]            @ Get length
    MOV R1, #0
    LDR R2, =reversed_buffer

    @ Reverse the buffer
    SUB R4, R4, #2          @ Exclude '!' at end for palindrome check
reverse_loop:
    CMP R4, #0
    BLT done_reverse
    LDR R3, =input_buffer
    ADD R3, R3, R4
    LDRB R7, [R3]
    STRB R7, [R2, R1]
    ADD R1, R1, #1
    SUB R4, R4, #1
    B reverse_loop

done_reverse:
    MOV R3, #0
    STRB R3, [R2, R1]

    LDR R0, =input_buffer
    LDR R1, =reversed_buffer

compare_loop:
    LDRB R2, [R0], #1
    LDRB R3, [R1], #1
    CMP R2, #0x21        @ Stop comparing at '!'
    BEQ is_palindrome
    CMP R2, R3
    BNE forward_message
    B compare_loop

is_palindrome:
    LDR R0, =GPIOE
    LDR R3, [R0, #0x14]
    ORR R3, R3, #(1 << 9 | 1 << 11 | 1 << 13 | 1 << 15)
    STR R3, [R0, #0x14]

forward_message:
    @ Send entire buffer (including '!')
    LDR R4, =input_buffer
    LDR R5, =buffer_index
    LDR R6, [R5]             @ Length incl. '!'
    MOV R7, #0               @ Index

send_loop:
    CMP R7, R6
    BGE reset

    LDRB R2, [R4, R7]
    ADD R7, R7, #1

    LDR R0, =UART2
wait_tx_ready:
    LDR R1, [R0, #USART_ISR]
    TST R1, #(1 << UART_TXE)
    BEQ wait_tx_ready
    STRB R2, [R0, #USART_TDR]

    B send_loop

reset:
    MOV R2, #0
    STR R2, [R5]           @ Reset buffer index
    B read_loop

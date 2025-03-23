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
    BL initialise_discovery_board
    BL enable_uart        @ USART1 (PC)
    BL enable_uart2       @ USART2 (to MCU2)

    LDR R4, =input_buffer
    LDR R5, =buffer_index
    MOV R6, #0x21          @ '!' terminator

read_loop:
    LDR R0, =UART          @ USART1
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
    LDR R4, [R5]           @ Length including '!'
    SUB R4, R4, #2         @ Exclude '!' from check

    LDR R1, =reversed_buffer
    MOV R5, #0

reverse_loop:
    CMP R4, #0
    BLT done_reverse
    LDR R3, =input_buffer
    ADD R3, R3, R4
    LDRB R2, [R3]
    STRB R2, [R1, R5]
    ADD R5, R5, #1
    SUB R4, R4, #1
    B reverse_loop

done_reverse:
    MOV R3, #0
    STRB R3, [R1, R5]      @ Null-terminate reversed string

    LDR R0, =input_buffer
    LDR R1, =reversed_buffer

compare_loop:
    LDRB R2, [R0], #1
    LDRB R3, [R1], #1
    CMP R2, #0x21          @ Stop comparing at '!'
    BEQ is_palindrome
    CMP R2, R3
    BNE forward_message
    B compare_loop

is_palindrome:
    @ Light up PE12–PE15
    LDR R0, =GPIOE
    LDR R3, [R0, #0x14]
    ORR R3, R3, #(1 << 12 | 1 << 13 | 1 << 14 | 1 << 15)
    STR R3, [R0, #0x14]

forward_message:
    LDR R4, =input_buffer
    LDR R5, =buffer_index
    LDR R6, [R5]            @ Total message length
    MOV R7, #0

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
    STR R2, [R5]            @ Reset buffer index
    B read_loop

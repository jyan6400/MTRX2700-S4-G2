.syntax unified
.thumb

.global main

#include "initialise.s"

.data
input_buffer:     .space 64
buffer_index:     .word 0

.text
main:
    BL initialise_power
    BL enable_peripheral_clocks
    BL initialise_discovery_board
    BL enable_uart        @ USART1 (PC)
    BL enable_uart2       @ USART2 (to MCU2)

wait_rx:
    LDR R0, =UART
    LDR R1, [R0, #USART_ISR]
    TST R1, #(1 << UART_RXNE)
    BEQ wait_rx

    LDRB R2, [R0, #USART_RDR]
    CMP R2, #0x0D           @ CR detected, stop reading
    BEQ convert_to_lowercase

    LDR R3, =buffer_index
    LDR R4, [R3]
    LDR R5, =input_buffer
    STRB R2, [R5, R4]
    ADD R4, R4, #1
    STR R4, [R3]
    B wait_rx

convert_to_lowercase:
    LDR R4, =input_buffer
    LDR R5, =buffer_index
    LDR R6, [R5]
    MOV R7, #0

lowercase_loop:
    CMP R7, R6
    BGE check_palindrome

    LDRB R2, [R4, R7]
    CMP R2, #'A'
    BLT store_lowercase
    CMP R2, #'Z'
    BGT store_lowercase
    ADD R2, R2, #32         @ Convert uppercase to lowercase

store_lowercase:
    STRB R2, [R4, R7]
    ADD R7, R7, #1
    B lowercase_loop

check_palindrome:
    SUB R6, R6, #1          @ Point to last valid char

    MOV R1, #0              @ R1 = start index
palindrome_loop:
    CMP R1, R6
    BGE encode_loop         @ Checked all, palindrome found

    LDRB R5, [R4, R1]
    LDRB R3, [R4, R6]
    CMP R5, R3
    BNE reset               @ Not palindrome, discard

    ADD R1, R1, #1
    SUB R6, R6, #1
    B palindrome_loop

encode_loop:
    LDR R5, =buffer_index
    LDR R6, [R5]
    MOV R7, #0
encode_char_loop:
    CMP R7, R6
    BGE send_cr

    LDRB R2, [R4, R7]
    CMP R2, #'a'
    BLT wait_tx_ready
    CMP R2, #'z'
    BGT wait_tx_ready
    ADD R2, R2, #5
    CMP R2, #'z'
    BLE wait_tx_ready
    SUB R2, R2, #26

wait_tx_ready:
    LDR R0, =UART2
    LDR R1, [R0, #USART_ISR]
    TST R1, #(1 << UART_TXE)
    BEQ wait_tx_ready
    STRB R2, [R0, #USART_TDR]

    ADD R7, R7, #1
    B encode_char_loop

send_cr:
    MOV R2, #0x0D
    LDR R0, =UART2
wait_tx_ready_cr:
    LDR R1, [R0, #USART_ISR]
    TST R1, #(1 << UART_TXE)
    BEQ wait_tx_ready_cr
    STRB R2, [R0, #USART_TDR]

reset:
    MOV R2, #0
    LDR R3, =buffer_index
    STR R2, [R3]            @ Clear buffer_index
    B wait_rx

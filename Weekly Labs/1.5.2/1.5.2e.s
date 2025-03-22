.syntax unified
.thumb

.global main

#include "initialise.s"

.data
.align
incoming_buffer:      .space 62
incoming_counter:     .byte  62

.text
main:
    BL  initialise_power
    BL  enable_peripheral_clocks
    BL  enable_uart      @ Configure USART1
    BL  enable_uart2     @ Configure USART2

    LDR  R1, =incoming_buffer
    LDR  R7, =incoming_counter
    LDRB R7, [R7]        @ R7 = buffer size (62)
    MOV  R8, #0          @ Current index in the buffer

read_loop:
    LDR  R0, =UART       @ Base address of USART1
    LDR  R6, [R0, #USART_ISR]
    TST  R6, #(1 << UART_ORE | 1 << UART_FE)
    BNE  clear_error

    TST  R6, #(1 << UART_RXNE)
    BEQ  read_loop

    LDRB R3, [R0, #USART_RDR]
    LDR  R1, =incoming_buffer
    STRB R3, [R1, R8]
    ADD  R8, R8, #1

    CMP  R8, R7
    BGE  buffer_full
    B    read_loop

buffer_full:
    BL   transmit_buffer
    MOV  R8, #0
    B    read_loop

clear_error:
    LDR  R0, =UART
    LDR  R6, [R0, #USART_ICR]
    ORR  R6, R6, #(1 << UART_ORECF | 1 << UART_FECF)
    STR  R6, [R0, #USART_ICR]
    B    read_loop

transmit_buffer:
    LDR  R0, =UART2
    LDR  R3, =incoming_buffer
    MOV  R4, R7

tx_loop:
    LDR  R1, [R0, #USART_ISR]
    TST  R1, #(1 << UART_TXE)
    BEQ  tx_loop

    LDRB R5, [R3], #1
    STRB R5, [R0, #USART_TDR]
    SUBS R4, R4, #1
    BGT  tx_loop
    BX   LR


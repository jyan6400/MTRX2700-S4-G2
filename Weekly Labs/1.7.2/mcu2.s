.syntax unified
.thumb

.global main

#include "initialise.s"

.data
.align
recv_buffer: .space 64
recv_index:  .word 0

.text
main:
    BL initialise_power
    BL enable_peripheral_clocks
    BL initialise_discovery_board     @ Sets up GPIOE for LEDs
    BL enable_uart2                   @ Only USART2 is needed

    LDR R4, =recv_buffer
    LDR R5, =recv_index
    MOV R6, #0x21                     @ '!' character

read_loop:
    LDR R0, =UART2
    LDR R1, [R0, #USART_ISR]
    TST R1, #(1 << UART_RXNE)
    BEQ read_loop

    LDRB R2, [R0, #USART_RDR]
    CMP R2, R6
    BEQ received_terminator

    LDR R3, [R5]
    STRB R2, [R4, R3]
    ADD R3, R3, #1
    STR R3, [R5]

    B read_loop

received_terminator:
    @ Toggle GPIOE LEDs (LD3, LD6, LD7, LD10)
    LDR R0, =GPIOE
    LDR R3, [R0, #0x14]                     @ Read ODR
    EOR R3, R3, #(1 << 9 | 1 << 11 | 1 << 13 | 1 << 15)
    STR R3, [R0, #0x14]                     @ Toggle LEDs

    MOV R3, #0
    STR R3, [R5]                            @ Reset buffer index

    B read_loop

.syntax unified
.thumb

.global main

#include "initialise.s"

.text
main:
    BL initialise_power
    BL enable_peripheral_clocks
    BL enable_uart      @ USART1 (PC)
    BL enable_uart2     @ USART2 (to MCU2)

forward_loop:
    LDR R0, =UART
    LDR R1, [R0, #USART_ISR]
    TST R1, #(1 << UART_RXNE)
    BEQ forward_loop

    LDRB R2, [R0, #USART_RDR]     @ Read byte from PC

    LDR R0, =UART2
wait_tx_ready:
    LDR R1, [R0, #USART_ISR]
    TST R1, #(1 << UART_TXE)
    BEQ wait_tx_ready

    STRB R2, [R0, #USART_TDR]     @ Send to MCU2

    B forward_loop

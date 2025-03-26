.syntax unified
.thumb

.global main

#include "initialise.s"

.text
main:
	@ Enbaling power, GPIO clocks and USARTs
    BL initialise_power
    BL enable_peripheral_clocks
    BL enable_usart      		  @ USART1 connected to PC
    BL enable_usart2     		  @ USART2 connected to MCU2

forward_loop:
    LDR R0, =UART				  @ USART1 base address
    LDR R1, [R0, #USART_ISR]	  @ Load USART1 status
    TST R1, #(1 << UART_RXNE)	  @ Check if ready to receive data
    BEQ forward_loop			  @ If not ready then keep checking

    LDRB R2, [R0, #USART_RDR]     @ Read byte from PC

    LDR R0, =UART2				  @ USART2 base adress
wait_tx_ready:
    LDR R1, [R0, #USART_ISR]	  @ Load status
    TST R1, #(1 << UART_TXE)	  @ Check if ready to transmit
    BEQ wait_tx_ready			  @ Loop if not ready

    STRB R2, [R0, #USART_TDR]     @ Send to MCU2

    B forward_loop

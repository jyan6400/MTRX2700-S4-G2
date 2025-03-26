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
	@ Setting up board, GPIO clocks and power
    BL initialise_power
    BL enable_peripheral_clocks
    BL initialise_discovery_board
         
    BL enable_usart2                @ Only USART2 is needed

    LDR R4, =recv_buffer			@ Buffer to receive from USART1
    LDR R5, =recv_index				@ Buffer index
    MOV R6, #0x21                   @ Terminating charcter

read_loop:
    LDR R0, =UART2
    LDR R1, [R0, #USART_ISR]
    TST R1, #(1 << UART_RXNE)		@ Check if ready to receive characters
    BEQ read_loop

    LDRB R2, [R0, #USART_RDR]		
    CMP R2, R6
    BEQ received_terminator			@ Branch once message is finished

    LDR R3, [R5]
    STRB R2, [R4, R3]
    ADD R3, R3, #1
    STR R3, [R5]

    B read_loop

received_terminator:
    @ Toggle all LEDs on 
    LDR R0, =GPIOE
    LDR R3, =0b11111111                     @ Load bitmask for LEDs
    STRB R3, [R0, #ODR+1]                   @ Store in GPIOE

    MOV R3, #0
    STR R3, [R5]                            @ Reset buffer index

    B read_loop

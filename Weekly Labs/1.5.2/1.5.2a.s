.syntax unified
.thumb

.global main

#include "initialise.s"

.data
@ define variables

.align

@ Define a string
tx_string: .asciz "string of characters"
tx_end: .asciz "\n"

tx_length: .byte 20  @ Length of the string

.text
@ define text

main:
	@ Initialising power on the board
    BL initialise_power

    @ Enabling clocks for GPIOs
    BL enable_peripheral_clocks

    @ Enabling USART1 to communicate with PC
    BL enable_uart

pressed:
	LDR R0, =GPIOA
    LDRB R2, [R0, #0x10]  @ Read button state
    ANDS R2, #0x01        @ Check if button is pressed
    BEQ pressed      	  @ Wait until button is pressed

    BL transmit

released:
	LDR R0, =GPIOA
    LDRB R2, [R0, #0x10]  @ Read button state again
    ANDS R2, #0x01        @ Check if still pressed
    BNE released 		  @ Stay here until the button is released

    B pressed  			  @ Go back to checking for button press

@ Function to transmit the message once
transmit:
    LDR R0, =UART 		@ Base address for USART1
    LDR R3, =tx_string  @ String to transmit
    LDR R4, =tx_length  @ Length of string
    LDR R7, =tx_end 	@ Terminating character to append
    LDR R4, [R4]  	    @ Dereference length variable


transmit_loop:
    LDR R1, [R0, USART_ISR]   @ Load UART status
    ANDS R1, 1 << UART_TXE    @ Check if TX buffer is empty
    BEQ transmit_loop         @ Wait if not ready

    LDRB R5, [R3], #1  		  @ Load next character
    STRB R5, [R0, USART_TDR]  @ Transmit character

    SUBS R4, #1  			  @ Decrement length counter
    BGT transmit_loop 		  @ Continue if more characters to send
    BEQ end

end:
	LDR R1, [R0, USART_ISR]   @ Load UART status
    ANDS R1, 1 << UART_TXE    @ Check if TX buffer is empty
    BEQ end        			  @ Wait if not ready
	LDRB R5, [R7]  			  @ Load next character
    STRB R5, [R0, USART_TDR]  @ Transmit character
    B released







.syntax unified
.thumb

.global main

#include "initialise.s"

.data
@ Define variables

.align
incoming_buffer: .space 62  @ Allocate buffer space (62 bytes)
incoming_counter: .byte 62  @ Store buffer size

.text
@ Define text

main:
    BL initialise_power
    BL enable_peripheral_clocks
    BL enable_uart

    @ Load buffer and counter memory addresses
    LDR R1, =incoming_buffer  @ Buffer address
    LDR R7, =incoming_counter @ Address of buffer size
    LDRB R7, [R7]  @ Load max buffer size from memory

    MOV R8, #0x00  @ Pointer to track buffer position
    MOV R5, #0x21  @ Terminating character (newline '\n' or 0x0A)

read_string:
    LDR R0, =UART  @ Base address for UART
    LDR R6, [R0, USART_ISR]  @ Load UART status

    TST R6, 1 << UART_ORE | 1 << UART_FE  @ Check for errors
    BNE clear_error  @ If errors exist, clear them

    TST R6, 1 << UART_RXNE  @ Check if data is available
    BEQ read_string  @ If no data, continue polling

    LDRB R3, [R0, USART_RDR]  @ Read the character from UART

    CMP R3, R5  @ Compare with terminating character
    BEQ end_read  @ If match, exit loop

    STRB R3, [R1, R8]  @ Store character in buffer
    ADD R8, #1  @ Move buffer index

    CMP R8, R7  @ Check if buffer is full
    BGE reset_buffer  @ Reset buffer if full

    B read_string  @ Continue reading

reset_buffer:
    MOV R8, #0  @ Reset buffer index
    B read_string

clear_error:
    LDR R6, [R0, USART_ICR]  @ Load error status
    ORR R6, 1 << UART_ORECF | 1 << UART_FECF  @ Clear flags
    STR R6, [R0, USART_ICR]
    B read_string  @ Continue polling

end_read:
	MOV R3, #0  @ Store null terminator
    STRB R3, [R1, R8]  @ Null-terminate the buffer

    B read_string  @ Stay in loop after reading stops

.syntax unified
.thumb

.global main

#include "initialise.s"

.data
input_buffer:     .space 64
buffer_index:     .word 0

.text
main:
	@ Enable power to the board
    BL initialise_power

    @ Enabling peripheral clocks
    BL enable_peripheral_clocks

    @ Initialising baord
    BL initialise_discovery_board

    @ Enabling USARTs
    BL enable_usart        @ USART1 connected to PC
    BL enable_usart2       @ USART2 connected to MCU2

wait_to_receive:

    LDR R0, =UART				@ USART1 base address
    LDR R1, [R0, #USART_ISR]	@ Check status
    TST R1, #(1 << UART_RXNE)	@ Wait until ready to receive data
    BEQ wait_to_receive

    LDRB R2, [R0, #USART_RDR]
    CMP R2, #0x0D           	@ Read data until terminating character is received
    BEQ lowercase_initialise	@ Convert to lowercase once received

	@ Loading buffer index and buffer to store string
    LDR R3, =buffer_index
    LDR R4, [R3]
    LDR R5, =input_buffer
    STRB R2, [R5, R4]			@ Store current character in buffer
    ADD R4, #1					@ Increment buffer index
    STR R4, [R3]				@ Store back to index
    B wait_to_receive

lowercase_initialise:
    LDR R4, =input_buffer
    LDR R5, =buffer_index
    LDR R6, [R5]				@ String length
    MOV R7, #0					@ Character index

lowercase_conversion:
    CMP R7, R6					@ Check if we have covered the string entirely
    BGE palindrome_initialise		@ If yes then check for palindrome

    LDRB R2, [R4, R7]			@ Load current character

    @ Check if not uppercase and store if not
    CMP R2, #'A'
    BLT store_lowercase
    CMP R2, #'Z'
    BGT store_lowercase
    ADD R2, #32         		@ Convert uppercase to lowercase

store_lowercase:
    STRB R2, [R4, R7] 			@ Store current character
    ADD R7, #1					@ Increase index and continue
    B lowercase_conversion

palindrome_initialise:
    SUB R6, #1          		@ Right pointer

    MOV R1, #0              	@ Left pointer
check_palindrome:
    CMP R1, R6
    BGE encode_initialise         	@ If all letters are found then encode

    LDRB R5, [R4, R1]
    LDRB R3, [R4, R6]
    CMP R5, R3					@ Compare charcaters
    BNE reset               	@ If a character doesn't match, not palindrome

	@ Increase left pointer and decrease right pointer
    ADD R1, #1
    SUB R6, #1
    B check_palindrome

encode_initialise:
	@ Establish string length and current index counter
    LDR R5, =buffer_index
    LDR R6, [R5]
    MOV R7, #0

encode_loop:
    CMP R7, R6
    BGE load_cr

    LDRB R2, [R4, R7]		@ Load character

    @ Check if it is within range a-z
    CMP R2, #'a'
    BLT transmit_loop 		@ If not send as normal
    CMP R2, #'z'
    BGT transmit_loop
    ADD R2, #5				@ If it is encode the message with caesar cypher +5
    CMP R2, #'z'
    BLE transmit_loop		@ Check if character has gone past alphabet range
    SUB R2, R2, #26			@ Loop back to start of alphabet if it has

transmit_loop:
    LDR R0, =UART2				@ USART2 base address
    LDR R1, [R0, #USART_ISR]	@ Check status
    TST R1, #(1 << UART_TXE)	@ Check if ready to transmit
    BEQ transmit_loop
    STRB R2, [R0, #USART_TDR]	@ Transmit encoded character

    ADD R7, #1					@ Increment character index
    B encode_loop

load_cr:
    MOV R2, #0x0D				@ Send carriage return character
    LDR R0, =UART2
finish_transmission:
    LDR R1, [R0, #USART_ISR]
    TST R1, #(1 << UART_TXE)
    BEQ finish_transmission
    STRB R2, [R0, #USART_TDR]	@ Transmit carriage return

reset:
    MOV R2, #0
    LDR R3, =buffer_index
    STR R2, [R3]            	@ Clear buffer index if not a palindrome
    B wait_to_receive			@ Wait for new message

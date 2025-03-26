.syntax unified
.thumb

.global main

#include "initialise.s"
#include "definitions.s"

.data
recv_buffer: .space 64
recv_index:  .word 0

.text

main:
	@ Enables timer2 for delay
    BL enable_timer2_clock

    @ Setting the peripheral clocks
    BL enable_peripheral_clocks

    @Initialising board
    BL initialise_discovery_board

    @ Enabling USART 2
    BL enable_usart2

    @ Setting up TIM2
	LDR R0, =TIM2
	MOV R1, #0b10000001              @ Enabling clock and ARPE
	STR R1, [R0, TIM_CR1]

	LDR R0, =TIM2
	MOV R1, #799               @ Prescaler value to set 0.1ms intervals
	STR R1, [R0, TIM_PSC]

    LDR R4, =recv_buffer  @ Buffer to recive charcters
    LDR R5, =recv_index   @ Current index of received string
    MOV R6, #0x0D         @ Setting the carriage return as terminating character

read_loop:
    LDR R0, =UART2           @ Base adress for USART2
    LDR R1, [R0, #USART_ISR] @ Load status of USART


    TST R1, #(1 << UART_RXNE) @ Checking if there is data to read
    BEQ read_loop             @ If not keep checking

    LDRB R2, [R0, #USART_RDR] @ Loads the current charcter into R2
    CMP R2, R6                @ Check for end of transmission
    BEQ initialise_count      @ If it's the end then continue with program

    @ Caesar cypher decoding
    SUB R2, #5       @ Decode 5 characters
    CMP R2, #'a'
    BGE store_letter @ Checks if the charcter is now out of alphabet range
    ADD R2, #26      @ Loops back if it is

store_letter:
    LDR R3, [R5]      @ Loads index position
    STRB R2, [R4, R3] @ Stores charcter in index position of buffer

    @ Adding 1 to index
    ADD R3, #1
    STR R3, [R5]

    B read_loop       @ Continues reading for next character

initialise_count:
    @ Null terminate the decoded string
	LDR R3, [R5]
	MOV R1, #0
	STRB R1, [R4, R3] @ Store null terminator into last index of the buffer

    @ Initialise vowel and consonant counts
    MOV R6, #0     @ Vowel count
    MOV R7, #0     @ Consonant count
    MOV R5, #1     @ Mode for showing count (1= vowels, 0=consonants)

count_loop:
	@ Check if we have reached the null terminator
    LDRB R3, [R4], #1
    CMP R3, #0
    BEQ display_mode @ If so continue to next section

	@ Check for all vowels
    CMP R3, #'a'
    BEQ increase_vowels
    CMP R3, #'e'
    BEQ increase_vowels
    CMP R3, #'i'
    BEQ increase_vowels
    CMP R3, #'o'
    BEQ increase_vowels
    CMP R3, #'u'
    BEQ increase_vowels

	@ If not a vowel check if it's within range of a-z
    CMP R3, #'a'
    BLT count_loop 			@ If not then continuing counting
    CMP R3, #'z'
    BLE increase_consonants @ If it is then increment consonant count
    B count_loop

increase_vowels:
	@ Adding to vowel count
    ADD R6, #1
    B count_loop

increase_consonants:
	@ Adding to consonant count
    ADD R7, #1
    B count_loop

display_mode:
	@ Checking whether to display vowels or consonants
    CMP R5, #1
    BEQ display_vowels
    B display_consonants

display_vowels:
    MOV R3, R6        @ Storing vowel count into R3
    B display_leds

display_consonants:
    MOV R3, R7        @ Storing consonant count into R3

display_leds:
    LDR R0, =GPIOE
    STRB R3, [R0, #ODR+1]
	BL timer_delay			 @ Trigger delay

	EOR R5, #1				 @ Toggle consonant or vowel mode
	B display_mode

timer_delay:
    LDR R0, =TIM2
    MOV R1, #5000            @ Creates 500ms delay
    STR R1, [R0, TIM_ARR]    @ Store into auto-reload register

    MOV R2, #1
    STR R2, [R0, #0x14]      @ Enable update generation in event generation register

    MOV R2, #0
    STR R2, [R0, TIM_CNT]    @ Reset counter
    STR R2, [R0, TIM_SR]     @ Clearing update interrupt flag

wait_loop:
    LDR R2, [R0, TIM_SR]
    TST R2, #1               @ Checking update interrupt flag
    BEQ wait_loop            @ Wait for counter overflow

    MOV R2, #0
    STR R2, [R0, TIM_SR]     @ Clear update interrupt again

    BX LR                    @ Return

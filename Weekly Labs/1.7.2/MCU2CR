.syntax unified
.thumb

.global main

#include "initialise.s"
#include "definitions.s"

.data
recv_buffer: .space 64
recv_index:  .word 0

delay_time: .word 500000          @ 0.5s delay
hardware_parameter: .word 8       @ 8 MHz multiplier

.text

main:
	@ Enables timer2 for delay
    BL enable_timer2_clock

    @ Branch with link to set the clocks for the I/O and UART
    BL enable_peripheral_clocks

    @Initialising board
    BL initialise_discovery_board

    @ Enabling USART 2
    BL enable_usart2

    @ Setting up TIM2
    LDR R0, =TIM2
    MOV R1, #1
    STR R1, [R0, TIM_CR1] @ Enabling counter

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
    BEQ initialise_count     @ If it's the end then continue with program

    @ Caesar cypher decoding
    SUB R2, #5     @ Decode 5 characters
    CMP R2, #'a'
    BGE store_letter @ Checks if the charcter is now out of alphabet range
    ADD R2, #26    @ Loops back if it is

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
    BLT count_loop @ If not then continuing counting
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
    STRB R3, [R0, #ODR+1]   @ Turn on LEDs to show number of consonants/vowels
    BL delay 				@ Trigger 500ms delay

    MOV R3, #0
    STRB R3, [R0, #ODR+1]   @ Turn off LEDs
    BL delay 				@ Trigger 500ms delay

    EOR R5, #1       @ Change to show either vowels/consonants now
    B display_mode 		 @ Repeat loop infinitely

delay:
    LDR R0, =delay_time 		 @ Loading delay time of 500ms
    LDR R1, [R0]				 @ Storing this into R1

    LDR R0, =hardware_parameter  @ Loading the frequency of the clock
    LDR R2, [R0] 				 @ Storing this into R2

    MUL R1, R2 					 @ Calculating how many clock cycles to wait

    LDR R0, =TIM2
    MOV R4, #0
    STR R4, [R0, TIM_CNT] @ Resetting timer counter to 0

delay_check:
    LDR R8, [R0, TIM_CNT] @ Store current timer count
    CMP R8, R1			  @ Check if we have completed enough cycles
    BLT delay_check	      @ Loop if delay is not finished

    BX LR		  		  @ Finish delay once cycles have been reached

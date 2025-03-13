.syntax unified
.thumb

#include "initialise.s"
#include "definitions.s"

.global main

.data
@ Define string in memory
string: .asciz "aeiou !/' fghrdz4s"

.text

@ This is the entry function called from the C file
main:
    @ Branch with link to set the clocks for the I/O and UART
    BL enable_peripheral_clocks

    @ Once the clocks are started, need to initialise the discovery board I/O
    BL initialise_discovery_board

    @ Start with vowels displayed
    MOV R5, #1  @ Variable to track mode

    LDR R0, =string  @ Load address of string
    MOV R1, #0  @ Vowel count
    MOV R2, #0  @ Consonant count
    BL count_loop

program_loop:
    @ Load GPIOE register address
    LDR R0, =GPIOE
    CMP R5, #1 @ Check if in vowel or consonant mode
    BEQ display_vowels
    B display_consonants


display_vowels:
    STRB R1, [R0, #ODR + 1]  @ Displaying vowel count
    B check_button


display_consonants:
    STRB R2, [R0, #ODR + 1]  @ Displaying consonant count

check_button:
    @ Read the input button state
    LDR R0, =GPIOA
    LDRB R6, [R0, #IDR]  @ Load button state
    ANDS R6, #0x01  @ We only need to check the first bit for the button
    BNE pressed  @ Switch once pressed

    B program_loop  @ Loop until pressed

pressed:
    EOR R5, #1  @ Change between displaying vowels and consonants
    BL released
    B program_loop

count_loop:
    LDRB R3, [R0], #1  @ Load a charcter then point to next one
    CMP R3, #0
    BEQ program_loop  @ Stop once null terminator is reached

    @ Check for vowels
    CMP R3, #'A'
    BEQ increment_vowel
    CMP R3, #'E'
    BEQ increment_vowel
    CMP R3, #'I'
    BEQ increment_vowel
    CMP R3, #'O'
    BEQ increment_vowel
    CMP R3, #'U'
    BEQ increment_vowel
    CMP R3, #'a'
    BEQ increment_vowel
    CMP R3, #'e'
    BEQ increment_vowel
    CMP R3, #'i'
    BEQ increment_vowel
    CMP R3, #'o'
    BEQ increment_vowel
    CMP R3, #'u'
    BEQ increment_vowel

    @ Check for consonants
    CMP R3, #'A'
    BLT count_loop
    CMP R3, #'Z'
    BLE increment_consonant
    CMP R3, #'a'
    BLT count_loop
    CMP R3, #'z'
    BLE increment_consonant
    B count_loop

increment_vowel:
    ADD R1, #1 @ Incrementing vowel count by 1
    B count_loop @ Checking next letter

increment_consonant:
    ADD R2, #1 @ Incrementing consonant count by 1
    B count_loop @ Checking next letter



released:
    LDRB R6, [R0, #IDR]  @ Read button state again
    ANDS R6, #0x01  @ Mask bit 0
    BNE released  @ Wait until button is released
    BX LR

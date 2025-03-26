.syntax unified
.thumb

.global main

#include "initialise.s"

.data
ascii_string: .asciz "racecar"     @ Input string

.text
main:
    BL enable_peripheral_clocks
    BL initialise_discovery_board

    LDR R0, =ascii_string     @ Pointer to string
    MOV R1, R0                @ Copy of string for palindrome check
    MOV R2, #0                @ Length counter

@ Find string length
find_length:
    LDRB R3, [R1, R2]
    CMP R3, #0				  @ Checking for null terminator
    BEQ check_palindrome
    ADD R2, #1				  @ Increasing length
    B find_length

check_palindrome:
    SUB R2, #1                @ Right pointer
    MOV R3, #0                @ Left pointer

compare_loop:
    CMP R3, R2
    BGE is_palindrome         @ If the pointers have met and no disprencies, must be palindrome

    LDRB R4, [R0, R3]         @ Load left pointer character
    LDRB R5, [R0, R2]         @ Load right pointer character
    CMP R4, R5
    
    BNE not_palindrome        @ If they are not equal it is not a palindrome

	@ Increment pointers and keep comparing
    ADD R3, R3, #1
    SUB R2, R2, #1
    B compare_loop

is_palindrome:
    LDR R6, =GPIOE
    MOV R7, #0b10001000       @ Light green LEDs for palindrome
    STRB R7, [R6, #ODR+1]
    BX LR

not_palindrome:
    LDR R6, =GPIOE
    MOV R7, #0b00100010       @ Light red LEDs for not palindrome
    STRB R7, [R6, #ODR+1]
    BX LR
    MOV R6, #0                 @ Store 0 in R6 if not palindrome
    BX LR                      @ Return

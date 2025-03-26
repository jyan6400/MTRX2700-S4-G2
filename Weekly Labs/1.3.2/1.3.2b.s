.syntax unified
.thumb

.global main

#include "initialise.s"

.data
ascii_string: .asciz "mr. owl ate my metal worm"     @ Input string

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
    BGE is_palindrome         @ If done comparing all valid characters

@ Skip non-letter characters from left pointer
check_left:
    LDRB R4, [R0, R3]
    CMP R4, #'a'
    BLT increase_left		  @ If it is not a letter then increment the left pointer
    CMP R4, #'z'
    BLE check_right			  @ If it's a letter then check the right pointer

increase_left:
    ADD R3, #1				  @ Increase left pointer
    CMP R3, R2
    BGT is_palindrome		  @ If pointers have met then must be a palindrome
    B check_left

@ Skip non-letter characters from right pointer
check_right:
    LDRB R5, [R0, R2]
    CMP R5, #'a'
    BLT decrease_right		  @ If it is not a letter then increment the right pointer
    CMP R5, #'z'
    BLE compare_chars		  @ If it is a letter then compare them

decrease_right:
    SUB R2, #1				  @ Decrease right pointer
    CMP R3, R2
    BGT is_palindrome		  @ If pointers have met then must be a palindrome
    B check_right

compare_chars:
    CMP R4, R5
    BNE not_palindrome		  @ If characters do not match then reset

    @ Change pointers
    ADD R3, #1
    SUB R2, #1
    B compare_loop			  @ Loop to keep checking characters

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


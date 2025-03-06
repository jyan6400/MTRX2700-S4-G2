.syntax unified
.thumb

.global main


.data
@ define variables

string_buffer: .asciz "Replace this text\0"
ascii_string: .asciz "racecar\0" @ Define a null-terminated string
byte_array: .byte 0, 1, 2, 3, 4, 5, 6
word_array: .word 0x00, 0x40, 0x80, 0xc0, 0x10, 0x14, 0xffffffff


.text
@ define text


@ this is the entry function called from the startup file
main:

	LDR R0, =ascii_string  @ the address of the string
	LDR R1, =string_buffer  @ the address of the string
	LDR R4, =0x00
	LDR R5, =0x00

find_length:
	LDRB R3, [R0, R4]	@ load the byte from the ascii_string (byte number R2)
	CMP R3, #0	@ Test to see whether this byte is zero (for null terminated)
	BEQ string_loop
	ADD R4, #1  @ increment the offset R2
	B find_length

string_loop:
	SUB R4, #1  @ increment the offset R2
	LDRB R3, [R0, R4]	@ load the byte from the ascii_string (byte number R2)
	STRB R3, [R1, R5]	@ store the byte in the string_buffer (byte number R2)
	ADD R5, #1
	CMP R4, #-1
	BEQ finished_strings
	B string_loop  @ loop to the next byte

finished_strings:
    MOV R3, #0              @ Null terminator
    STRB R3, [R1, R5]       @ Add null terminator at the end

palindrome:
    LDR R0, =ascii_string      @ Load address of original string
    LDR R1, =string_buffer     @ Load address of reversed string

compare_loop:
    LDRB R3, [R0], #1          @ Load and increment ascii_string pointer
    LDRB R4, [R1], #1         @ Load and increment string_buffer pointer
    CMP R3, #0                 @ Check if null terminator (end of string)
    BEQ yes                    @ If both are identical, it's a palindrome
    CMP R3, R4                 @ Compare characters
    BNE no                     @ If different, not a palindrome
    B compare_loop             @ Continue checking next character

yes:
    MOV R6, #1                 @ Store 1 in R6 if palindrome
    BX LR                      @ Return

no:
    MOV R6, #0                 @ Store 0 in R6 if not palindrome
    BX LR                      @ Return

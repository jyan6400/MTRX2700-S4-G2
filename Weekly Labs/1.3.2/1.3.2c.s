@Jiaze sun 2025/3/9
.syntax unified
.thumb

.global main


.data
@ define variables


input_string: .asciz "Hello World 123" @ Define a import string
coding_string: .asciz "Mjqqt%\twqi%678" @ Define a coding string
decoding_string: .asciz "This is decoding string!"@ Define a decoding string


.text
@ define text


@ this is the entry function called from the startup file
main:

	LDR R0, =input_string  @ the address of the import string
	LDR R1, =coding_string  @ the address of the coding string
	LDR R6, =decoding_string @ the address of the decoding string
	LDR R2, = -5 	@ (+)coding and (-)decoding
    LDR R4, =0x00 	@ counter to the current place in the string

    BL Caesar_Cipher


Caesar_Cipher:

    CMP R2, #0     @check the R2 value is + or -
    BGT Coding     @ if positive skip to coding
    BLT Decoding   @ if negative skip to decoding

    Coding:

          LDRB R5, [R0, R4]   @ loading input string
          CMP R5, #0          @ detect the NULL of the strings
          BEQ finished_loop   @ if touch the NULL, finished_loop

          ADD R5, R2

          STRB R5, [R1, R4]   @ storing the coding strings
	      ADD R4, #1          @ increment the offset R4
	      B Coding


    Decoding:
          LDRB R5, [R1, R4]   @ loading coding string
          CMP R5, #0          @ detect the NULL of the strings
          BEQ finished_loop   @ if touch the NULL, finished_loop

          ADD R5, R2

          STRB R5, [R6, R4]   @ storing the decoding strings
	      ADD R4, #1          @ increment the offset R4
          B Decoding
finished_loop:

	BX LR  @ loop to the next byte

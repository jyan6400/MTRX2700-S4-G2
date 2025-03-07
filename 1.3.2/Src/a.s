.syntax unified
.thumb

.global main


.data
@ define variables

string_buffer: .asciz "replace this text replace this text" @ Define a null-terminated string
ascii_string: .asciz "Hello world!" @ Define a null-terminated string


.text
@ define text
    BL letters_convertion

@ this is the entry function called from the startup file
main:

	LDR R1, =ascii_string  @ the address of the string
	LDR R2, =string_buffer  @ the address of the string stored
	LDR R3, =0x00 	@ counter to the current place in the string


letters_convertion:

    LDRB R4, [R1, R3]   @ loading Ascii string
    CMP R4, #0          @ Detect the NULL of the strings
    BEQ finished_loop   @ if touch the NULL, finished——loop


    CMP R4, #65         @ compare the R4 Ascii < 65 (nonalphabetic)
    BLT store           @ if < 65 skip to store


    CMP R4, #90         @ compare the R4 Ascii <= 90 (Upperalphabetic)
    BLE Lowercase_convertion    @ if <= 90 skip to Lowercase_convertion


    CMP R4, #122        @ compare the R4 Ascii > 122 (nonalphabetic)
    BGT store           @ if > 122 skip to store

    SUB R4, #32     @ convert the lowercase to uppercase
    B store         @ store strings

    Lowercase_convertion:
    ADD R4, #32    @ convert the uppercase to lowercase

    store:
    STRB R4, [R2, R3]   @ storing the converted strings

	ADD R3, #1  @ increment the offset R2

    B letters_convertion

finished_loop:
	BX LR  @ loop to the next byte



finished_everything:

	B finished_everything 	@ infinite loop here

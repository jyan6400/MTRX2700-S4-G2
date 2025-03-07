.syntax unified
.thumb

.global main


.data
@ define variables

string_buffer: .asciz "replace this text replace this text" @ Define a store string
ascii_string: .asciz "Hello [] World!" @ Define a import string


.text
@ define text
@ this is the entry function called from the startup file
main:

	LDR R0, =ascii_string  @ the address of the string
	LDR R1, =string_buffer  @ the address of the string stored
	LDR R3, =0x00 	@ counter to the current place in the string
	MOV R2, #1      @if R2=1 upperconver, R2=0 lowerconver
    BL letters_convertion

letters_convertion:

    LDRB R4, [R0, R3]   @ loading Ascii string
    CMP R4, #0          @ detect the NULL of the strings
    BEQ finished_loop   @ if touch the NULL, finished_loop

    CMP R4, #65         @ compare the R4 Ascii < 65 (nonalphabetic)
    BLT store           @ if < 65 skip to store

    CMP R4, #122        @ compare the R4 Ascii <= 90 (alphabetic)
    BLE Convertion      @ if <= 90 skip to Convertion

    CMP R4, #122        @ compare the R4 Ascii > 122 (nonalphabetic)
    BGT store           @ if > 122 skip to store


    Convertion:

    CMP R2,#1                   @ if R2=1 is true convert Uppercase
    BEQ Uppercase_convertion    @ skip to Uppercase

    CMP R2,#0                   @ if R2=1 is true convert Lowercase
    BEQ  Lowercase_convertion   @ skip to Lowercase


    Uppercase_convertion:

    CMP R4, #96         @compare the R4 Ascii <= 96
    BLE store           @ if <= 96 skip to store

    SUB R4, #32         @ convert the lowercase to uppercase
    B store             @ store strings


    Lowercase_convertion:

    CMP R4, #91         @compare the R4 Ascii >= 91
    BGE store           @ if >= 91 skip to store


    ADD R4, #32         @ convert the uppercase to lowercase
    B store             @ store strings



    store:
    STRB R4, [R1, R3]   @ storing the converted strings

	ADD R3, #1          @ increment the offset R2

    B letters_convertion

finished_loop:
	BX LR  @ loop to the next byte

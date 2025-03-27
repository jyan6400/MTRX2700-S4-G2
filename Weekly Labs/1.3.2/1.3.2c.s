.syntax unified
.thumb

.global main

.data
input_string: .asciz "yzxjyz ocdn ozso"
converted_string:  .space 64

.text
main:
    LDR R1, =input_string      @ Original string
    LDR R0, =converted_string  @ Buffer to store coded string
    MOV R2, #5                 @ Shift amount, negative to decode, positive to


code_initialise:
    MOV R3, #0                 @ Index of coded string

code_loop:
    LDRB R4, [R1, R3]		   @ Load current character of original string
    CMP R4, #0				   @ If end of string finish program
    BEQ finished

	@ Check whether character is within range a-z
    CMP R4, #'a'
    BLT store_original		   @ Store character as normal if not
    CMP R4, #'z'
    BGT store_original

    ADD R5, R4, R2             @ Apply shift and store in R5

    CMP R2, #0				   @ Check whether to  or decode
    BLT decode_check		   @ If negative decode, if positive


encode_check:
	@ Check if shifted character is within range a-z
    CMP R5, #'z'
    BLE store_shifted		   @ If it is store the shifted letter
    SUB R5, #26				   @ If not then loop back around
    B store_shifted

decode_check:
	@ Check if shifted character is within range a-z
    CMP R5, #'a'
    BGE store_shifted		   @ If it is store the shifted letter
    ADD R5, #26				   @ If not then loop back around
    B store_shifted

store_original:
    MOV R5, R4                 @ Copy unchanged character

store_shifted:
    STRB R5, [R0, R3]		   @ Store character in buffer
    ADD R3, #1				   @ Increment index
    B code_loop

finished:
    MOV R5, #0				   @ Null terminate string
    STRB R5, [R0, R3]
    BX LR

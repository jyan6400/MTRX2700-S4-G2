.syntax unified
.thumb

#include "initialise.s"
#include "definitions.s"

.global main

.data
@ define variables

.text
@ define text

@ This is the entry function called from the C file
main:
    @ Branch with link to set the clocks for the I/O and UART
    BL enable_peripheral_clocks

    @ Once the clocks are started, need to initialise the discovery board I/O
    BL initialise_discovery_board

    @ Start with a single LED on
    LDR R4, =0b00000001

program_loop:
    @ Load GPIOE register address
    LDR R0, =GPIOE
    STRB R4, [R0, #ODR + 1]  @ Store R4 to ODR (bits 8-15)

    @ Read the input button state
    LDR R0, =GPIOA    @ Port for the input button
    LDRB R1, [R0, #IDR]@ load the lowest byte from the input data register port A
    ANDS R1, #0x01    @ Look only at bit 0 (input value of PA0)
    BNE pressed       @ loop until the button is pressed

    B program_loop    @ Repeat loop

pressed:
    @ Shift left to add the next LED while keeping previous LEDs on
    LSL R5, R4, #1
    ORR R4, R4, R5

    @ If all LEDs are on (0xFF), reset back to 1 LED
    CMP R4, #0x100
    BLO released   @ If R4 < 0x100, continue normally
    LDR R4, =0b00000001  @ Reset to 1 LED if all are on

released:
    @ Wait for button to be released
    LDRB R1, [R0, #IDR] @ load the lowest byte from the input data register port A
    ANDS R1, #0x01  @ Look only at bit 0 (input value of PA0)
    BNE released  @ loop until button is unpressed

    B program_loop  @ Return to program_loop once button is unpressed

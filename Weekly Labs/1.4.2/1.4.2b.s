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
    LDR R4, =0b00000000

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
    @ If all LEDs are off, turn on the first LED
    CMP R4, #0
    BNE shift_leds    @ If R4 is NOT zero, continue shifting LEDs
    LDR R4, =0b00000001  @ If R4 is zero, start with the first LED
    B released

shift_leds:
    LSL R5, R4, #1  @ Shift left to turn on the next LED
    ORR R4, R4, R5  @ Keep previous LEDs on

    @ If all LEDs are on reset to 0 LEDs
    CMP R4, #0x100 @ All LEDs on (0b11111111) corresponds to 255 in binary, therefore check if current state is above that
    BLO released   @ If R4 < 0x100, continue
    LDR R4, =0b00000000  @ Reset to all LEDs off

released:
    @ Wait for button to be released
    LDRB R1, [R0, #IDR] @ load the lowest byte from the input data register port A
    ANDS R1, #0x01  @ Look only at bit 0 (input value of PA0)
    BNE released  @ loop until button is unpressed

    B program_loop  @ Return to program_loop once button is unpressed

.syntax unified
.thumb

#include "initialise.s"
#include "definitions.s"

.global main

.data
@ define variables

.text
@ define text

main:
    @ Enabling clock for GPIOs
    BL enable_peripheral_clocks

    @ Initialising discovery baord
    BL initialise_discovery_board

    @ Start with a no LEDs on
    LDR R4, =0b00000000

program_loop:
    @ Load GPIOE register address
    LDR R0, =GPIOE
    STRB R4, [R0, #ODR + 1]  @ Store R4 to bits 8-15

    @ Read the input button state
    LDR R0, =GPIOA    @ Port for the input button
    LDRB R1, [R0, #IDR]@ load the lowest byte from the input data register port A
    ANDS R1, #0x01    @ Look only at bit 0 (input value of PA0)
    BNE pressed       @ Loop until the button is pressed

    B program_loop    @ Repeat loop

pressed:
    @ If all LEDs are off, turn on the first LED
    CMP R4, #0
    BNE change_leds    @ If R4 is NOT zero, continue shifting LEDs
    LDR R4, =0b00000001  @ If R4 is zero, start with the first LED
    B released

change_leds:
    LSL R4, #1  @ Shift left to turn on the next LED
    ORR R4, #1  @ Keep previous LEDs on

    @ If all LEDs are on reset to 0 LEDs
    CMP R4, #0b11111111 @ Check if all LEDs are on
    BLE released   @ If not then continue as normal
    LDR R4, =0b00000000  @ If all are on then reset to 0 on

released:
    @ Wait for button to be released
    LDRB R1, [R0, #IDR] @ load the lowest byte from the input data register port A
    ANDS R1, #0x01  @ Look only at bit 0 (input value of PA0)
    BNE released  @ loop until button is unpressed

    B program_loop  @ Return to program_loop once button is unpressed

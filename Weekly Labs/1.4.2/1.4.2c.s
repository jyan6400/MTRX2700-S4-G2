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
    @ Initialising clocks for GPIOs
    BL enable_peripheral_clocks

    @ Initialising discovery board
    BL initialise_discovery_board

    @ Start with no LEDs on
    LDR R4, =0b00000000
    
    MOV R5, #1  @ Variable to know whether to turn on or off LEDs

program_loop:
    @ Load GPIOE register address
    LDR R0, =GPIOE
    STRB R4, [R0, #ODR + 1]  @ Store LED pattern in bits 8-15
    
    @ Read the input button state
    LDR R0, =GPIOA
    LDRB R1, [R0, #IDR]
    ANDS R1, #0x01
    BNE pressed

    B program_loop

pressed:
    CMP R5, #1 @ Check if in turn on or turn off mode
    BEQ turn_on
    B turn_off

turn_on:
    LSL R4, #1   @ Shift left to turn on next LED
    ORR R4, #1   @ Keep previous LEDs on

    CMP R4, #0b11111111 @ Check if all LEDs are on
    BNE released @ If not all on continue
    MOV R5, #0  @ If all on switch to turning off
    B released

turn_off:
    LSR R4, #1   @ Shift right to turn off the last LED

    CMP R4, #0 @ Check if all LEDs are off
    BNE released @ If not all off continue
    MOV R5, #1  @ If all of switch to turning on

released:
    LDRB R1, [R0, #IDR]@ load the lowest byte from the input data register port A
    ANDS R1, #0x01 @ Look only at bit 0 (input value of PA0)
    BNE released  @ loop until button is unpressed

    B program_loop

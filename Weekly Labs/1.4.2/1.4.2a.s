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

@ Function to apply bitmask
bitmask:
	@ Bitmask setting LEDs to given pattern (First 4 on)
	LDR R0, =0b00001111
 
	@Loading GPIOE into R1
	LDR R1, =GPIOE
 
	@ Store bitmask into bits 8-15
    	STRB R0, [R1, #ODR + 1]
	BX LR

;************************************************************************
; Filename: Lab_4														*
;																		*
; ELEC3450 - Microprocessors											*
; Wentworth Institute of Technology										*
; Professor Bruce Decker												*
;																		*
; Student #1 Name: Takaris Seales										*
; Course Section: 03													*
; Date of Lab: <06-07-2017>												*
; Semester: Summer 2017													*
;																		*
; Function: This program demonstrates the use of interrupts 
; One GPIO is connected as an output. Using the internal timer, 		*
; and a counter, the LED blinks every 250ms								*
; The watchdog timer is disabled, and the prescaler set to 1.  	        *	
;																		*
; Wiring: 																*
; One RA7 switch connected to LED       								*			*
;************************************************************************												*
; A register may hold an instruction, a storage address, or any kind of data
;(such as a bit sequence or individual characters)
;BYTE-ORIENTED INSTRUCTION:	
;'f'-specifies which register is to be used by the instruction	
;'d'-designation designator: where the result of the operation is to be placed
;BIT-ORIENTED INSTRUCTION:
;'b'-bit field designator: selects # of bit affected by operation
;'f'-represents # of file in which the bit is located
;
;'W'-working register: accumulator of device. Used as an operand in conjunction with
;	 the ALU during two operand instructions															*
;************************************************************************

		#include <p16f877a.inc>

COUNT					EQU 0X20
TEMP_W					EQU 0X21			
TEMP_STATUS				EQU 0X22			


		__CONFIG		0X373A 				;Control bits for CONFIG Register w/o WDT enabled			

		
		ORG				0X0000				;Start of memory
		GOTO 		MAIN

		ORG 			0X0004				;INTR Vector Address
PUSH										;Stores Status and W register in temp. registers

		MOVWF 		TEMP_W
		SWAPF		STATUS,W
		MOVWF 		TEMP_STATUS
		BTFSC		PIR1, CCP1IF
		GOTO		INTRC

POP											;Restores W and Status registers
	
		SWAPF		TEMP_STATUS,W
		MOVWF		STATUS
		SWAPF		TEMP_W,F
		SWAPF		TEMP_W,W				
		RETFIE

INTRC										;ISR FOR LED
		BCF			PIR1,  CCP1IF
		INCF		COUNT, F
		GOTO 		POP
				


MAIN
		BCF			INTCON, GIE				;Disable all interrupts
		CLRF 		PORTC					;Clear GPIO to be used	
		BCF			STATUS, RP0				;Bank0
		MOVLW		0X00					;Set Count = 0
		MOVWF		COUNT
		MOVLW		0X05
		MOVWF		T1CON
		MOVLW		0X0B
		MOVWF		CCP1CON
		MOVLW		0X13
		MOVWF		CCPR1H
		MOVLW		0X88
		MOVWF		CCPR1L
		BSF			INTCON, PEIE			;Enable Peripheral Interrupts				
		BSF			STATUS, RP0				;Bank1 
		BSF			PIE1,   CCP1IE			;Enable CCPI1E bits (Capture Compare enable bit)
		MOVLW		0X00					;TRISC is 0000 0000 to have RC0-RC2 as outputs
		MOVWF 		TRISC
		BCF			STATUS, RP0				;Bank 0
		BSF			INTCON, GIE				;Enable all interrupts


CountTracker
		MOVLW		0XFA		
		XORWF		COUNT,  W				;Check to see if count = 250
		BTFSC		STATUS, Z
		GOTO		LED
		GOTO		CountTracker

LED
		MOVLW		0X80
		XORWF		PORTC,  RC7
		CLRF		COUNT
		GOTO		CountTracker

	


		RETURN

		END

		
		;BTFSS the zero bit in status register?
		;Switch to Bank 0 before disabling the interrupts? (Probably won't do anything different)
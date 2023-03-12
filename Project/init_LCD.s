;initialize GPIO and SPI for LCD
;configure LCD
;/////////////////////////////////////////////////
;BOARD -> LCD
;PA2:clock	->	Clk
;PA3:frame signal	->	CE
;PA4:receive(not used) 
;PA5:transmit	->	Din
;PA6	->	DC
;PA7	->	RST
;/////////////////////////////////////////////////

;definitions
RCGCGPIO			EQU		0x400FE608	
GPIO_PORTA_AFSEL	EQU		0x40004420
GPIO_PORTA_PCTL		EQU		0x4000452C
GPIO_PORTA_AMSEL	EQU		0x40004528
GPIO_PORTA_DEN		EQU		0x4000451C
GPIO_PORTA_DIR		EQU		0x40004400
LCD_DC				EQU		0x40004100
LCD_RST				EQU		0x40004200

RCGCSSI				EQU		0x400FE61C	
SSI0_CR1			EQU		0x40008004
SSI0_CPSR			EQU		0x40008010
SSI0_CR0			EQU		0x40008000
SSI0_CC				EQU		0x40008FC8
SSI0_SR				EQU		0x4000800C
SSI0_DR				EQU		0x40008008

;main Area of init_LCD
			AREA 		init_LCD_area , READONLY, CODE, ALIGN=2
			THUMB
			EXPORT 		init_LCD

init_LCD	PROC
			PUSH 	{R0, R1, R2, R3, LR}
			LDR 	R1, =RCGCGPIO
			LDR		R0, [R1]
			ORR		R0, #0x01					;open PORTA for SPI connection, SSI0
			STR		R0, [R1]
			NOP
			NOP
			NOP
			LDR		R1, =GPIO_PORTA_DIR			;PA2:clock(clk), PA3:frame signal(CE), PA4:receive(not used), PA5:transmit(Din), PA6: DC, PA7:RST
			LDR		R0, [R1]
			ORR		R0, #0xC0					; PA 6,7 output
			STR		R0, [R1]
			LDR		R1, =GPIO_PORTA_DEN			;PA2:clock(clk), PA3:frame signal(CE), PA4:receive(not used), PA5:transmit(Din), PA6: DC, PA7:RST
			LDR		R0, [R1]
			ORR		R0, #0x2C					; PA 2,3,5 digital
			ORR 	R0, #0xC0					; PA 6,7
			STR		R0, [R1]
			LDR		R1, =GPIO_PORTA_AFSEL
			LDR		R0, [R1]
			ORR		R0, #0x2C					; PA 2,3,5 alternate function
			BIC 	R0, #0xC0					; PA 6,7 not alternate function
			STR		R0, [R1]
			LDR		R1, =GPIO_PORTA_PCTL
			LDR		R0, [R1]
			;BIC 	R0, #0xFFF0FF00
			BIC		R0, #0xFF00
			BIC		R0, #0xF00000
			BIC		R0, #0xFF000000
			;BIC	R0, #0x202200
			ORR		R0, #0x200000				; PA 2,3,5 alternate function SSI0, PD6,7 not alternate function
			ORR		R0, #0x2200			
			STR		R0, [R1]
			LDR		R1, =GPIO_PORTA_AMSEL
			LDR		R0, [R1]
			BIC 	R0, #0x2C					; PA 2,3,5 not analog function
			BIC 	R0, #0xC0					; PA 6,7 not analog function
			STR		R0, [R1]
	
			
			LDR		R1, =RCGCSSI
			LDR		R0, [R1]
			ORR		R0, #0x01					; SSI0
			STR		R0, [R1]
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			LDR		R1, =SSI0_CR1			
			LDR		R0, [R1]
			BIC		R0, #0x02					; SSI0 disable
			STR		R0, [R1]
			
			; 16 MHz system clock, at most 4 MHz SPI operation
			LDR		R1, =SSI0_CC
			LDR		R0, [R1]
			BIC		R0, #0x0F					; System clock
			STR		R0, [R1]
			LDR		R1, =SSI0_CPSR
			MOV		R0, #15					; CPSR = 6, 16/6 = 2.66 MHz
			STR		R0, [R1]
			
			
			
			LDR		R1, =SSI0_CR0
			LDR		R0, [R1]
			BIC		R0, #0xFF00					; SCR = 0, 4 MHz serial clock
			BIC 	R0, #0x00000080 			; SSI Serial Clock Phase	
			BIC 	R0, #0x00000040 			; SSI Serial Clock Polarity; if this bit is 1, configure as pull up gpio
			BIC		R0, #0x3F					; Freescale mode
			ORR		R0, #0x7					; 8-bit data
			STR		R0, [R1]
			
			LDR		R1, =SSI0_CR1
			LDR		R0, [R1]
			BIC		R0, #0x04					; Master
			ORR		R0, #0x02					; Enable SSI1
			STR		R0, [R1]
			
			
			LDR		R1, =LCD_DC
			MOV		R0, #0x00					; D/C is low (control)
			STR		R0, [R1]
			
			
			LDR		R1, =LCD_RST
			MOV		R0, #0x00					; active low reset, low (reset the previous changes)
			STR		R0, [R1]
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			LDR		R1, =LCD_RST
			MOV		R0, #0x80					; active low reset, return to high
			STR		R0, [R1]
			
			
			BL 		check_SSI_fifo
			
			LDR		R1, =SSI0_DR
			MOV		R0, #0x21					; additional command mode (H = 1)
			STR		R0, [R1]
			
									
			BL 		check_SSI_fifo
			
			MOV		R0, #0xB4					; VOP 
			STR		R0, [R1]
			
			BL 		check_SSI_fifo
			
			MOV		R0, #0x04					; temperature coefficient 
			STR		R0, [R1]
			
			BL 		check_SSI_fifo
			
			MOV		R0, #0x13					; Voltage Bias System (n=4, 1:48)
			STR		R0, [R1]
			
			BL 		check_SSI_fifo
					
			
			MOV		R0, #0x20					; basic command mode (H = 0) and horizontal addressing mode (V = 0)
			STR		R0, [R1]
			
			BL 		check_SSI_fifo
			
			;LDR		R1, =SSI0_DR
			;MOV		R0, #0x000C					; Normal Mode display
			MOV		R0, #0x08						; To check communication, dark mode
			STR		R0, [R1]
			
			BL 		check_SSI_fifo
			
			LDR		R1, =SSI0_DR
			MOV		R0, #0x0C						; To check communication, dark mode
			BL 		check_SSI_fifo
			STR		R0, [R1]
			
					
			POP		{R0, R1, R2, R3, LR}
			BX		LR
			
check_SSI_fifo		LDR		R2, =SSI0_SR
					LDR		R3, [R2]
					ANDS	R3, #0x10
					BNE		check_SSI_fifo
					BX 		LR
			
			ENDP
			ALIGN
			END
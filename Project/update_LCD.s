; Update number regions of the LCD screen

; Position of the current number is 
	; Y address = bank 1  ->  send 0x41 	
	; X address = column 72  ->  send 0xC8 
; Position of temperature range numbers is 
	; Y address = bank 4  ->  send 0x44 	
	; X address = column 37  ->  send 0xA5
	
LCD_DC		EQU			0x40004100
SSI0_DR		EQU			0x40008008
SSI0_SR		EQU		 	0x4000800C
	
;LABEL DIRECTIVE VALUE COMMENT
				AREA 		up_LCD , DATA, READONLY
				THUMB
					
WRITE_0			DCB			0x3e, 0x51, 0x49, 0x45, 0x3e 
WRITE_1			DCB			0x00, 0x42, 0x7f, 0x40, 0x00
WRITE_2			DCB			0x42, 0x61, 0x51, 0x49, 0x46
WRITE_3			DCB			0x21, 0x41, 0x45, 0x4b, 0x31
WRITE_4			DCB			0x18, 0x14, 0x12, 0x7f, 0x10
WRITE_5			DCB			0x27, 0x45, 0x45, 0x45, 0x39
WRITE_6			DCB			0x3c, 0x4a, 0x49, 0x49, 0x30
WRITE_7			DCB			0x01, 0x71, 0x09, 0x05, 0x03
WRITE_8			DCB			0x36, 0x49, 0x49, 0x49, 0x36
WRITE_9			DCB			0x06, 0x49, 0x49, 0x29, 0x1e

WRITE_DASH		DCB			0x08, 0x08, 0x08, 0x08, 0x08		; -


;main Area of default_LCD
			AREA 		update_LCD_area , READONLY, CODE, ALIGN=2
			THUMB
			EXPORT 		update_LCD
				
update_LCD	PROC
			PUSH	{R0, R1, R2, R3, R4, R5, LR}
			
			MOV		R6, R0
			MOV		R7, R1
			MOV		R8, R2
			
			; WRITE NUMBER
			; Position of the current number is 
			; Y address = bank 1  ->  send 0x41 	
			; X address = column 72  ->  send 0xC8 
			MOV		R4, #0x41					; Y address 1
			MOV		R5, #0xC8					; X address 72
			BL		pos_config
			
			
			MOV		R10, R6
			BL		write_temp
			
			MOV		R11, R10
			BL		write_cont
			
			; WRITE NUMBER
			; Position of temperature range numbers is 
			; Y address = bank 4  ->  send 0x44 	
			; X address = column 37  ->  send 0xA5
			MOV		R4, #0x44					; Y address 4
			MOV		R5, #0xA5					; X address 37
			BL		pos_config
			
			MOV		R10, R7
			BL		write_temp
			
			MOV		R11, R10
			BL		write_cont
			
			LDR		R5, =WRITE_DASH
			BL		write
			
			MOV		R10, R8
			BL		write_temp
			
			MOV		R11, R10
			BL		write_cont
			
			
			
			; exit the function
			POP		{R0, R1, R2, R3, R4, R5, LR}
			BX 		LR
	

; before transmission, check if line is available
chk_SSI_fifo		LDR		R2, =SSI0_SR
					LDR		R3, [R2]
					ANDS	R3, #0x10
					BNE		chk_SSI_fifo
					BX 		LR
					
; write the desired char to the current location					
write		PUSH	{LR}
			; address of the desired char is in R5
			LDR		R1, =SSI0_DR
			MOV		R4, #5
write_r		BL		chk_SSI_fifo
			LDR		R0, [R5], #1
			STR		R0, [R1]
			SUBS	R4, #1
			BNE		write_r
			
			BL		chk_SSI_fifo
			MOV		R0, #0x00
			STR		R0, [R1]
			
			POP		{LR}
			BX		LR	
			
			
; change current position
pos_config	PUSH	{LR}
			; R5: X position, R4: Y position
			LDR		R1, =LCD_DC
			MOV		R0, #0x00					; D/C is low (control)
			STR		R0, [R1]
			
			
			BL		chk_SSI_fifo
			LDR		R1, =SSI0_DR
			MOV		R0, #0x20					; basic command mode (H = 0) and horizontal addressing mode (V = 0)
			STR		R0, [R1]
			
			BL 		chk_SSI_fifo
			
			MOV		R0, R4						; Y address 
			STR		R0, [R1]
			
			BL 		chk_SSI_fifo
			
			MOV		R0, R5						; X address 
			STR		R0, [R1]
			
			BL 		chk_SSI_fifo
			
			LDR		R1, =LCD_DC
			MOV		R0, #0x40					; D/C is high (data)
			STR		R0, [R1]
			
			POP		{LR}
			BX		LR

write_temp	; start of data
			; R10 is the temperature we want to write

			MOV		R11, #0			; quotient of division
			
			CMP		R10, #10
			BLT		write_cont
mod			SUB		R10, #10
			ADD		R11, #1
			CMP		R10, #10
			BGE		mod
			
write_cont	CMP		R11, #0	
			LDREQ	R5, =WRITE_0
			BEQ		write
			
			CMP		R11, #1	
			LDREQ	R5, =WRITE_1
			BEQ		write
			
			CMP		R11, #2	
			LDREQ	R5, =WRITE_2
			BEQ		write
			
			CMP		R11, #3	
			LDREQ	R5, =WRITE_3
			BEQ		write
			
			CMP		R11, #4	
			LDREQ	R5, =WRITE_4
			BEQ		write
			
			CMP		R11, #5	
			LDREQ	R5, =WRITE_5
			BEQ		write
			
			CMP		R11, #6	
			LDREQ	R5, =WRITE_6
			BEQ		write
			
			CMP		R11, #7	
			LDREQ	R5, =WRITE_7
			BEQ		write
			
			CMP		R11, #8	
			LDREQ	R5, =WRITE_8
			BEQ		write

			CMP		R11, #9			
			LDREQ	R5, =WRITE_9
			B		write

			
			ENDP
			ALIGN
			END
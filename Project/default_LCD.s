; design the screen and defines the positions to write current temperature and range
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
				AREA 		sdata , DATA, READONLY
				THUMB
WRITE_T			DCB			0x04, 0x3f, 0x44, 0x40, 0x20		; t
WRITE_E			DCB			0x38, 0x54, 0x54, 0x54, 0x18		; e
WRITE_M			DCB			0x7c, 0x04, 0x18, 0x04, 0x78		; m
WRITE_P			DCB			0x7c, 0x14, 0x14, 0x14, 0x08		; p
WRITE_R			DCB			0x7c, 0x08, 0x04, 0x04, 0x08		; r
WRITE_A			DCB			0x20, 0x54, 0x54, 0x54, 0x78		; a
WRITE_U			DCB			0x3c, 0x40, 0x40, 0x20, 0x7c		; u
WRITE_CAPS_C	DCB			0x3e, 0x41, 0x41, 0x41, 0x22		; C
WRITE_N			DCB			0x7c, 0x08, 0x04, 0x04, 0x78		; n
WRITE_COLON		DCB			0x00, 0x36, 0x36, 0x00, 0x00		; :
WRITE_G			DCB			0x0c, 0x52, 0x52, 0x52, 0x3e		; g
WRITE_CAPS_T	DCB			0x01, 0x01, 0x7f, 0x01, 0x01		; T
WRITE_DASH		DCB			0x08, 0x08, 0x08, 0x08, 0x08		; -

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

;main Area of default_LCD
			AREA 		default_LCD_area , READONLY, CODE, ALIGN=2
			THUMB
			EXPORT 		default_LCD
				
default_LCD	PROC
			PUSH	{R0, R1, R2, R3, R4, R5, LR}
			
			MOV		R4, #0x40					; Y address 0
			MOV		R5, #0x80					; X address 0
			BL		pos_config			
			
			; start of data 
			LDR		R1, =SSI0_DR
			
			; write "Current"
			LDR		R5, =WRITE_CAPS_C
			BL		write
			
			LDR		R5, =WRITE_U
			BL		write
			
			LDR		R5, =WRITE_R
			BL		write
			
			LDR		R5, =WRITE_R
			BL		write
			
			LDR		R5, =WRITE_E
			BL		write
			
			LDR		R5, =WRITE_N
			BL		write
			
			LDR		R5, =WRITE_T
			BL		write
			
			; NEW LINE			
			MOV		R4, #0x41					; Y address 1
			MOV		R5, #0x80					; X address 0
			BL		pos_config			
			
			; start of data 
			LDR		R1, =SSI0_DR
			
			; write "temperature"
			LDR		R5, =WRITE_T
			BL		write	
			
			LDR		R5, =WRITE_E
			BL		write
			
			LDR		R5, =WRITE_M
			BL		write
			
			LDR		R5, =WRITE_P
			BL		write
			
			LDR		R5, =WRITE_E
			BL		write
			
			LDR		R5, =WRITE_R
			BL		write
			
			LDR		R5, =WRITE_A
			BL		write
			
			LDR		R5, =WRITE_T
			BL		write
			
			LDR		R5, =WRITE_U
			BL		write
			
			LDR		R5, =WRITE_R
			BL		write
			
			LDR		R5, =WRITE_E
			BL		write
			
			LDR		R5, =WRITE_COLON
			BL		write
				
			
			
			
			; NEW LINE
			MOV		R4, #0x43					; Y address 3
			MOV		R5, #0x80					; X address 0
			BL		pos_config	
			
			; start of data 
			LDR		R1, =SSI0_DR
			
			; write "Temperature"
			LDR		R5, =WRITE_CAPS_T
			BL		write	
			
			LDR		R5, =WRITE_E
			BL		write
			
			LDR		R5, =WRITE_M
			BL		write
			
			LDR		R5, =WRITE_P
			BL		write
			
			LDR		R5, =WRITE_E
			BL		write
			
			LDR		R5, =WRITE_R
			BL		write
			
			LDR		R5, =WRITE_A
			BL		write
			
			LDR		R5, =WRITE_T
			BL		write
			
			LDR		R5, =WRITE_U
			BL		write
			
			LDR		R5, =WRITE_R
			BL		write
			
			LDR		R5, =WRITE_E
			BL		write
			
			; NEW LINE
			MOV		R4, #0x44					; Y address 4
			MOV		R5, #0x80					; X address 0
			BL		pos_config	
			
			; start of data 
			LDR		R1, =SSI0_DR
			
			LDR		R5, =WRITE_R
			BL		write
			
			LDR		R5, =WRITE_A
			BL		write
			
			LDR		R5, =WRITE_N
			BL		write
			
			LDR		R5, =WRITE_G
			BL		write
			
			LDR		R5, =WRITE_E
			BL		write
			
			LDR		R5, =WRITE_COLON
			BL		write
			
			
			
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

			ENDP
			ALIGN
			END
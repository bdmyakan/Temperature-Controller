;clears LCD screen

LCD_DC		EQU			0x40004100
SSI0_DR		EQU			0x40008008
SSI0_SR		EQU		 	0x4000800C
	
	
;main Area of clear_LCD
			AREA 		clear_LCD_area , READONLY, CODE, ALIGN=2
			THUMB
			EXPORT 		clear_LCD
				
clear_LCD	PROC
			PUSH	{R0, R1, R2, R3, R4, LR}
			
			LDR		R1, =LCD_DC
			MOV		R0, #0x00					; D/C is low (control)
			STR		R0, [R1]
			
			
			BL		chck_SSI_fifo
			LDR		R1, =SSI0_DR
			MOV		R0, #0x20					; basic command mode (H = 0) and horizontal addressing mode (V = 0)
			STR		R0, [R1]
			
			BL 		chck_SSI_fifo
			
			MOV		R0, #0x40					; Y address 0
			STR		R0, [R1]
			
			BL 		chck_SSI_fifo
			
			MOV		R0, #0x80					; X address 0
			STR		R0, [R1]
			
			BL 		chck_SSI_fifo
			
			LDR		R1, =LCD_DC
			MOV		R0, #0x40					; D/C is high (data)
			STR		R0, [R1]			
			
			LDR		R1, =SSI0_DR
			MOV		R0, #0x00	
			;MOV		R2, #672				;number of traverse
			MOV		R4, #672						;number of traverse
			
clear_loop	BL		chck_SSI_fifo
			STR		R0, [R1]
			SUBS	R4, #1
			BNE		clear_loop
			
			; exit the function
			POP		{R0, R1, R2, R3, R4, LR}
			BX 		LR
	

; before transmission, check 
chck_SSI_fifo		LDR		R2, =SSI0_SR
					LDR		R3, [R2]
					ANDS	R3, #0x10
					BNE		chck_SSI_fifo
					BX 		LR
	
			

			ENDP
			ALIGN
			END
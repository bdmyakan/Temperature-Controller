			AREA	|.text|, READONLY, CODE, ALIGN=2
			THUMB
			EXPORT	DELAY100MS
				
DELAY100MS	PROC
	
			MOV32 R10, #200000
			
AGAIN		NOP
			NOP
			SUBS R10, R10, #1
			BNE AGAIN
	
			BX LR
			ENDP
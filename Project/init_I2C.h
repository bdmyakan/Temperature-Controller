void init_I2C(void);
#include "TM4C123GH6PM.h"

void init_I2C(){
	SYSCTL->RCGCI2C |= 0x08;		//open clock for I2C module 3
	// PD0: SCL, PD1:SDA	
	// CSB directly connected to VDDIO
	// SDO: Slave Address LSB
	while(!(SYSCTL->PRI2C & 0x08) ){}		// wait until clock stabilizes

	GPIOD->AFSEL |= 0x03;				//port D 0,1
	
		
		
		
		
		
		
		
	SYSCTL->RCGCGPIO |= 0x08;					// port D
	while(!(SYSCTL->PRGPIO & 0x08) ){}	// wait until clock stabilizes
	

	
}
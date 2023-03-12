#include "TM4C123GH6PM.h"
#include "init.h"
#include "stdio.h"
#include "init_I2C.h"

char slave_address = 0x76;
char sample_trim_address = 0x88;

char slave_memory_address = 0xFA; // temp data address
 
extern void init_LCD(void) ;
extern void clear_LCD(void) ;
extern void default_LCD(void) ;
extern void update_LCD(int temp1, int temp2, int temp3) ;
extern void DELAY100MS(void);
void OutStr(char* b);
char I2C3_Write_Multiple(int slave_address, char slave_memory_address, int count, char* data);
char I2C3_read_Multiple(int slave_address, char slave_memory_address, int count, char* data);

// I2C configuration 
void I2C3_Init (void){
SYSCTL->RCGCGPIO  |= 0x00000008 ;
SYSCTL->RCGCI2C   |= 0x00000008 ;
GPIOD->DEN |= 0x03;
GPIOD->AFSEL |= 0x00000003 ;
GPIOD->PCTL |= 0x00000033 ;
GPIOD->ODR |= 0x00000002 ;
I2C3->MCR  = 0x0010 ;
I2C3->MTPR  = 0x07 ; // clock frequency change by this
}

// To take the temp range value from pot initialize E3 and for led F1

void Pot_Init (void){
	// GPIO E3 initialization
  SYSCTL->RCGCGPIO |= (1<<4);
	SYSCTL->RCGCADC |= (1<<0);
	__asm("NOP");
  __asm("NOP");
  __asm("NOP");
//   while(SYSCTL -> PRGPIO != 3); // wait stabilization
  GPIOE->AFSEL |= (1<<3);
  GPIOE->DEN &= ~(1<<3);    
  GPIOE->AMSEL |= (1<<3); 
  
  // adc initialization
  ADC0->ACTSS &= ~(1<<3); 
  ADC0->EMUX &= ~0xF000;
  ADC0->SSMUX3 = 0;
  ADC0->SSCTL3 |= (1<<1)|(1<<2);
  ADC0->ACTSS |= (1<<3); /* enable ADC0 sequencer 3 */
	
	// E1 pin for transistor gate
	GPIOE->DIR |= 0x02;
	GPIOE->DEN |= 0x02;
    
	/*Iniitialize PF1 PF2 and PF3 as a digital output pin */
  SYSCTL->RCGCGPIO |= 0x20;
  __asm("NOP");
  __asm("NOP");
  __asm("NOP");
  GPIOF->DIR       |= 0x0E;
  GPIOF->DEN       |= 0x0E;

}



// BMP280 configuration write to slave memory
void configureBMP280(void){
char slave_memory_address1 = 0xE0; //reset
char slave_memory_address2 = 0xF4; //ctrl_meas
char slave_memory_address3 = 0xF7; //config
char bmpconfig1[1]; 
char bmpconfig2[1]; 
char bmpconfig3[1];
*bmpconfig1 = 0xB6;
*bmpconfig2 = 0x23;
*bmpconfig3 = 0x00;
	// write the configuration of BMP280 through write
I2C3_Write_Multiple(slave_address,slave_memory_address1,1, bmpconfig1);
I2C3_Write_Multiple(slave_address,slave_memory_address2,1, bmpconfig2);
I2C3_Write_Multiple(slave_address,slave_memory_address3,1, bmpconfig3);
}


//read 256 * 2 bytes of data to a char array given
void read512(int slave_address, char slave_memory_address, int bytes_count, char* data){
		int i = 0;
		for(i=0;i<256;i++){
				I2C3_read_Multiple(slave_address,slave_memory_address,bytes_count, data+2*i);
				if(*(data+2*i) == 0x80 && *(data+2*i+1) == 0x00)
					i=i-1;
		}
}

void LCD(int temp1,int temp3,int temp2){
	int i = 0;
	clear_LCD();				// clears LCD screen	
	default_LCD();			// default image seen in LCD screen
	update_LCD(temp1, temp2, temp3);
	for(i=0;i<10;i++)
			DELAY100MS();

}
int pot_reading[1]; // ADC reading

int main(void)
{	
	char data[512];
	char trimvalues[6];
	int temp, temp1,i;

	unsigned short dig_T1_ushort;
	short dig_T2_short,dig_T3_short;
	
	volatile float temperature;
	volatile float dig_T1,dig_T2,dig_T3;
	volatile float var1,var2,t_fine,T;
	
	init_LCD();					// initialize GPIO PORT A and SSI0 for LCD 
	clear_LCD();				// clears LCD screen
	default_LCD();			// default image seen in LCD screen
	Pot_Init();
	I2C3_Init();

	
	while(1){
		//variable initialization
		temperature = 0;
		pot_reading[0] = 0;
		temp = 0;
		temp1 = 0;
		dig_T1 = 0;
		dig_T2 = 0;
		dig_T3 = 0;
		dig_T1_ushort = 0;
		dig_T2_short = 0;
		dig_T3_short = 0;
		var1 = 0;
		var2 = 0;
		t_fine = 0;
		T = 0;
		

		
		configureBMP280();
		
		// read the temperature and trim values
		read512(slave_address,slave_memory_address,2, data);
		I2C3_read_Multiple(slave_address,sample_trim_address,6, trimvalues);	
		
		// convert the char data to int temp and calculate the average temp 1 is the output temp data
		for(i=0;i<256;i++){
			temp = temp + data[2*i];
			temp1 = temp1 + data[2*i+1];
		}
		temp1 = temp1/256;
		temp = (temp + temp1)*16;
		
		// read the trimming values from char array sample trimvalues
		dig_T1_ushort = dig_T1_ushort + trimvalues[1]*256 + trimvalues[0];
		dig_T2_short = dig_T2_short + trimvalues[3]*256 + trimvalues[2];
		dig_T3_short = dig_T3_short + trimvalues[5]*256 + trimvalues[4];
		
		// change the values to float values to do the calculation below
		temperature = temp;
		dig_T1 = dig_T1_ushort;
		dig_T2 = dig_T2_short;
		dig_T3 = dig_T3_short;
		

		// the calculation algorithm for temperature is immplemented
		var1 = ((temperature)/16384.0f - (dig_T1)/1024.0f) * (dig_T2);
		var2 = (((temperature)/131072.0f - (dig_T1)/8192.0f) * ((temperature)/131072.0f - (dig_T1)/8192.0f)) * (dig_T3);
		t_fine = var1 + var2;
		T = (var1+var2)/5120.0f;
		temp1=T;
	// read the temperature data with respect to pot 
		ADC0->PSSI |= (1<<3); // SS3 start sampling
		while((ADC0->RIS & 0x08) == 0); // wait until the flag is set
		pot_reading[0] = ADC0->SSFIFO3 & 0xFFF;
		ADC0->ISC = 0x08; // SS3 continue sampling
		pot_reading[0] = 40 * (pot_reading[0]) / 0xFFF;  // reading is between 0 and 40 which means our input temperature is between 0 and 40

		
		if((pot_reading[0]+5)<temp1){
			GPIOF->DATA = 0x04; // blue
			GPIOE -> DATA &= ~(0x02); // gate is low
		}
		else if(temp1>=(pot_reading[0]-5) && (pot_reading[0]+5)>=temp1){
			GPIOF->DATA = 0x08; // green
			GPIOE -> DATA &= ~(0x02); // gate is low	
		}
		else{
			GPIOF->DATA = 0x02; // red
			GPIOE -> DATA |= 0x02; // gate is high
		}
		LCD( temp1 , pot_reading[0]+5 , pot_reading[0]-5);


		i=0;
	}
}


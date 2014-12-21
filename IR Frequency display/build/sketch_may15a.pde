#include <phys253.h>        		//***** from 253 template file
#include <LiquidCrystal.h>  		//***** from 253 template file
#include <servo253.h>       		//***** from 253 template file 


void setup()
{
  portMode(0, INPUT) ;      	 	//***** from 253 template file
  portMode(1, INPUT) ;      	   	//***** from 253 template file
  RCServo0.attach(RCServo0Output) ;	//***** from 253 template file
  RCServo1.attach(RCServo1Output) ;	//***** from 253 template file
  RCServo2.attach(RCServo2Output) ;	//***** from 253 template file



}


void loop()
{
    
  LCD.clear();
  LCD.home();
  
long startTime = micros();

for(int i = 0; i <= 100; i++) {
  while(digitalRead(0) != HIGH) {};
  while(digitalRead(0) != LOW) {};
}

long endTime = micros();

int Frequency = 100*1000000 / (endTime - startTime);

LCD.print(Frequency);
delay(1000);
  
  
}

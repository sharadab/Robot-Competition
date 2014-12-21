#include <phys253.h>        		//***** from 253 template file
#include <LiquidCrystal.h>  		//***** from 253 template file
#include <servo253.h>       		//***** from 253 template file 

 #include "WProgram.h"
#include <HardwareSerial.h>
void setup();
void loop();
void setup()
{
  portMode(0, INPUT) ;      	 	//***** from 253 template file
  portMode(1, INPUT) ;      	   	//***** from 253 template file
  RCServo0.attach(RCServo0Output) ;	//***** from 253 template file
  RCServo1.attach(RCServo1Output) ;	//***** from 253 template file
  RCServo2.attach(RCServo2Output) ;	//***** from 253 template file
}

void loop() {
  while(!stopbutton()) {
  int number = knob(6);
  
  int leftIRSmall = analogRead(3);
  int rightIRSmall = analogRead(2);
  int leftIRBig = analogRead(4);
  int rightIRBig = analogRead(1);
  
  LCD.clear();
  LCD.home();
  LCD.print(rightIRBig);
  LCD.print(" ");
  LCD.print(leftIRBig);
  LCD.setCursor(0,1);
  LCD.print(rightIRSmall);
  LCD.print(" ");
  LCD.print(leftIRSmall);
  delay(50);
  
  motor.speed(0, number);
  motor.speed(3, number);
  }
}
  


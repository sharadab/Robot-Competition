#include <phys253.h>        		//***** from 253 template file
#include <LiquidCrystal.h>  		//***** from 253 template file
#include <servo253.h>    

#include "WProgram.h"
#include <HardwareSerial.h>
void setup();
void loop();
void pickup(int artifactNum);
void setup(){
  portMode(0, INPUT) ;      	 	//***** from 253 template file
  portMode(1, INPUT) ;      	   	//***** from 253 template file
  RCServo0.attach(RCServo0Output) ;	//***** from 253 template file
  RCServo1.attach(RCServo1Output) ;	//***** from 253 template file
  RCServo2.attach(RCServo2Output) ;	//***** from 253 template file
}


void loop(){
  int artifactNumber;
  if(knob(6)<=250){ artifactNumber = 1;}
  if((knob(6)>250) && (knob(6)<=500)){ artifactNumber = 2;}
  if((knob(6)>500) && (knob(6)<=750)){ artifactNumber = 3;}
  if(knob(6)>750){ artifactNumber = 4;}
  LCD.clear();
  LCD.home();
  LCD.print("AN:");
  LCD.print(artifactNumber);
  pickup(artifactNumber);
  delay(1000);
}


void pickup(int artifactNum){
  RCServo1.write(180); //close arms
  delay(2000);
  RCServo2.write(180); //raise collector
  delay(2000);
  if(artifactNum < 4){ //if we're not picking up the last artifact, reset arms and collector
    RCServo2.write(0); //reset collector position
    delay(2000);
    RCServo1.write(0); //open arms
  }
}


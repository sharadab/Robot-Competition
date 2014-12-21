#include <phys253.h>        		//***** from 253 template file
#include <LiquidCrystal.h>  		//***** from 253 template file
#include <servo253.h>       		//***** from 253 template file 


//Constants for the very beginning
 #include "WProgram.h"
#include <HardwareSerial.h>
void setup();
void loop();
void IRFollow();
int getMotorSpeedIR(int difference, int lastDifference, int kp, int kd);
int thresh = 200; //above this is black, below this is white
 int initialSpeed;
 int difference = 0;
 int loopnumber = 0;

 void setup()
{
  portMode(0, INPUT) ;      	 	//***** from 253 template file
  portMode(1, INPUT) ;      	   	//***** from 253 template file
  RCServo0.attach(RCServo0Output) ;	//***** from 253 template file
  RCServo1.attach(RCServo1Output) ;	//***** from 253 template file
  RCServo2.attach(RCServo2Output) ;	//***** from 253 template file
  
   LCD.clear(); LCD.home();
  LCD.print("Setup!");
  delay(3000);
 
 
 while(!startbutton()) {
   initialSpeed = knob(6);
   LCD.clear(); LCD.home();
   LCD.print("Init Speed:"); LCD.print(initialSpeed);
   LCD.setCursor(0,1); LCD.print("Press Start");
   delay(5);
 }
 
 LCD.clear(); LCD.home();
 LCD.print("Setup done!");
 LCD.setCursor(0,1); LCD.print("Press Stop");
 while(!stopbutton());
}

//***********************************************************************
//MAIN LOOP
void loop() {
  
  //Otherwise start IR following  
  IRFollow();
}

//******************************************************************************
//FOLLOW IR

void IRFollow() {
  
  int leftIRBig = analogRead(4);
  int leftIRSmall = analogRead(3);
  int rightIRBig = analogRead(1);
  int rightIRSmall = analogRead(2);
  
  int kp = knob(6);
  int kd = knob(7);
  
  long startTime = millis();
  
  int sumOfDifferences = 0;
  
  int lastDifference = difference;
  
  int irkp = knob(6); //assuming IR following only needs kp
 
  
  //averages over every 1s
  while (millis() < startTime + 1000.0){
    
   //Difference in big gain while small gain is unreadable
   if(leftIRSmall <= 80 && rightIRSmall <= 30) {
     difference = leftIRBig - rightIRBig;
   }
  
   else {
   //Otherwise small gain difference
   difference = leftIRSmall - rightIRSmall;
   }
  
  sumOfDifferences = sumOfDifferences + difference;
  }
  
  int averageDifference = sumOfDifferences / 1000;
  
  
  int motorControlSpeed = getMotorSpeedIR(averageDifference, lastDifference, kp, kd);
  
  int rightMotor = initialSpeed + motorControlSpeed;
  int leftMotor = initialSpeed - motorControlSpeed;
  
  motor.speed(0, rightMotor);
  motor.speed(3, leftMotor);
  
  //prints needed values
  if(loopnumber == 30) {
  LCD.clear();
    LCD.home();
    LCD.print(averageDifference); LCD.print(" ");
    LCD.print("R"); LCD.print(rightIRBig); LCD.print(" ");
    LCD.print("L"); LCD.print(leftIRBig);
    LCD.setCursor(0,1);
    LCD.print("R"); LCD.print(rightIRSmall); LCD.print(" ");
    LCD.print("L"); LCD.print(leftIRSmall); LCD.print(" ");
    delay(5); 
    loopnumber = 0;
  }
  loopnumber++;
  
  //if(armSwitch == LOW) {pickUpArtefact();}
}

//**********************************************************
//PID CONTROL FOR TAPE AND IR
int getMotorSpeedIR(int difference, int lastDifference, int kp, int kd) {
  int Proportional = kp*error;
  int Derivative = (difference -lastDifference)*kd;
  int motorControlSpeed = Proportional + Derivative;
  return motorControlSpeed;
}



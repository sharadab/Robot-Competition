#include <phys253.h>        		//***** from 253 template file
#include <LiquidCrystal.h>  		//***** from 253 template file
#include <servo253.h>       		//***** from 253 template file 


//Constants for the very beginning
 int thresh = 200; //above this is black, below this is white
 int error = 0;
 int recentError = 0;
 int time = 0;
 int lastTime = 1;
 int initialSpeed = 500;
 int numberOfPresses = 0;

 void setup()
{
  portMode(0, INPUT) ;      	 	//***** from 253 template file
  portMode(1, INPUT) ;      	   	//***** from 253 template file
  RCServo0.attach(RCServo0Output) ;	//***** from 253 template file
  RCServo1.attach(RCServo1Output) ;	//***** from 253 template file
  RCServo2.attach(RCServo2Output) ;	//***** from 253 template file
}

void loop() {
  int leftIRBig = analogRead(4);
  int leftIRSmall = analogRead(3);
  int rightIRBig = analogRead(1);
  int rightIRSmall = analogRead(2);
  
  //Otherwise start IR following  
  IRFollow(leftIRBig, rightIRBig, leftIRSmall, rightIRSmall);
}

void IRFollow(int leftIRBig, int rightIRBig, int leftIRSmall, int rightIRSmall) {
   //using the averaging method for 100 loops
  int sumOfDifferences = 0;
  int difference;
  int irkp = knob(6); //assuming IR following only needs kp
  //int i = 0;
  
  for(int i = 0; i < 100; i++) { //averages over every 100 loops
  
  //Difference in big gain while small gain is unreadable
  if(leftIRSmall <= 50 && rightIRSmall <= 50) {
    difference = leftIRBig - rightIRBig;
  }
  else {
  //Otherwise small gain difference
  difference = leftIRSmall - rightIRSmall;
  }
  
  sumOfDifferences = sumOfDifferences + difference;
  }
  
  int averageDifference = sumOfDifferences / 100;
  
  //Setting error = averageDIfference, recentError = 0, lastTime = 1, kp= irkp, kd = 0. 
  //The constants ensure no Deriv is calculated.
  int motorControlSpeed = getMotorSpeed(averageDifference, 0, 1, irkp, 0);
  
  int rightMotor = initialSpeed + motorControlSpeed;
  int leftMotor = initialSpeed - motorControlSpeed;
  
  motor.speed(0, rightMotor);
  motor.speed(3, leftMotor);
  
  //prints needed values
  LCD.clear();
    LCD.home();
    LCD.print(averageDifference);
    LCD.print(" ");
    LCD.print("RB:");
    LCD.print(rightIRBig);
    LCD.print(" ");
    LCD.print("LB:");
    LCD.print(leftIRBig);
    LCD.setCursor(0,1);
    LCD.print(irkp);
    LCD.print(" ");
    LCD.print("RS:");
    LCD.print(rightIRSmall);
    LCD.print(" ");
    LCD.print("LS:");
    LCD.print(leftIRSmall);
    delay(5);
}

//**********************************************************
//PID CONTROL FOR TAPE AND IR
int getMotorSpeed(int error, int recentError, int lastTime, int kp, int kd) {
  int Proportional = kp*error;
  int Derivative = kd*(error-recentError)/(time+lastTime);
  int motorControlSpeed = Proportional + Derivative;
  return motorControlSpeed;
}

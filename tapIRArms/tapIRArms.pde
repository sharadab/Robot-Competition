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
 int armSwitch = 0;
 int artefactNumber = 0;

 void setup(){
  portMode(0, INPUT) ;      	 	//***** from 253 template file
  portMode(1, INPUT) ;      	   	//***** from 253 template file
  RCServo0.attach(RCServo0Output) ;	//***** from 253 template file
  RCServo1.attach(RCServo1Output) ;	//***** from 253 template file
  RCServo2.attach(RCServo2Output) ;	//***** from 253 template file
  }

 void loop() {
  LCD. setCursor(0,0);
  
  //something for setup
  
  int leftSensor = analogRead(0);
  int rightSensor = analogRead(2);
  
  int leftIRBig = analogRead(1);
  int leftIRSmall = analogRead(3);
  int rightIRBig = analogRead(4);
  int rightIRSmall = analogRead(5);

  //As long as both the large IR gains are 0, you follow tape  
  while(leftIRBig == 0 && rightIRBig == 0) {
    tapeFollow(leftSensor, rightSensor); 
  }
  
  //Otherwise start IR following  
  IRFollow(leftIRBig, rightIRBig, leftIRSmall, rightIRSmall);
  
  if(digitalRead(armSwitch) == HIGH) {pickUpArtefact();}
 }

//*********************************************************************
//TAPE FOLLOWING
void tapeFollow(int leftSensor, int rightSensor) {
  
  //Initializing lastError to error at the beginning of each loop
  int lastError = error;
  
  //Finds the error from QRDs
  if(leftSensor > thresh && rightSensor > thresh) { error = 0;}
  if(leftSensor > thresh && rightSensor < thresh) {error = 1;}
  if(leftSensor < thresh && rightSensor > thresh) {error = -1;}
  if(leftSensor < thresh && rightSensor < thresh) {
    if(lastError > 0) {error = 5;}
    if(lastError < 0) {error = -5;}
  }
  
  //This is to use in Derivative error
  if(error != lastError) {
    recentError = lastError;
    time = lastTime;
    lastTime = 1;
  }
  
  //Finds motor control speed for rear wheels, sets it. 
  int motorControlSpeed = getMotorSpeed(error, recentError, lastTime, kp, kd);
  int rightMotor = initialSpeed + motorControlSpeed;
  int leftMotor = initialSpeed - motorControlSpeed;
  
  motor.speed(0, rightMotor);
  motor.speed(3, leftMotor);
  
  //Prints out things on LCD
    LCD.clear();
    LCD.home();
    LCD.print(error);
    LCD.print(" ");
    LCD.print(rightSensor);
    LCD.print(" ");
    LCD.print(leftSensor);
    LCD.print(" ");
    LCD.setCursor(0,1);
    LCD.print(kp);
    LCD.print(" ");
    LCD.print(kd);
    LCD.setCursor(0,2);
    LCD.print(rightMotor);
    LCD.print(" ");
    LCD.print(leftMotor);
    delay(5);

  lastTime = lastTime + 1;
}

//*************************************************
//IR FOLLOWING 
void IRFollow(int leftIRBig, int rightIRBig, int leftIRSmall, int rightIRSmall) {
  //changing rightIRBig continuously
  rightIRBig = rightIRBIg - 8*rightIRBig + 6200;
  
  //change rightIRSmall continuously
  rightIRSmall = rightIRSmall - 6.9*rightIRSmall + 5000;  
  //then same code!
  
  long startTime = millis();
  
  int sumOfDifferences = 0;
  int difference;
  
  int irkp = knob(6); //assuming IR following only needs kp

  //averages over every 5s
  while (millis < startTime + 1000.0){
    
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
  
  int averageDifference = sumOfDifferences / 1000;
  
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

//**************************************
//MENU CONTROL
//need to press stop to open this menu. then press start to shuffle through.
void settingsMenu() {
  if(startbutton()) {
    
   numberOfPresses++;
   
   if(numberOfPresses == 1) {
     LCD.print("Kp:");
     int kp = knob(7);
     LCD.println(kp);
   }
   if(numberOfPresses == 2) {
    LCD.print("Kd:");
     int kp = knob(6);
     LCD.println(kd); 
   }
   if(numberOfPresses == 3) {
     LCD.print("IR Kp:");
     int irkp = knob(6);
     LCD.println(irkp);
   }
  }
}

//**************************
//ARTEFACT COLLECTION
void pickUpArtefact() {
  RCServo0.write(180); //close arms
  delay(2000);
  RCServo2.write(180); //raise collector
  delay(2000);
  artefactNumber++;
  if(artefactNumber < 4){ //if we're not picking up the last artifact, reset arms and collector
    RCServo2.write(0); //reset collector position
    delay(2000);
    RCServo1.write(0); //open arms
  }
  else {lastArtefact();}
}

//******************************************
//LAST ARTEFACT


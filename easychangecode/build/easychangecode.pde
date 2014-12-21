
#include <phys253.h>        		//***** from 253 template file
#include <LiquidCrystal.h>  		//***** from 253 template file
#include <servo253.h>       		//***** from 253 template file 


//Constants for the very beginning
 int thresh; //above this is black, below this is white
 int error = 0;
 int recentError = 0;
 int time = 0;
 int lastTime = 1;
 int kp;
 int kd;
 int initialSpeed;
 int loopnumber = 0;
 int artefactNumber = 0;
 int armSwitch = 0;
 int openAngleArms = 70; //90
 int openAngleFlip = 180; //180
 int closeAngleArms = 170; //180
 int closeAngleFlip = 0; //0
 int turnSpeed = 100;

//**************************************
//SETUP
 void setup()
{
  portMode(0, INPUT) ;      	 	//***** from 253 template file
  portMode(1, INPUT) ;      	   	//***** from 253 template file
  RCServo0.attach(RCServo0Output) ;	//***** from 253 template file
  RCServo1.attach(RCServo1Output) ;	//***** from 253 template file
  RCServo2.attach(RCServo2Output) ;	//***** from 253 template file
  
  //setting up
  
  RCServo0.write(openAngleArms);
  RCServo1 .write(openAngleFlip); 
  
  LCD.clear(); LCD.home();
  LCD.print("Setup!");
  delay(3000);
 
   while(!stopbutton()) {
   thresh = knob(6);
   LCD.clear(); LCD.home();
   LCD.print("thresh:"); LCD.print(thresh);
   LCD.setCursor(0,1); LCD.print("Press Stop");
   delay(5);
 }
 /*
 while(!stopbutton()) {
   kd = knob(6);
   LCD.clear(); LCD.home();
   LCD.print("Kd:"); LCD.print(kd);
   LCD.setCursor(0,1); LCD.print("Press Stop");
   delay(5);
 }*/
 
 while(!startbutton()) {
   initialSpeed = knob(6);
   LCD.clear(); LCD.home();
   LCD.print("Init Speed:"); LCD.print(initialSpeed);
   LCD.setCursor(0,1); LCD.print("Press Start");
   delay(5);
 }
 
/* while(!stopbutton()) {
  irkp = knob(6);
  LCD.clear(); LCD.home();
  LCD.print("IR Kp:"); LCD.print(irkp);
  LCD.setCursor(0,1); LCD.print("Press Stop");
  delay(5);
 }*/
 
 
 /*LCD.clear(); LCD.home();
 LCD.print("Setup done!");
 LCD.setCursor(0,1); LCD.print("Press Stop");
 while(!stopbutton()); */
}

//***************************************************
//LOOP
void loop() {
  tapeFollow();
}

//************************************************
//FOLLOW TAPE
void tapeFollow() {

  int leftSensor = analogRead(5);
  int rightSensor = analogRead(0);
  int kp = knob(6);
  int kd = knob(7);
  
  
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
  int Proportional = kp*error;
  int Derivative = int(kd*(error-recentError)/(time+lastTime));
  int motorControlSpeed = Proportional + Derivative;
  
  int rightMotor = initialSpeed + motorControlSpeed;
  int leftMotor = initialSpeed - motorControlSpeed;
  
  if(rightMotor > 1024) {rightMotor = 1023;}
  if(leftMotor > 1024) {leftMotor = 1023;}
  
  
  motor.speed(0, rightMotor);
  motor.speed(3, leftMotor);
  
  if(loopnumber == 300) {
  //Prints out things on LCD
    LCD.clear();
    LCD.home();
    LCD.print("E:"); LCD.print(error); LCD.print(" ");
    LCD.print("R:"); LCD.print(rightSensor); LCD.print(" ");
    LCD.print("L:"); LCD.print(leftSensor); LCD.print(" ");
    LCD.setCursor(0,1);
    LCD.print("Kp:"); LCD.print(kp); LCD.print(" ");
    LCD.print("Kd:"); LCD.print(kd); LCD.print(" ");
    LCD.print(initialSpeed);
    delay(5);
    loopnumber = 0;
  }
 loopnumber++;
 lastTime = lastTime + 1; 
 
 if(digitalRead(armSwitch) == LOW) {pickUpArtefact();}
}


//*****************************************************************
//DO A TURN
void doATurn() {
  //just the tape turn. will turn until sensor readings are both on tape.
    boolean turnComplete = 0;
    LCD.clear(); LCD.home(); LCD.print("turning"); LCD.print(" "); delay(5);
  
    long startTime = millis();
    while(millis() < startTime + 500.0) {
      motor.speed(0,turnSpeed);
      motor.speed(3,0);
    }
  
    while(turnComplete == 0) {
      int leftSensor = analogRead(5);
      int rightSensor = analogRead(0);
      int thresh = knob(6);
      
      if(leftSensor < thresh && rightSensor < thresh) {
        motor.speed(0,turnSpeed);
        motor.speed(3, 0);
        LCD.clear(); LCD.home(); LCD.print("finding tape"); 
        LCD.setCursor(0,1);LCD.print(rightSensor); LCD.print(" "); LCD.print(leftSensor); LCD.print(" "); LCD.print(thresh); delay(5);
      }
      
      if(leftSensor > thresh || rightSensor > thresh) {
          tapeFollow();
          LCD.clear(); LCD.home(); LCD.print("tape");
          LCD.setCursor(0,1); LCD.print(rightSensor); LCD.print(" "); LCD.print(leftSensor);
          turnComplete = 1; }
    }
    }

//*************************************************************************
//ARMS CODE
void pickUpArtefact() {
  motor.speed(3,0);
  motor.speed(0,0);
  delay(1000);
  
  RCServo0.write(closeAngleArms); //close arms
  delay(2000);
  RCServo0.write(openAngleArms);
  delay(1000);
  RCServo1.write(closeAngleFlip); //raise collector
  delay(2000);
  RCServo1.write(openAngleFlip);
  delay(2000);
  RCServo1.write(closeAngleFlip);
  delay(2000);
  
  artefactNumber++;
  LCD.clear(); LCD.home(); LCD.print("artefact"); LCD.print(artefactNumber);
  
   if(artefactNumber < 3){ //if we're not picking up the last artefact, reset arms and collector
    RCServo1.write(openAngleFlip); //reset collector position
    delay(2000);
   //RCServo0.write(openAngleArms); //open arms
    tapeFollow(); 
   LCD.clear(); LCD.home(); LCD.print("tape"); 
  }
  
  if(artefactNumber == 3) {
    RCServo0.write(closeAngleArms);
    //RCServo2.write(closeAngleFlip);
    doATurn();
    LCD.clear(); LCD.home(); LCD.print("turning");
  }
  
}

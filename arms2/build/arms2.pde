//Libraries
  #include <phys253.h>          //   ***** from 253 template file
  #include <LiquidCrystal.h>    //   ***** from 253 template file
  #include <Servo253.h>         //   ***** from 253 template file

//Joshua folk can llala my 

    int artefactNumber = 0;
    int armSwitch = 0;
    int openAngleArms = 70; //90
    int openAngleFlip = 180; //180
    int closeAngleArms = 170; //180
    int closeAngleFlip = 0; //0
    int shakeAngle1 = 90;
    int shakeAngle2 = 10;
    int mode = 1;



void setup()
{
  portMode(0, INPUT) ;      //   ***** from 253 template file
  portMode(1, INPUT) ;      //   ***** from 253 template file
  
  
  RCServo0.attach(RCServo0Output) ;    // attaching the digital inputs to the RC servo pins on the board.  
  RCServo1.attach(RCServo1Output) ;
  RCServo2.attach(RCServo2Output) ;
  
  
  RCServo0.write(openAngleArms);
  RCServo1.write(openAngleFlip);
 
  LCD.clear(); LCD.home(); LCD.print("Go!");
}

void loop() {
    if(digitalRead(armSwitch) == LOW) {pickUpArtefact();}
}

void pickUpArtefact() {
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
 
 /* RCServo1.write(shakeAngle1);
  delay(1000);
  RCServo1.write(shakeAngle2);
  delay(1000);
  RCServo1.write(shakeAngle1);
  delay(1000);
  RCServo1.write(shakeAngle2);
  delay(1000);
 */
 
 /* long startTime = millis();
  while(millis() < startTime + 500) {
  motor.speed(0,100);
  motor.speed(3,-100);
  }
  while(millis() < startTime + 1000) {
  motor.speed(0,-100);
  motor.speed(3,100);
  } */
  
  artefactNumber++;
  LCD.clear(); LCD.home(); LCD.print("artefact"); LCD.print(artefactNumber);
  
   if(artefactNumber < 3){ //if we're not picking up the last artefact, reset arms and collector
    RCServo1.write(openAngleFlip); //reset collector position
    delay(2000);
    //RCServo0.write(openAngleArms); //open arms
    //tapeFollow(); 
   LCD.clear(); LCD.home(); LCD.print("tape"); 
  }
  
  if(mode == 1 && artefactNumber == 3) {
   // RCServo0.write(closeAngleArms);
    //RCServo2.write(closeAngleFlip);
    //doATurn();
    LCD.clear(); LCD.home(); LCD.print("turning");
  }
  
  
  if(mode == 2) {
    if(artefactNumber == 3) {
      RCServo1.write(openAngleFlip);
      RCServo0.write(openAngleArms);
      //IRFollow();
      LCD.clear(); LCD.home(); LCD.print("IR");
    }
    if(artefactNumber == 4) {
      RCServo1.write(closeAngleFlip);
      RCServo0.write(closeAngleArms);
      //reverseIRFollow();
      LCD.clear(); LCD.home(); LCD.print("rev IR");
  }
    

  }
}

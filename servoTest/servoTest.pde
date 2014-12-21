 #include <phys253.h>          //   ***** from 253 template file
  #include <LiquidCrystal.h>    //   ***** from 253 template file
  #include <Servo253.h>         //   ***** from 253 template file


void setup()
{
  portMode(0, INPUT) ;      //   ***** from 253 template file
  portMode(1, INPUT) ;      //   ***** from 253 template file
  
  
  RCServo0.attach(RCServo0Output) ;    // attaching the digital inputs to the RC servo pins on the board.  
  RCServo1.attach(RCServo1Output) ;
  RCServo2.attach(RCServo2Output) ;
  
 
  LCD.clear(); LCD.home(); LCD.print("Go!");
}

void loop() {
  int angle = knob(6)/5.5;
  RCServo0.write(angle);
  LCD.clear(); LCD.home(); LCD.print(angle);
  delay(5);
}

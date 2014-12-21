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
  int motorControlSpeed = getMotorSpeed(error, recentError, lastTime);
  int rightMotor = initialSpeed + motorControlSpeed;
  int leftMotor = initialSpeed - motorControlSpeed;
  
  motor.speed(0, rightMotor);
  motor.speed(3, leftMotor);
  
  //Prints out things on LCD
    LCD.clear();
    LCD.home();
    LCD.print(error);
    LCD.print(" ");
    LCD.print(rightMotor);
    LCD.print(" ");
    LCD.print(leftMotor);
    LCD.print(" ");
    delay(5);

lastTime = lastTime + 1;
}

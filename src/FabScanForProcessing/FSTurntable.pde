  
  
public class FSTurntable
{
  
  
  public int DIRECTION_CCW = 0;
  public int DIRECTION_CW = 1;  
  
  private PVector _rotation;
  private float degreesPerStep = 360.0f/200.0f/16.0f; //the size of a microstep
  private float turntableStepSize = 16*degreesPerStep;//GOOD RESOLUTION
  int direction = DIRECTION_CW;
  
  public FSTurntable()
  {
    _rotation = new PVector();
  }
  
  
  public PVector getRotation()
  {
    return _rotation;
  }
  
  
  public float getStepSize()
  {
    return turntableStepSize;
  }
  
  
  //disables the stepper motor that moves the turntable
  public void disableStepperMotor()
  {
  }
  
  //enables the stepper motor that moves the turntable
  public void enableStepperMotor()
  {
  }
  
  public void setDirection(int direction)
  {
    //this->selectStepper();
    //direction = d;
    //char c = (d==FS_DIRECTION_CW)?MC_SET_DIRECTION_CW:MC_SET_DIRECTION_CCW;
    //FSController::getInstance()->serial->writeChar(c);
    
    if(direction==DIRECTION_CCW)//CCW
    {
    }
    else if(direction==DIRECTION_CW)//CW
    {
    }
  }
  
  void turnNumberOfSteps(int steps)
{
    //unsigned char size = steps/256*2;
    //char c[size];
    //unsigned int s = steps;
    //for(unsigned int i=0; i<=steps/256; i++){
    //    c[2*i]=MC_PERFORM_STEP;
    //    if(s<256){
    //        c[2*i+1]=s%256;
    //    }else{
    //        c[2*i+1]=255;
    //        s-=255;
    //    }
    //}
    //this->selectStepper();
    //FSController::getInstance()->serial->writeChars(c);
    
}
  
  public void turnNumberOfDegrees(float degrees)
  {
    int steps = (int)(degrees/degreesPerStep);
    
    if(direction==DIRECTION_CW){
      _rotation.y -= degrees;
    }else if(direction==DIRECTION_CCW){
      _rotation.y += degrees;
    }
    
    turnNumberOfSteps(steps);
  }
  
}


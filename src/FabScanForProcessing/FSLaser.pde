public class FSLaser
{
  private PVector _laserPointPosition;
  
  public FSLaser()
  {
    _laserPointPosition = new PVector(0,0,0);
  }
  
  
  public PVector getPosition()
  {
    PVector result = new PVector(FSConfiguration.LASER_POS_X,FSConfiguration.LASER_POS_Y,FSConfiguration.LASER_POS_Z);
    return result;
  }
  
  
  //disables the stepper motor that moves the laser
  public void disableStepperMotor()
  {
  }
  
  //enables the stepper motor that moves the laser
  public void enableStepperMotor()
  {
  }
  
  //turns on the laser. Returns true if everything worked.
  public boolean turnOn()
  {
    return true;
  }
  
  //turns off the laser. Returns true if everything worked.
  public boolean turnOff()
  {
    return true;
  }
  
  void setLaserPointPosition(PVector p)
{
    _laserPointPosition = p;
    //double b = position.x - laserPointPosition.x;
    //double a = position.z - laserPointPosition.z;
    //rotation.y = atan(b/a)*180.0/M_PI;
    //FSController::getInstance()->controlPanel->setLaserAngleText(rotation.y);
}
 
  PVector getLaserPointPosition()
  {
       return _laserPointPosition;
    
  }
  
}

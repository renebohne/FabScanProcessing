public class FSLaser
{
  private PVector _laserPointPosition;
  private FSController controller;

  public FSLaser(FSController c)
  {
    controller = c;
    _laserPointPosition = new PVector(0, 0, 0);
  }


  public PVector getPosition()
  {
    PVector result = new PVector(FSConfiguration.LASER_POS_X, FSConfiguration.LASER_POS_Y, FSConfiguration.LASER_POS_Z);
    return result;
  }


  //disables the stepper motor that moves the laser
  public void disableStepperMotor()
  {
    controller.serial.writeInt(212);//MC_SELECT_STEPPER
    controller.serial.writeInt(11);//MC_LASER_STEPPER
    controller.serial.writeInt(206);//MC_TURN_STEPPER_OFF  
  }

  //enables the stepper motor that moves the laser
  public void enableStepperMotor()
  {
    controller.serial.writeInt(212);//MC_SELECT_STEPPER
    controller.serial.writeInt(11);//MC_LASER_STEPPER
    controller.serial.writeInt(205);//MC_TURN_STEPPER_ON
  }

  //turns on the laser
  public void turnOn()
  {
    controller.serial.writeInt(201);//MC_TURN_LASER_ON
    
  }

  //turns off the laser
  public void turnOff()
  {
    controller.serial.writeInt(200);//MC_TURN_LASER_OFF
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


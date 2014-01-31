

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
    controller.serial.writeInt(212);//MC_SELECT_STEPPER
    controller.serial.writeInt(10);//MC_TURNTABLE_STEPPER
    controller.serial.writeInt(206);//MC_TURN_STEPPER_OFF
  }

  //enables the stepper motor that moves the turntable
  public void enableStepperMotor()
  {
    controller.serial.writeInt(212);//MC_SELECT_STEPPER
    controller.serial.writeInt(10);//MC_TURNTABLE_STEPPER
    controller.serial.writeInt(205);//MC_TURN_STEPPER_ON
  }

  public void setDirection(int direction)
  {
    controller.serial.writeInt(212);//MC_SELECT_STEPPER
    controller.serial.writeInt(10);//MC_TURNTABLE_STEPPER

    if (direction==DIRECTION_CCW)//CCW
    {
      controller.serial.writeInt(204);//MC_SET_DIRECTION_CCW
    }
    else if (direction==DIRECTION_CW)//CW
    {
      controller.serial.writeInt(203);//MC_SET_DIRECTION_CW
    }
  }

  void turnNumberOfSteps(int steps)
  {
    controller.serial.writeInt(212);//MC_SELECT_STEPPER
    controller.serial.writeInt(10);//MC_TURNTABLE_STEPPER

    int size = steps/256*2;

    for (int i=0; i<=steps/256; i++)
    {
      controller.serial.writeInt(202);//MC_PERFORM_STEP

      //second byte of the message: how many steps?
      if (steps<256)
      {
        controller.serial.writeInt(steps%256);
      }
      else
      {
        controller.serial.writeInt(255);
        steps -= 255;
      }
    }
  }

  public void turnNumberOfDegrees(float degrees)
  {
    int steps = (int)(degrees/degreesPerStep);

    if (direction==DIRECTION_CW) {
      _rotation.y -= degrees;
    }
    else if (direction==DIRECTION_CCW) {
      _rotation.y += degrees;
    }

    turnNumberOfSteps(steps);
  }
}


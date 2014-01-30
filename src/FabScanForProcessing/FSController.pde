public class FSController
{
  FSWebcam webcam;
  FSLaser laser;
  FSTurntable turntable;
  FSVision vision;
  FSModel model;

  boolean scanning = false;
  boolean meshComputed = false;

  //all in degrees; (only when stepper is attached to laser)
  double laserSwipeMin = 30.0; //18
  double laserSwipeMax = 45.0; //50

  int yDpi = 1;//1 for Best and Good resolution, 5 for Normal resolution, 10 for poor 

    public FSController()
  {
    webcam = new FSWebcam();
    laser = new FSLaser();
    turntable = new FSTurntable();
    vision = new FSVision();
    model = new FSModel();
  }

  public boolean detectLaserLine()
  {
    return true;
  }

  public void scanThread()
  {

    //check if the webcam is available
    if (!webcam.isAvailable())
    {
      println("ERROR: webcam is not available!");
      return;
    }

    if (!detectLaserLine())
    {
      println("ERROR: laser line was not detected!");
    }

    laser.disableStepperMotor();//disable the stepper motor that moves the laser

      scanning = true;//start scanning; if false, scan stops
    float stepDegrees = turntable.getStepSize();

    laser.turnOn();

    turntable.setDirection(turntable.DIRECTION_CCW);
    turntable.enableStepperMotor();

    for (float i=0.0f; i<360.0 && scanning == true; i+= stepDegrees)
    {
      //take picture with laser switched off
      laser.turnOff();
      delay(200);//NOT PERFECT...
      PImage laserOffImage = webcam.getFrame();
      laserOffImage.resize(1280, 960);

      //take picture with laser switched on
      laser.turnOn();
      delay(200);//NOT PERFECT...
      PImage laserOnImage = webcam.getFrame();
      laserOnImage.resize(1280, 960);

      //here the magic happens
      vision.putPointsFromFrameToCloud(laserOffImage, laserOnImage, yDpi, 0, this);
      
      turntable.turnNumberOfDegrees(stepDegrees);
      delay(  300+(int)stepDegrees*100);//NOT PERFECT !!!
      
      
    }
    scanning = false;
    
  }
}


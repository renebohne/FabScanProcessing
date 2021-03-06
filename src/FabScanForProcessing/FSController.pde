public class FSController
{
  FSWebcam webcam;
  FSLaser laser;
  FSTurntable turntable;
  FSVision vision;
  FSModel model;
  FSSerial serial;

  public boolean scanning = false;
  boolean meshComputed = false;

  //all in degrees; (only when stepper is attached to laser)
  double laserSwipeMin = 30.0; //18
  double laserSwipeMax = 45.0; //50

    float stepDegrees =0.0f;

  int yDpi = 1;//1 for Best and Good resolution, 5 for Normal resolution, 10 for poor 

  PApplet parent;

  public float current_degree = 0;


  public FSController(PApplet p)
  {
    parent = p;
    webcam = new FSWebcam(parent);
    serial = new FSSerial(parent);
    laser = new FSLaser(this);
    turntable = new FSTurntable();
    vision = new FSVision();
    model = new FSModel();
    
    //serial.writeInt(207);//TURN LIGHT ON
  }

  public boolean detectLaserLine()
  {
    int threshold = 40;
    laser.turnOff();
    delay(200);
    PImage laserOffFrame = webcam.getFrame();
    while (laserOffFrame == null)
    {
      laserOffFrame = webcam.getFrame();
    }
    laser.turnOn();
    delay(200);
    PImage laserOnFrame = webcam.getFrame();
    while (laserOnFrame == null)
    {
      laserOnFrame = webcam.getFrame();
    }
  
    PVector p = vision.detectLaserLine( laserOffFrame, laserOnFrame, threshold );
    if (p.x == 0.0) {
      return false;
    }
    println("laser point position: "+p.toString());
    println("laser point position: "+vision.convertFSPointToCvPoint(p).toString());
    laser.setLaserPointPosition(p);
    return true;
  }


  public boolean init()
  {
    boolean ret = true;
    
    //check if the webcam is available
    if (!webcam.isAvailable())
    {
      println("ERROR: webcam is not available!");
      println("Available webcams: ");
      println(Capture.list());
      ret = false;
    }
    
    if (!serial.serialPortInitialized())
    {
      println("ERROR: serial port is not available!");
      println("Available serial ports:");
      println(Serial.list());
      ret = false;
    }
    
    if(ret == false)
    {
      return false;
    }
    
    delay(3000);//wait for stable power supply
    

    if (!detectLaserLine())
    {
      println("ERROR: laser line was not detected!");
      return false;
    }
    else
    {
      laser.disableStepperMotor();//disable the stepper motor that moves the laser

      scanning = true;//start scanning; if false, scan stops
      stepDegrees = turntable.getStepSize();

      laser.turnOn();

      turntable.setDirection(turntable.DIRECTION_CCW);
      turntable.enableStepperMotor();
      println("laser DETECTED.");
    }
    return true;
  }


  public PImage tick()
  {    
    if (current_degree < 360.0 && scanning == true)
    {
      //take picture with laser switched off
      laser.turnOff();
      delay(200);//NOT PERFECT...
      PImage laserOffImage = webcam.getFrame();
      while (laserOffImage == null)
      {
        laserOffImage = webcam.getFrame();
      }

      //take picture with laser switched on
      laser.turnOn();
      delay(200);//NOT PERFECT...
      PImage laserOnImage = webcam.getFrame();
      while (laserOnImage == null)
      {
        laserOnImage = webcam.getFrame();
      }

      //here the magic happens

      if (vision.putPointsFromFrameToCloud(laserOffImage, laserOnImage, yDpi, 0, this) ==true)
      {
        turntable.turnNumberOfDegrees(stepDegrees);
        delay(  1000+(int)stepDegrees*100);//NOT PERFECT !!!


        current_degree += stepDegrees;

        return vision.getImageForMainWindow();//this is the image that we see in the preview (MainWindow)
      }

      return null;//vision.putPointsFromFrameToCloud failed
    }
    else if (current_degree >= 360.0)
    {
      scanning = false;
      model.savePointCloudToFile();
      return null;
    }
    else
    {
      scanning = false;
      return null;
    }
  }
}


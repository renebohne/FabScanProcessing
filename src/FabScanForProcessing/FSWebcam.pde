import processing.video.*;

public class FSWebcam
{

  public boolean DEBUG_MODE = false;
  private int image_counter=0;

  Capture cam;
  PApplet parent;

  PImage laserOnImage;
  PImage laserOffImage;


  public FSWebcam(PApplet p)
  {
    parent = p;
    //String[] cameras = Capture.list();
    //println(cameras);
    //if (cameras != null)
    //{
    //for (int i = 0; i < cameras.length; i++) 
    //{
    //  println(cameras[i]);
    //}
    //println("selected camera: "+cameras[0]);
    //cam = new Capture(parent, cameras[0]);
    //}

    if (DEBUG_MODE)
    {
      laserOnImage = loadImage("img_5397.jpg");
      laserOffImage = loadImage("img_5396.jpg");
    }
    else
    {
      cam = new Capture(parent, (int) FSConfiguration.CAM_IMAGE_WIDTH, (int) FSConfiguration.CAM_IMAGE_HEIGHT, FSConfiguration.CAM_PORT_NAME, 30);

      if (cam != null)
      {
        cam.start();
      }
    }
  }


  public boolean isAvailable()
  {
    if (DEBUG_MODE)
    {
      return true;
    }
    else {
      return cam != null;
    }
  }

  public PVector getPosition()
  {
    PVector result = new PVector(FSConfiguration.CAM_POS_X, FSConfiguration.CAM_POS_Y, FSConfiguration.CAM_POS_Z);
    return result;
  }

  public PImage getFrame()
  {
    if (DEBUG_MODE)
    {
      if (image_counter==0)
      {
        image_counter=1;
        return laserOffImage;
      }
      else
      {
        image_counter=0;
        return laserOnImage;
      }
    }

    if (cam.available())
    {
      cam.read();



      cam.loadPixels();

      PImage result = createImage(cam.width, cam.height, RGB);
      result.loadPixels();
      int numPixels = cam.width*cam.height;
      for (int i=0; i<numPixels;i++)
      {

        if (FSConfiguration.APPLY_RED_FILTER)//remove green and blue channels... only show the red channel (because the laser is red)
        {
          result.pixels[i] = cam.pixels[i] & 0xFFFF0000;//ARGB
        }
        else if (FSConfiguration.APPLY_BLUE_FILTER)//less blue!
        {
          result.pixels[i] = cam.pixels[i] & 0xFFFFFF3F;//ARGB
        }

        else//1:1 camera picture
        {
          result.pixels[i] = cam.pixels[i];
        }
      }

      cam.updatePixels();
      result.updatePixels();
      return result;


      //return cam.get();
    }
    return null;
  }
}


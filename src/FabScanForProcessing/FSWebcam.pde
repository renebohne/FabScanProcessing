public class FSWebcam
{
  public boolean isAvailable()
  {
    return true;
  }
  
  public PVector getPosition()
  {
    PVector result = new PVector(FSConfiguration.CAM_POS_X,FSConfiguration.CAM_POS_Y);
    return result;
  }
  
  public PImage getFrame()
  {
    PImage image = new PImage(1280,960);
    
    return image;
    
  }
}

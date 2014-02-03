// uses hough_lines by David Chatting: https://github.com/davidchatting/hough_lines
import java.awt.image.BufferedImage; 
import java.util.Vector; 
import java.awt.Color;


public class FSVision
{
  public FSVision()
  {
  }

public PVector detectLaserLine(PImage laserOff, PImage laserOn, int threshold )
{
    int rows = laserOff.height;
    PImage laserLine = subLaser(laserOff, laserOn);//was subLaser2
    
    PImage laserLineBW = convertImageToGreyscale(laserLine);//convert to grayscale
    
    HoughTransform h=new HoughTransform(laserLineBW);
    Vector<HoughLine> lines=h.getLines(4);  //get the top scoring 4 lines

    
    if(lines.size()==0){
        //println("ERROR: Did not detect any laser line, did you select a SerialPort form the menu?");
        PVector p = new PVector(0,0,0);
        return(p);
    }
    
    PVector p1 = new PVector(lines.elementAt(0).x1, lines.elementAt(0).y1);
   
    PVector p = convertCvPointToFSPoint(p1);
    return p;

}


public PImage detectEdges(PImage img)
{
  CannyEdgeDetector detector = new CannyEdgeDetector();

  detector.setLowThreshold(0.5f);
  detector.setHighThreshold(1f);

   detector.setSourceImage((java.awt.image.BufferedImage)img.getImage());
   
   detector.process();
   BufferedImage edges = detector.getEdgesImage();
   PImage changed = new PImage(edges);
   return changed;
}

  //from Processing Webpage... but this is not working too well
  public PImage old_detectEdges(PImage img)
  {
    float[][] kernel = {
      { 
        -1, -1, -1
      }
      , 
      { 
        -1, 9, -1
      }
      , 
      { 
        -1, -1, -1
      }
    };

    PImage result = createImage(img.width, img.height, RGB);

    // Loop through every pixel in the image.
    for (int y = 1; y < img.height-1; y++) { // Skip top and bottom edges
      for (int x = 1; x < img.width-1; x++) { // Skip left and right edges
        float sum = 0; // Kernel sum for this pixel
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            // Calculate the adjacent pixel for this kernel point
            int pos = (y + ky)*img.width + (x + kx);
            // Image is grayscale, red/green/blue are identical
            float val = red(img.pixels[pos]);
            // Multiply adjacent pixels based on the kernel values
            sum += kernel[ky+1][kx+1] * val;
          }
        }
        // For this pixel in the new image, set the gray value
        // based on the sum from the kernel
        result.pixels[y*img.width + x] = color(sum, sum, sum);
      }
    }
    result.updatePixels();
    return result;
  }


  private PImage subLaser(PImage laserOffImage, PImage laserOnImage)
  {
    if(laserOffImage == null || laserOnImage == null)
    {
      return null;
    }
    PImage bwLaserOffImage = convertImageToGreyscale(laserOffImage);
    PImage bwLaserOnImage = convertImageToGreyscale(laserOnImage);

    PImage result = (PImage) bwLaserOnImage.get();
    
    result.blend(bwLaserOffImage, 0, 0, bwLaserOffImage.width, bwLaserOffImage.height, 0, 0, result.width, result.height, SUBTRACT);//subtract both grayscales
    
    //PImage tresh2Image = (PImage) result.get();
    
    PImage gaussImage = result.get();
    gaussImage.filter(BLUR, 5); //gaussian filter - parameter: radius... 5 or 3??

    //seems to work better if we DON'T subtract a second time...???
    //result.blend(gaussImage, 0, 0, gaussImage.width, gaussImage.height, 0, 0, result.width, result.height, SUBTRACT);//subtract both grayscales
    
    //cv::threshold(diffImage,treshImage,threshold,255,cv::THRESH_BINARY); //apply threshold
    result.filter(THRESHOLD, 0.1);//apply threshold

    result.filter(ERODE);

    result = detectEdges(result);
    
    PImage laserImage = createImage(result.width, result.height, RGB);
    result.loadPixels();
    laserImage.loadPixels();
    
    //initialize all pixels in laserImage to black
    for(int px=0; px<laserImage.width*laserImage.height; px++)
    {
      laserImage.pixels[px] = color(0);
    }
    
    int[] edges = new int[result.width]; //contains the cols index of the detected edges per row
    for(int y = 0; y <result.height; y++){
        //reset the detected edges
        for(int j=0; j<result.width; j++){ edges[j]=-1; }
        
        int j=0;
        for(int x = 0; x<result.width; x++){
            if(result.pixels[y*result.width+x]>color(250)){
                edges[j]=x;
                j++;
            }
        }
        
        //iterate over detected edges, take middle of two edges
        for(int k=0; k<result.width-1; k+=2)
        {
            if(edges[k]>=0 && edges[k+1]>=0 && (edges[k+1]-edges[k]<40) )
            {
                int middle = (int)(edges[k]+edges[k+1])/2;
                //qDebug() << cols << rows << y << middle;
                laserImage.pixels[y*result.width+middle] = color(255);
            }
        }
    }
    
    result.updatePixels();
    laserImage.updatePixels();
    
    return laserImage;
  }




  PImage convertImageToGreyscale(PImage img)
  {
    PImage result;

    if(img == null)
    {
      return null;
    }
    
    result = img.get();
    result.filter(GRAY);
    return result;
  }

  private PVector convertFSPointToCvPoint(PVector fsPoint)
  {
    PVector cvImageSize = new PVector(FSConfiguration.CAM_IMAGE_WIDTH, FSConfiguration.CAM_IMAGE_HEIGHT);
    PVector fsImageSize = new PVector(FSConfiguration.FRAME_WIDTH, FSConfiguration.FRAME_WIDTH*(FSConfiguration.CAM_IMAGE_HEIGHT/FSConfiguration.CAM_IMAGE_WIDTH), 0.0f);

    PVector origin = new PVector(cvImageSize.x/2.0f, cvImageSize.y*FSConfiguration.ORIGIN_Y);

    PVector cvPoint = new PVector(fsPoint.x*cvImageSize.x/fsImageSize.x, -fsPoint.y*cvImageSize.y/fsImageSize.y);

    //translate
    cvPoint.x += origin.x;
    cvPoint.y += origin.y;

    return cvPoint;
  }

  private PVector convertCvPointToFSPoint(PVector cvPoint)
  {
    PVector cvImageSize = new PVector(FSConfiguration.CAM_IMAGE_WIDTH, FSConfiguration.CAM_IMAGE_HEIGHT);
    PVector fsImageSize = new PVector(FSConfiguration.FRAME_WIDTH, FSConfiguration.FRAME_WIDTH*(FSConfiguration.CAM_IMAGE_HEIGHT/FSConfiguration.CAM_IMAGE_WIDTH), 0.0f);

    //here we define the origin of the cvImage, we place it in the middle of the frame and in the corner of the two perpendiculair planes
    PVector origin = new PVector(cvImageSize.x/2.0f, cvImageSize.y*FSConfiguration.ORIGIN_Y);


    //translate
    cvPoint.x -= origin.x;
    cvPoint.y -= origin.y;

    //scale
    PVector fsPoint = new PVector(cvPoint.x*fsImageSize.x/cvImageSize.x, -cvPoint.y*fsImageSize.y/cvImageSize.y,0);


    return fsPoint;
  }




  //dpiVertical: step between vertical points, lowerLimit: remove points below this limit
  public boolean putPointsFromFrameToCloud(PImage laserOffImage, PImage laserOnImage, int dpiVertical, float lowerLimit, FSController controller)
  {
    
    if(laserOffImage == null || laserOnImage == null)
    {
      return false;
    }
    
    PImage laserLineImage = subLaser(laserOffImage, laserOnImage);
    if(laserLineImage==null)
    {
      println("ERROR: laserLineImage==null");
      return false;
    }

    //convert from rgb to b&w
    PImage bwImage = convertImageToGreyscale(laserLineImage);

    //position of the laser line on the back plane in frame/image coordinates
    PVector fsLaserLinePosition =  controller.laser.getLaserPointPosition();
    //println("fsLaserLinePosition: "+fsLaserLinePosition.toString());
    PVector cvLaserLinePosition = convertFSPointToCvPoint(fsLaserLinePosition);
    //println("cvLaserLinePosition: "+cvLaserLinePosition.toString());
    float laserPos = cvLaserLinePosition.x;//const over all y
    

    bwImage.loadPixels();

    for (int y = FSConfiguration.UPPER_ANALYZING_FRAME_LIMIT;y < bwImage.height-(FSConfiguration.LOWER_ANALYZING_FRAME_LIMIT);y+=dpiVertical )
    {
      for (int x = bwImage.width-1;x >= laserPos+FSConfiguration.ANALYZING_LASER_OFFSET;x--)
      {
        if(bwImage.pixels[y*bwImage.width+x]==color(255))//check if white=laser-reflection
        { 
          //we have a white point in the grayscale image, so one edge laser line found
          //now we should continue to look for the other edge and then take the middle of those two points
          //to take the width of the laser line into account

          //position of the reflected laser line on the image coord
          PVector cvNewPoint = new PVector(x, y);

          //convert to world coordinates withouth depth
          PVector fsNewPoint = convertCvPointToFSPoint(cvNewPoint);
          //println("fsNewPoint: "+fsNewPoint.toString());

          FSLine l1 = new FSLine(controller.webcam.getPosition(), fsNewPoint);
          FSLine l2 = new FSLine(controller.laser.getPosition(), controller.laser.getLaserPointPosition());
          
          
          PVector i = l1.computeIntersectionWithLine(l2);
          fsNewPoint.x = i.x;
          fsNewPoint.z = i.z;
          
          //At this point we know the depth=z. Now we need to consider the scaling depending on the depth.
          //First we move our point to a camera centered cartesion system.
          fsNewPoint.y -= (controller.webcam.getPosition()).y;
          fsNewPoint.y *= ((controller.webcam.getPosition()).z - fsNewPoint.z)/(controller.webcam.getPosition()).z;
          //Redo the translation to the box centered cartesion system.
          fsNewPoint.y += (controller.webcam.getPosition()).y;

          //turning new point according to current angle of turntable
          //translate coordinate system to the middle of the turntable
          fsNewPoint.z -= FSConfiguration.TURNTABLE_POS_Z; //7cm radius of turntbale plus 5mm offset from back plane
          PVector alphaDelta = controller.turntable.getRotation();
          float alphaOld = (float)atan(fsNewPoint.z/fsNewPoint.x);
          float alphaNew = alphaOld+alphaDelta.y*(PI/180.0f);
          float hypotenuse = (float)sqrt(fsNewPoint.x*fsNewPoint.x + fsNewPoint.z*fsNewPoint.z);
          

          if (fsNewPoint.z < 0 && fsNewPoint.x < 0) {
            alphaNew += PI;
          }
          else if (fsNewPoint.z > 0 && fsNewPoint.x < 0) {
            alphaNew -= PI;
          }
          fsNewPoint.z = (float)sin(alphaNew)*hypotenuse;
          fsNewPoint.x = (float)cos(alphaNew)*hypotenuse;
          
          
          if (fsNewPoint.y>lowerLimit+0.5 && hypotenuse < 7) { //eliminate points from the grounds, that are not part of the model
            
            controller.model.addPointToPointCloud(fsNewPoint);
            //println("added point to pointcloud: "+fsNewPoint.toString());
          }
          break;
        }
      }
    }
    return true;
  }
}


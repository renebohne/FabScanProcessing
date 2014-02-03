// uses hough_lines by David Chatting: https://github.com/davidchatting/hough_lines
import java.awt.image.BufferedImage; 
import java.util.Vector; 
import java.awt.Color;


public class FSVision
{

  private PImage returnImage = null;//you can put the image that this method should return in this variable. This image will be displayed after each step...

  public FSVision()
  {
  }

  //this image should be displayed in the MainWindow... for a preview and progress indicatin
  public PImage getImageForMainWindow()
  {
    return returnImage;
  }

  //this image should be displayed in the MainWindow... for a preview and progress indicatin
  public void setImageForMainWindow(PImage img)
  {
    returnImage = img.get();
  }


//TODO: THIS IS A DRAFT! I need to find a better method for this. At least, the HoughTransformation was removed :)
  public PVector detectLaserLine(PImage laserOff, PImage laserOn, int threshold )
  {
    
    PImage laserLine = subLaser(laserOff, laserOn);//was subLaser2
    
    //only consider the top ... pixels!! If we would parse the whole frame, we might detect the wrong x-position of the laser
    //laserLine.resize(laserOff.width, FSConfiguration.LOWEST_Y_POSITION_FOR_LASER_DETECTION);
    laserLine = laserLine.get(0,0,laserLine.width, FSConfiguration.LOWEST_Y_POSITION_FOR_LASER_DETECTION);

    float middle_x = -1.0f;
    float middle_y = -1.0f;
    
    for (int y = 0; y <laserLine.height; y++) 
    {
      for (int x = 0; x<laserLine.width; x++) 
      {
        if (laserLine.pixels[y*laserLine.width+x] == color(255)) 
        {
          middle_x = x;
          middle_y = y;
          //println("x,y: "+middle_x+" "+middle_y);
        }
      }
    }
    
    if( (middle_x == -1.0f) && (middle_y == -1.0f))
    {
      println("ERROR: Did not detect any laser line, did you select a SerialPort form the menu?");
      PVector p = new PVector(0, 0, 0);
      return p;
    }
     
    PVector p1 = new PVector(middle_x, middle_y);

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

  private PImage subLaser(PImage laserOffImage, PImage laserOnImage)
  {
    if (laserOffImage == null || laserOnImage == null)
    {
      return null;
    }

    //setImageForMainWindow(laserOnImage);



    //PImage result = (PImage) laserOnImage.get();
    PImage result = laserOnImage;
    
    laserOffImage.filter(GRAY);
    laserOnImage.filter(GRAY);
    


    result.blend(laserOffImage, 0, 0, laserOffImage.width, laserOffImage.height, 0, 0, result.width, result.height, SUBTRACT);//subtract both grayscales

    result.filter(BLUR, 8);//???

    result.filter(THRESHOLD, FSConfiguration.IMAGE_FILTER_THRESHOLD);//apply threshold

    result.filter(ERODE);

    result = detectEdges(result);

    PImage laserImage = createImage(result.width, result.height, RGB);
    result.loadPixels();
    laserImage.loadPixels();

    //initialize all pixels in laserImage to black
    for (int px=0; px<laserImage.width*laserImage.height; px++)
    {
      laserImage.pixels[px] = color(0);
    }

    int[] edges = new int[result.width]; //contains the cols index of the detected edges per row
    for (int y = 0; y <result.height; y++) {
      //reset the detected edges
      for (int j=0; j<result.width; j++) { 
        edges[j]=-1;
      }

      int j=0;
      for (int x = 0; x<result.width; x++) {
        if (result.pixels[y*result.width+x]>color(250)) {
          edges[j]=x;
          j++;
        }
      }

      //iterate over detected edges, find edges with biggest distance per row
      int max_distance_index = -1;
      int max_distance = -1;
      for (int k=0; k<result.width-1; k+=2)
      {
        if (edges[k]>=0 && edges[k+1]>=0 && (edges[k+1]-edges[k]<FSConfiguration.MAX_EDGE_DISTANCE) && (edges[k+1]-edges[k]>FSConfiguration.MIN_EDGE_DISTANCE) )
        {
          if (edges[k+1]-edges[k] > max_distance)
          {
            max_distance = edges[k+1]-edges[k];
            max_distance_index = k;
          }
        }
      }

      //take middle of two edges with biggest distance
      if (max_distance_index > -1)
      {
        int middle = (int)(edges[max_distance_index]+edges[max_distance_index+1])/2;
        laserImage.pixels[y*result.width+middle] = color(255);
      }
    }

    result.updatePixels();
    laserImage.updatePixels();

    //setImageForMainWindow(laserImage);

    return laserImage;
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
    PVector fsPoint = new PVector(cvPoint.x*fsImageSize.x/cvImageSize.x, -cvPoint.y*fsImageSize.y/cvImageSize.y, 0);

    return fsPoint;
  }


//TODO: only draw this once and make it a static overlay to save ressources!!!
  //draw calibration lines on the screen...
  public PImage drawHelperLinesToFrame(PImage frame)
  {
    PGraphics pg = createGraphics(frame.width, frame.height, P2D);
    pg.beginDraw();
    pg.image(frame, 0, 0);

    //artificial horizon
    pg.stroke(0, 0, 255); 
    pg.line(0, frame.height*FSConfiguration.ORIGIN_Y, frame.width, frame.height*FSConfiguration.ORIGIN_Y);

    //two lines for center of frame
    pg.stroke(255, 255, 0); 
    pg.line(frame.width*0.5f, 0, frame.width*0.5f, frame.width);
    //  pg.stroke(255,255,0); pg.line(0,frame.height*0.5f, frame.width, frame.height*0.5f);

    //line showing the lower limit where analyzing stops
    pg.stroke(255, 0, 0); 
    pg.line(0, frame.height-FSConfiguration.LOWER_ANALYZING_FRAME_LIMIT, frame.width, frame.height-FSConfiguration.LOWER_ANALYZING_FRAME_LIMIT);

    //line showing the upper limit where analyzing starts
    pg.stroke(255, 255, 0); 
    pg.line(0, FSConfiguration.UPPER_ANALYZING_FRAME_LIMIT, frame.width, FSConfiguration.UPPER_ANALYZING_FRAME_LIMIT);
   
    //laser
    pg.stroke(255, 0, 0); 
    float thex = convertFSPointToCvPoint(controller.laser.getLaserPointPosition()).x;
    
    pg.line(thex, 0, thex, frame.height);
   

    pg.endDraw();

    return pg.get();
  }




  //dpiVertical: step between vertical points, lowerLimit: remove points below this limit
  public boolean putPointsFromFrameToCloud(PImage laserOffImage, PImage laserOnImage, int dpiVertical, float lowerLimit, FSController controller)
  {
    returnImage = null;

    if (laserOffImage == null || laserOnImage == null)
    {
      return false;
    }

    PImage laserLineImage = subLaser(laserOffImage, laserOnImage);

    //setImageForMainWindow(laserLineImage);

    if (laserLineImage==null)
    {
      println("ERROR: laserLineImage==null");

      return false;
    }


    //create a nice preview image for the main window... it shows the camera picture without the laser and on top of that, the detected laser line (edges)
    PImage previewImage;
    
    
    if(FSConfiguration.SHOW_CALIBRATIONLINES)
    {
      previewImage = drawHelperLinesToFrame(laserOffImage.get());
    }
    else
    {
      previewImage = laserOffImage.get();
    }
    
    previewImage.blend(laserLineImage, 0, 0, previewImage.width, previewImage.height, 0, 0, previewImage.width, previewImage.height, LIGHTEST); 
    setImageForMainWindow(previewImage);


    //convert from rgb to b&w
    laserLineImage.filter(GRAY);
    

//THE LASER POSITION IS ONLY DETECTED ONCE AT THE START!
//THIS IS OK IF THE LASER IS NOT MOVED (NO STEPPER MOTOR FOR THE LASER)

    //position of the laser line on the back plane in frame/image coordinates
    PVector fsLaserLinePosition =  controller.laser.getLaserPointPosition();
    PVector cvLaserLinePosition = convertFSPointToCvPoint(fsLaserLinePosition);
    float laserPos = cvLaserLinePosition.x;//const over all y


    laserLineImage.loadPixels();

    for (int y = FSConfiguration.UPPER_ANALYZING_FRAME_LIMIT;y < laserLineImage.height-(FSConfiguration.LOWER_ANALYZING_FRAME_LIMIT);y+=dpiVertical )
    {
      for (int x = laserLineImage.width-1;x >= laserPos+FSConfiguration.ANALYZING_LASER_OFFSET;x--)
      {
        if (laserLineImage.pixels[y*laserLineImage.width+x]==color(255))//check if white=laser-reflection
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
        
    laserLineImage.updatePixels();

    return true;
  }
}


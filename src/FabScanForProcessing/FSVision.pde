

public class FSVision
{



  public FSVision()
  {
  }


  public PImage detectEdges(PImage img)
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
    int cols = laserOffImage.width;
    int rows = laserOffImage.height;

    PImage bwLaserOffImage = convertImageToGreyscale(laserOffImage);
    PImage bwLaserOnImage = convertImageToGreyscale(laserOnImage);

    PImage result;
    try
    {
      result = (PImage) bwLaserOnImage.clone();
    }
    catch(CloneNotSupportedException ex)
    {
      result = null;
    }

    result.blend(bwLaserOffImage, 0, 0, bwLaserOffImage.width, bwLaserOffImage.height, 0, 0, result.width, result.height, SUBTRACT);//subtract both grayscales
    result.blend(0, 0, bwLaserOffImage.width, bwLaserOffImage.height, 0, 0, result.width, result.height, SUBTRACT);//subtract both grayscales

    PImage tresh2Image;
    try
    {
      tresh2Image = (PImage) result.clone();
    }
    catch(CloneNotSupportedException ex)
    {
      tresh2Image = null;
    }


    result.filter(BLUR, 5); //gaussian filter - parameter: radius... 5 or 3??

    //cv::threshold(diffImage,treshImage,threshold,255,cv::THRESH_BINARY); //apply threshold
    result.filter(THRESHOLD, 10);//apply threshold

    result.filter(ERODE);


    result = detectEdges(result);



    //cv::Mat element5(3,3,CV_8U,cv::Scalar(1));
    //cv::morphologyEx(treshImage,treshImage,cv::MORPH_OPEN,element5);

    //cv::cvtColor(treshImage, result, CV_GRAY2RGB); //convert back ro rgb
    return result;
  }




  PImage convertImageToGreyscale(PImage img)
  {
    /*
    PImage result = new PImage(img.width, img.height);
     for (int x=0; x<img.width; x++)
     {
     for (int y=0; y<img.height; y++)
     {
     color c = img.get(x, y);
     float red = red(c);
     float green = green(c);
     float blue = blue(c);
     int grey = (int)(red+green+blue)/3;
     color Color =color(grey, grey, grey);
     result.set(x, y, Color);
     }
     }
     return result;
     */
    PImage result;

    try
    {
      result = (PImage) img.clone();
    }
    catch(CloneNotSupportedException ex)
    {
      return null;
    }

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
    PVector fsPoint = new PVector(cvPoint.x*fsImageSize.x/cvImageSize.x, -cvPoint.y*fsImageSize.y/cvImageSize.y);


    return fsPoint;
  }




  //dpiVertical: step between vertical points, lowerLimit: remove points below this limit
  public void putPointsFromFrameToCloud(PImage laserOffImage, PImage laserOnImage, int dpiVertical, float lowerLimit, FSController controller)
  {
    PImage laserLineImage = subLaser(laserOffImage, laserOnImage);

    //convert from rgb to b&w
    PImage bwImage = convertImageToGreyscale(laserLineImage);

    //position of the laser line on the back plane in frame/image coordinates
    PVector fsLaserLinePosition =  controller.laser.getLaserPointPosition();
    PVector cvLaserLinePosition = convertFSPointToCvPoint(fsLaserLinePosition);
    float laserPos = cvLaserLinePosition.x;//const over all y

    int cols = laserLineImage.width;
    int rows = laserLineImage.height;

    for (int y = FSConfiguration.UPPER_ANALYZING_FRAME_LIMIT;y < bwImage.height-(FSConfiguration.LOWER_ANALYZING_FRAME_LIMIT);y+=dpiVertical )
    {
      for (int x = bwImage.width-1;x >= laserPos+FSConfiguration.ANALYZING_LASER_OFFSET;x--)
      {
        if (bwImage.get(x, y)==255)//check if white=laser-reflection
        { 
          //we have a white point in the grayscale image, so one edge laser line found
          //no we should continue to look for the other edge and then take the middle of those two points
          //to take the width of the laser line into account

          //position of the reflected laser line on the image coord
          PVector cvNewPoint = new PVector(x, y);

          //convert to world coordinates withouth depth
          PVector fsNewPoint = convertCvPointToFSPoint(cvNewPoint);

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

          //get color from picture without laser -- TODO SINCE JAVA PORT DOES NOT CARE ABOUT COLORS YET
          //FSUChar r = laserOff.at<cv::Vec3b>(y, x)[2];
          //FSUChar g = laserOff.at<cv::Vec3b>(y, x)[1];
          //FSUChar b = laserOff.at<cv::Vec3b>(y, x)[0];
          //fsNewPoint.color = FSMakeColor(r, g, b);

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
            //qDebug("adding point");
            controller.model.addPointToPointCloud(fsNewPoint);
          }
          break;
        }
      }
    }
  }
}


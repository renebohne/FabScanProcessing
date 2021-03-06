public static class FSConfiguration
{

  public static String SERIAL_PORT_NAME = "/dev/tty.usbmodem1421";

  public static String CAM_PORT_NAME = "USB Camera";

  public static boolean SHOW_CALIBRATIONLINES = true;
  
  public static boolean EXPORT_DAT_FILE = false;//binary format for sunflow renderer
  
  public static boolean RESIZE_PREVIEW = false;//true resizes the preview image to 1024x768
  
  //filter out blue channel
  public static boolean APPLY_BLUE_FILTER = false;
  
  //filter out green and blue channels
  public static boolean APPLY_RED_FILTER = true;

  //threshold between black and white... allowed values: 0.00f-1.00f  
  public static float IMAGE_FILTER_THRESHOLD = 0.1f;//default: 0.1f

  //minimum distance between two points of an edge (aka minimum width of the laser line)
  public static int MIN_EDGE_DISTANCE = 0;//pixels - good values are between 0 and 2

  //maximum distance between two points of an edge (aka maximum width of the laser line)
  public static int MAX_EDGE_DISTANCE = 60;//pixels

  //we expect the laser to be within this frame
  public static int MIN_X_POSITION_FOR_LASER_DETECTION = 300;
  public static int MAX_X_POSITION_FOR_LASER_DETECTION = 1280/2;
  public static int MIN_Y_POSITION_FOR_LASER_DETECTION = 0;
  public static int MAX_Y_POSITION_FOR_LASER_DETECTION = 50;
  
  //to make the scanning process faster we ommit the lower and hight part of the cvImage
  //as there is no object anyway.  The lower limit is defined by the turning table lower bound
  //units are pixels, seen from the top, resp from the bottom  
  public static int UPPER_ANALYZING_FRAME_LIMIT = 0;
  public static int LOWER_ANALYZING_FRAME_LIMIT = 30;
  

  //as the actual position in the frame differs a little from calculated laserline we stop a little befor as we might catch the real non reflected laser line which creates noise
  public static int ANALYZING_LASER_OFFSET = 90;


  /********************************/
  /*       CAMERA DEFINES         */
  /********************************/
  //logitech c270
  //public static float FRAME_WIDTH = 26.6f;//in cm. the width of what the camera sees, ie place a measure tool at the back-plane and see how many cm the camera sees.
  public static float FRAME_WIDTH = 24.6f;//in cm. the width of what the camera sees, ie place a measure tool at the back-plane and see how many cm the camera sees.

  public static float CAM_IMAGE_WIDTH = 1280.0f;
  public static float CAM_IMAGE_HEIGHT = 960.0f;



  //defining the origin in the cvFrame
  //the position of intersection of back plane with ground plane in cvFrame IN PERCENT
  //check the yellow laser line to calibrate, the yellow laser line should touch the bottom plane
  public static float ORIGIN_Y= 0.75;


  /********************************/
  /*    HARDWARE SETUP DEFINES    */
  /********************************/

  //position of the laser
  public static float LASER_POS_X = 14.0f; //precise by construction
  public static float LASER_POS_Y = 6.4f;  //not needed/used for calculations
  public static float LASER_POS_Z = 28.8f; //precise by construction

  public static float LASER_SWIPE_MIN = 18.0f;
  public static float LASER_SWIPE_MAX = 52.0f;

  //position of the c270
  public static float CAM_POS_X = 0.0f; //precise by construction
  public static float CAM_POS_Y = 5.57f;
  public static float CAM_POS_Z = 30.9f;

  //position of the turntable
  public static float TURNTABLE_POS_X = 0.0f; //not used by calculations
  public static float TURNTABLE_POS_Y = 0.0f; //not used by calculations
  public static float TURNTABLE_POS_Z = 7.5f; //precise by construction
}


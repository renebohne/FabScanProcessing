public static class FSConfiguration
{

public static String SERIAL_PORT_NAME = "/dev/tty.usbmodem1421";
  
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
public static float FRAME_WIDTH = 26.6f;//in cm. the width of what the camera sees, ie place a measure tool at the back-plane and see how many cm the camera sees.
//public static float CAM_IMAGE_WIDTH = 1280.0f;
//public static float CAM_IMAGE_HEIGHT = 960.0f; //here I am not sure, I think it is 960, (old=853.0f)
public static float CAM_IMAGE_WIDTH = 1280.0f;
public static float CAM_IMAGE_HEIGHT = 960.0f; //here I am not sure, I think it is 960, (old=853.0f)



//defining the origin in the cvFrame
//the position of intersection of back plane with ground plane in cvFrame in percent
//check the yellow laser line to calibrate, the yellow laser line should touch the bottom plane
public static float    ORIGIN_Y= 0.75;


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


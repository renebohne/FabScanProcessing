//import hypermedia.video.*;


FSController controller;

//OpenCV opencv;

void setup()
{
  //opencv = new OpenCV(this);
  controller = new FSController();
  controller.scanThread();  
}

void draw()
{
}


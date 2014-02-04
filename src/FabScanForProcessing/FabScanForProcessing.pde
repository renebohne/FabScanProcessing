FSController controller;

boolean initialized = false;


//private static final int MegaBytes = 1024 * 1024;


void setup()
{
  size((int) FSConfiguration.CAM_IMAGE_WIDTH, (int) FSConfiguration.CAM_IMAGE_HEIGHT, P3D);
  //size(800,600, P3D);
  //opencv = new OpenCV(this);
  controller = new FSController(this);

  initialized = controller.init();

  fill(255);
  stroke(255);
  textSize(28);
}

void draw()
{
  background(0);

  if (!initialized)
  {

    PImage img = controller.vision.getImageForMainWindow();
    if (img != null)
    {
      image(img, 0, 0);
    }
    text("FabScan not ready! Please start the application again!", 100, 100);
    return;
  }

  if (!controller.scanning)
  {
    text("Done!", 100, 100);
    return;
  }

  PImage img = controller.tick();
  if (img != null)
  {
    PImage img_preview = controller.vision.getImageForMainWindow();
    image(img_preview, 0, 0);
  }
  //show progress 
  text("Scanning... progress: "+ nf(controller.current_degree*100.0f/360.0f, 1, 2)+ " %", 700, 80);
  text("Please wait: "+ nf(  420.0f - 420.0f*(controller.current_degree/360.0f), 1, 1)+ "  seconds", 700, 110);
  arc(width-100, 70, 100, 100, 0, radians(controller.current_degree), PIE);
  
  //long totalMemory = Runtime.getRuntime().totalMemory() / MegaBytes;
  //long maxMemory = Runtime.getRuntime().maxMemory() / MegaBytes;
  //long freeMemory = Runtime.getRuntime().freeMemory() / MegaBytes;
  //println("freeMemory in JVM: " + freeMemory);


}


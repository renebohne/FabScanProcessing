FSController controller;

boolean initialized = false;

void setup()
{
  //size((int) FSConfiguration.CAM_IMAGE_WIDTH, (int) FSConfiguration.CAM_IMAGE_HEIGHT, P3D);
  size(1024,768, P3D);
  
  controller = new FSController(this);

  initialized = controller.init();

  fill(255);
  stroke(255);
  textSize(14);
}

void draw()
{
  background(0);

  if (!initialized)
  {

    PImage img = controller.vision.getImageForMainWindow();
    if (img != null)
    {
      img.resize(width, height);//resize image to fit screen size
      image(img, 0, 0);
    }
    text("FabScan not ready! Check SERIAL_PORT_NAME and CAM_PORT_NAME in the FSConfiguration file. Please start the application again!", 50, height/2);
    text("Please look into the error messages in the Processing main window for more information.", 50, height/2+20);
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
    img_preview.resize(width, height);//resize image to fit screen size
    image(img_preview, 0, 0);
  }
  //show progress 
  text("Scanning... progress: "+ nf(controller.current_degree*100.0f/360.0f, 1, 2)+ " %", width-300, 40);
  text("Please wait: "+ nf(  420.0f - 420.0f*(controller.current_degree/360.0f), 1, 1)+ "  seconds", width-300, 60);
  text("# of points: "+ controller.model.numberOfPoints, width-300, 80);
  arc(width-60, 40, 50, 50, 0, radians(controller.current_degree), PIE);
  
}


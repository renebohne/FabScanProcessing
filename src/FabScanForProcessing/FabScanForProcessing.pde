FSController controller;


void setup()
{
  size((int) FSConfiguration.CAM_IMAGE_WIDTH , (int) FSConfiguration.CAM_IMAGE_HEIGHT);
  //size(800,600, P3D);
  //opencv = new OpenCV(this);
  controller = new FSController(this);
  controller.init();
  
  fill(255);
  stroke(255);
  textSize(32);
   
}

void draw()
{
  background(0);
  
  if(!controller.scanning)
  {
    text("Done!",100,100);
    return;
  }
  
  PImage img = controller.tick();
  if(img != null)
  {
    image(img,0,0);
  }
  //show progress 
  text("Scanning... progress: "+ nf(controller.current_degree*100.0f/360.0f,1,2)+ " %",600,80);
  arc(width-100, 70, 100, 100, 0, radians(controller.current_degree), PIE);
  
}

//not used yet. Later, we could show the points from the point cloud on the screen.
void showPoints()
{
  ArrayList<PVector> cloud = controller.model.getPointCloud();
    for(int i=0; i<cloud.size();i++)
    {
      PVector p = cloud.get(i);
      point(p.x,p.y,p.z);
    }
}


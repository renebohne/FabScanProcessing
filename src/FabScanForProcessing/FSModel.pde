public class FSModel
{
  ArrayList<PVector> pointcloud;
  private PrintWriter output;  
  
  public FSModel()
  {
    pointcloud = new ArrayList<PVector>();
    try
    {
      output = createWriter("pointcloud.asc");
    }
    catch(Exception ex)
    {
        println("ERROR: can't create file pointcloud.asc");
    }
  }
  
  public void addPointToPointCloud(PVector fsNewPoint)
  {
    pointcloud.add(fsNewPoint);
    println("added Point: "+fsNewPoint.x+" "+fsNewPoint.y+" "+fsNewPoint.z);
    output.println(fsNewPoint.x+" "+fsNewPoint.y+" "+fsNewPoint.z);
  }
  
  public ArrayList<PVector> getPointCloud()
  {
    return pointcloud;
  }
  
  public void savePointCloudToFile()
  {
    output.flush();
    output.close();
    println("saved file");
    
  
  }
}

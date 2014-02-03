public class FSModel
{
  //ArrayList<PVector> pointcloud;//we might want to get the point cloud for visualisation... but right now, it takes up too much memory
  private PrintWriter output;  
  
  public FSModel()
  {
    //pointcloud = new ArrayList<PVector>();//we might want to get the point cloud for visualisation... but right now, it takes up too much memory
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
    //pointcloud.add(fsNewPoint);//we might want to get the point cloud for visualisation... but right now, it takes up too much memory
    println("added Point: "+fsNewPoint.x+" "+fsNewPoint.y+" "+fsNewPoint.z);
    output.println(fsNewPoint.x+" "+fsNewPoint.y+" "+fsNewPoint.z);
  }
  
  //we might want to get the point cloud for visualisation... but right now, it takes up too much memory
  public ArrayList<PVector> getPointCloud()
  {
    //return pointcloud;
    throw new UnsupportedOperationException();
  }
  
  public void savePointCloudToFile()
  {
    output.flush();
    output.close();
    println("saved file");
    
  
  }
}

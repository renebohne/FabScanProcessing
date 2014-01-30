public class FSModel
{
  ArrayList<PVector> pointcloud;  
  
  public FSModel()
  {
    pointcloud = new ArrayList<PVector>();
  }
  
  public void addPointToPointCloud(PVector fsNewPoint)
  {
    pointcloud.add(fsNewPoint);
  }
}

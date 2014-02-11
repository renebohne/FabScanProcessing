import java.io.*;

public class FSModel
{
  //ArrayList<PVector> pointcloud;//we might want to get the point cloud for visualisation... but right now, it takes up too much memory
  private PrintWriter asc_output;//ascii file (open with MeshLab)
  private OutputStream dat_output;//Sunflow data file see: http://toxi.co.uk/blog/2006/12/point-cloud-experiments-with-sunflow.htm
  private DataOutputStream dat_ds; 

  public long numberOfPoints = 0;


  public FSModel()
  {
    //pointcloud = new ArrayList<PVector>();//we might want to get the point cloud for visualisation... but right now, it takes up too much memory
    try
    {
      asc_output = createWriter("pointcloud.asc");
      if (FSConfiguration.EXPORT_DAT_FILE)
      {
        dat_output = createOutput("pointcloud.dat");
        dat_ds = new DataOutputStream(dat_output);
      }
    }
    catch(Exception ex)
    {
      println("ERROR: can't create file pointcloud.asc");
    }
  }

  public void addPointToPointCloud(PVector fsNewPoint)
  {
    //pointcloud.add(fsNewPoint);//we might want to get the point cloud for visualisation... but right now, it takes up too much memory
    //println("added Point: "+fsNewPoint.x+" "+fsNewPoint.y+" "+fsNewPoint.z);
    numberOfPoints++;
    asc_output.println(fsNewPoint.x+" "+fsNewPoint.y+" "+fsNewPoint.z);

    if (FSConfiguration.EXPORT_DAT_FILE)
    {
      try
      {
        dat_ds.writeFloat(fsNewPoint.x);
        dat_ds.writeFloat(fsNewPoint.y);
        dat_ds.writeFloat(fsNewPoint.z);
      }
      catch(Exception ex)
      {
        ex.printStackTrace();
      }
    }
  }

  //we might want to get the point cloud for visualisation... but right now, it takes up too much memory
  public ArrayList<PVector> getPointCloud()
  {
    //return pointcloud;
    throw new UnsupportedOperationException();
  }

  public void savePointCloudToFile()
  {

    asc_output.flush();
    asc_output.close();

    if (FSConfiguration.EXPORT_DAT_FILE)
    {
      try
      {
        dat_ds.flush();
        dat_ds.close();
      }
      catch(Exception ex)
      {
        ex.printStackTrace();
      }
    }


    println("saved file");
  }
}


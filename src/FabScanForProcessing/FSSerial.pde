import processing.serial.*;

private PApplet parent;

private Serial myPort = null;
private int inByte = -1;    // Incoming serial data

protected String portName;

public class FSSerial
{
  public FSSerial(PApplet p)
  {
    parent = p;
    connectToSerialPort();
  }

  public boolean connectToSerialPort()
  {
    portName = FSConfiguration.SERIAL_PORT_NAME;
    try
    {
      myPort = new Serial(parent, portName, 9600);
    }
    catch(Exception ex)
    {
      myPort=null;
      return false;
    }
    
    if(myPort == null)
    {
      return false;
    }

    return true;
  }
  
  public boolean serialPortInitialized()
  {
    return (myPort != null);
  }


  public void writeInt(int c)
  {
    if(myPort==null)
    {
      return;
    }
    myPort.write(c);
  }

  //byte received from Arduino
  void serialEvent(Serial myPort) 
  {
    inByte = myPort.read();
  }
}


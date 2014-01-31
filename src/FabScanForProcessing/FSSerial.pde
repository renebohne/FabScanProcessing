import processing.serial.*;

private PApplet parent;

private Serial myPort;
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
    myPort = new Serial(parent, portName, 9600);

    return true;
  }


  public void writeInt(int c)
  {
    myPort.write(c);
  }

  //byte received from Arduino
  void serialEvent(Serial myPort) 
  {
    inByte = myPort.read();
  }
}


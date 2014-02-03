FabScanProcessing / FabScanForProcessing
=================

FabScan port to Java/Processing


INSTALLATION

1. Download Processing here: http://processing.org

2. Download FabScanForProcessing

3. Open FabScanForProcessing with the Processing IDE.


SCANNING

The scan starts immediately. 
There is no 3D preview yet!
You will see a very simple progress indicator and a picture preview that shows the calibration lines and the detected laser (white line).
A scan takes 7 minutes.
After the scan, you will find a file called "pointcloud.asc". You can import this file into MeshLab.

CALIBRATION

In the preview image, you can see three lines:
The red line at the bottom should touch the bottom of the turntable.
The blue line should touch the top of the turntable.
The vertical yellow line shows the centre of the frame - this is the centre of what the camera sees.
The horizontal yellow line at the top of the screen shows the upper analysing frame limit. By default, it is 0.

CONFIGURATION

You might want to change the settings in FSConfiguration.pde
The most important changes will be:

1. the name of your serial port. For my Mac it is:
public static String SERIAL_PORT_NAME = "/dev/tty.usbmodem1421";

2. the name of your camera device. For my Mac it is:
public static String CAM_PORT_NAME = "USB Camera";

Please write an issue if you found a bug.
Please send a pull request if you added some features or fixed some bugs :)


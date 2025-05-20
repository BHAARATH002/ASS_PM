For edge devices
1. Hardware equipment requirements
Equipment Usage Connection Method
Raspberry Pi 4B main controller (running code) must
Grove Pi main controller (control sensors) must
USB camera video capture (face detection) connected to USB port
Grove ultrasonic sensor distance detection connected to digital port (such as D4)
Grove blue LED alarm indicator connected to digital port (such as D3)
Grove buzzer alarm sound connected to digital port (such as D7)
2.Burn Raspberry Pi environment
Required equipment
Raspberry Pi (recommended 4B or 5, 2GB or more memory)
MicroSD card (at least 16GB, Class 10 speed)
Card reader (connect MicroSD card to computer)
Computer (Windows/macOS/Linux)

Download Resources
Ubuntu 22.04 LTS image
Official image (choose Raspberry Pi exclusive version):
Ubuntu Server for Raspberry Pi
Recommend downloading Ubuntu 22.04 LTS (RPi 4/400/5)
Burning tool
Windows: Rufus or BalenaEtcher
MacOS/Linux: BalenaEtcher or command-line tool dd

Using BalenaEtcher (recommended)
Insert the MicroSD card into the computer.
Open BalenaEtcher, click Flash from file and select the downloaded. img.xz image.
Select the target device (MicroSD card), confirm it is correct, and click Flash!.
Wait for the burning to complete (approximately 5-10 minutes).

3. Raspberry Pi internal environment dependency
Raspberry Pi internal environment dependency
Using Git Clone https://github.com/DexterInd/GrovePi.git Download related libraries
Then put the edge code in the Python folder under the software folder
And copy the latest I2C code from the official library here

4.Project related dependencies and environment
#Basic dependencies
opencv-python==4.9.0.80
numpy==1.26.4
pandas==2.2.1
Pillow==10.2.0
Python==3.11.8

#Hardware control
Grovepi==1.4.0 # Raspberry Pi Grove Sensor Control

#Network communication
websockets==12.0
aiohttp==3.9.3
requests==2.31.0

#Data serialization
pickle-mixin==1.0.2

5. How to insert Grove Pi port into devices
Grove ultrasonic sensor connected to digital port D4
Grove blue LED connected to digital port D3
Grove buzzer connected to digital port D7

6. run code
All environments related to Grove Pi need to be run in the sudo environment
If you have already installed it in the user environment, you can use the following code to run it
sudo -E python3

7. Configuration file modification
Modify the following variables to your actual configuration:
TCP_SRVER-IP='192.168.101.213' # Replace with TCP server IP
WEBSOCKET_URI = " wss://54.198.170.28:6789 # Replace with WebSocket server address
![image](https://github.com/user-attachments/assets/9c71810c-9958-4eb3-b174-58e82854f45b)

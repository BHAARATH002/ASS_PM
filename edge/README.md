Instruction on Edge Tier
For edge server
1.	Configure related dependencies
#Basic Library
opencv-python==4.9.0.80
numpy==1.26.4
pandas==2.2.1
requests==2.31.0
Pillow==10.2.0

#Facial recognition core
Dlib==19.24.4 # If GPU support is required, CUDA version needs to be installed separately

#AWS IoT Communication
boto3==1.34.74
awsiotsdk==1.17.1

#Video processing
Ffmpeg python==0.2.0 # FFmpeg binary needs to be installed in the system

#GUI interface
Tkinter==0.1.0 # Usually comes with Python and does not require separate installation

#python environment
Python3==3.11.8

2.	AI analysis models require
The following files need to be manually downloaded to the data/data-d lib/directory:
shape_predictor_68_face_landmarks.dat
dlib_face_recognition_resnet_model_v1.dat

3.	File and certificate configuration
Create a videos folder in the same directory of the code
Create an images folder in the same directory as the code
Ensure that the following files are in the project directory:
Intruder_Thing.cert.pem
Intruder_Thing.private.key
root-CA.crt

Create a data folder and create the data-d lib folder, features_all. csv file, and features_unknown.csv file within it
And put the model into the data-d lib folder

4.	network environment
Ensure smooth network connectivity for edge servers, preferably on the same network as Raspberry Pi.
Cannot use restricted networks such as campus network, hotel network, etc

5. Download AWS IoT Device SDK v2 for Python
Clone SDK repository (if directory does not exist):
bash
git clone  https://github.com/aws/aws-iot-device-sdk-python-v2.git  --recursive
Install SDK (if not installed):
bash
python3 -m pip install ./aws-iot-device-sdk-python-v2





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
![Uploading image.png…]()


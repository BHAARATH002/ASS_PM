Instruction on Edge Server Tier
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
![image](https://github.com/user-attachments/assets/73ad2493-da35-40c4-8664-00bd513bc9b8)

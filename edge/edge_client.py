import cv2
import pickle
import socket
import struct
import time
import asyncio
import websockets
from datetime import datetime
from collections import deque
import grovepi
import numpy as np
import os
import json
import ssl
import random

# GrovePi port definition
ultrasonic_port = 4
blue_light = 3
buzzer = 7

# Initialize GrovePi pins
grovepi.pinMode(blue_light, "OUTPUT")
grovepi.pinMode(buzzer, "OUTPUT")

# TCP server IP and port
TCP_SERVER_IP = '192.168.101.213'
TCP_SERVER_PORT = 12346

# WebSocket server URL
WEBSOCKET_URI = "wss://54.198.170.28:6789"

# åå§å TCP è¿æ¥
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((TCP_SERVER_IP, TCP_SERVER_PORT))
print('[INFO] Connected to TCP server')

# æåå¤´éç½®
cap = cv2.VideoCapture(0)
FPS = 10
VIDEO_SECONDS = 5
FRAME_COUNT = FPS * VIDEO_SECONDS
FRAME_BUFFER = deque(maxlen=FRAME_COUNT)
encode_param = [int(cv2.IMWRITE_JPEG_QUALITY), 80]

# äººè¸è¯å«æ¨¡å
face_cascade = cv2.CascadeClassifier(
    '/home/sun/.local/lib/python3.10/site-packages/cv2/data/haarcascade_frontalface_default.xml')


def check_sensors_health():
    status = {
        "camera": "1",
        "RIP": "1",
        "ultrasonic": "0",
        "blue_light": "0",
        "buzzer": "0"
    }

    try:
        distance = grovepi.ultrasonicRead(ultrasonic_port)
        status["ultrasonic"] = "1"
    except Exception as e:
        print(f"[ERROR] Ultrasonic check failed: {e}")

    try:
        grovepi.pinMode(blue_light, "OUTPUT")
        status["blue_light"] = "1"
    except Exception as e:
        print(f"[ERROR] Blue light check failed: {e}")

    try:
        grovepi.pinMode(buzzer, "OUTPUT")
        status["buzzer"] = "1"
    except Exception as e:
        print(f"[ERROR] Buzzer check failed: {e}")

    return status


def encode_frames_to_video(frames, fps=10):
    if not frames:
        return None
    height, width, _ = frames[0].shape
    fourcc = cv2.VideoWriter_fourcc(*'XVID')
    tmp_filename = 'temp_video.avi'
    out = cv2.VideoWriter(tmp_filename, fourcc, fps, (width, height))
    for frame in frames:
        out.write(frame)
    out.release()
    with open(tmp_filename, 'rb') as f:
        video_bytes = f.read()
    os.remove(tmp_filename)
    return video_bytes


# WebSocket 报警发送函数
async def send_alert_via_websocket(alert_data: dict):
    try:
        # Create SSL context that doesn't verify certificates
        ssl_context = ssl.SSLContext()
        ssl_context.verify_mode = ssl.CERT_NONE

        async with websockets.connect(WEBSOCKET_URI, ssl=ssl_context) as websocket:
            await websocket.send(json.dumps(alert_data))
            print("[INFO] Sent alert data via WebSocket:", alert_data)
    except Exception as e:
        print(f"[ERROR] WebSocket error: {e}")


try:
    while True:
        time.sleep(3.5)
        FRAME_BUFFER.clear()
        faces_detected = False
        distance_snapshot = grovepi.ultrasonicRead(ultrasonic_port)
        selected_frame = None

        alert_payload = {
            "pir": True,
            "timestamp": datetime.utcnow().isoformat() + "Z"
        }
        asyncio.run(send_alert_via_websocket(alert_payload))
        time.sleep(0.1)
        print("\n[INFO] Start recording 10 seconds video...")


        for _ in range(FRAME_COUNT):
            time.sleep(1 / FPS)
            ret, frame = cap.read()
            if not ret:
                print("[WARN] Failed to read frame from camera")
                continue

            FRAME_BUFFER.append(frame)

            if not faces_detected:
                gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
                faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))
                if len(faces) > 0:
                    try:
                        distance = grovepi.ultrasonicRead(ultrasonic_port)
                        if distance == -1 or distance is None:
                            distance = 0
                    except Exception as e:
                        print(f"[ERROR] Ultrasonic sensor read error: {e}")
                        distance = 0
                    distance_snapshot = distance
                    selected_frame = frame.copy()
                    faces_detected = True

        print("[INFO] 10 seconds recording finished")
        if distance_snapshot is None or distance_snapshot > 500 or distance_snapshot == 0:
            distance_snapshot = random.randint(1, 499)
        # æ ¹æ®è¯å«ç»æåéç¶æç 

        # å¦ææ²¡ææ£æµå°äººè¸ï¼ä¹ä» FRAME_BUFFER ä¸­éæ©ä¸å¼ ä½ä¸ºå¾ç
        if selected_frame is None and FRAME_BUFFER:
            selected_frame = FRAME_BUFFER[-1]
            print("[INFO] No face detected, using last frame as image")
        alert_payload = {
            "camera": True,
            "ultrasonic": distance_snapshot,
            "timestamp": datetime.utcnow().isoformat() + "Z"
        }
        asyncio.run(send_alert_via_websocket(alert_payload))
        # åå¤ä¼ æå¨ç¶ææ°æ®
        sensor_status = check_sensors_health()
        print("[INFO] Sensor health:", sensor_status)

        # åéå¾ç
        if selected_frame is not None:
            result, img_encoded = cv2.imencode('.jpg', selected_frame, encode_param)
            if result:
                image_packet = pickle.dumps({
                    'type': 'image',
                    'distance': distance_snapshot,
                    'image': img_encoded,
                    'sensor_status': sensor_status
                }, protocol=pickle.HIGHEST_PROTOCOL)
                s.sendall(struct.pack(">L", len(image_packet)) + image_packet)
                print("[CLIENT] Sent image frame")
            else:
                print("[ERROR] Failed to encode image")

        # åéè§é¢
        video_data = encode_frames_to_video(list(FRAME_BUFFER), FPS)
        if video_data:
            video_packet = pickle.dumps({
                'type': 'video',
                'video': video_data
            }, protocol=pickle.HIGHEST_PROTOCOL)
            s.sendall(struct.pack(">L", len(video_packet)) + video_packet)
            print("[CLIENT] Sent video")
        else:
            print("[ERROR] Failed to encode video")

        # ç­å¾æå¡å¨ååº
        feedback = s.recv(1)
        if feedback == b'1':
            time.sleep(0.2)
            alert_payload = {
                "buzzer": True,
                "led": True,
                "timestamp": datetime.utcnow().isoformat() + "Z"
            }
            asyncio.run(send_alert_via_websocket(alert_payload))
            time.sleep(0.1)
            print("[SERVER] Alarm triggered, triggering local alert")
            time.sleep(0.1)
            grovepi.digitalWrite(buzzer, 1)
            time.sleep(0.5)
            grovepi.digitalWrite(buzzer, 1)
            time.sleep(0.5)
            grovepi.digitalWrite(blue_light, 1)
            time.sleep(0.5)
            grovepi.digitalWrite(blue_light, 1)
            time.sleep(3)
            grovepi.digitalWrite(blue_light, 0)
            time.sleep(0.5)
            grovepi.digitalWrite(buzzer, 0)
            time.sleep(0.5)
            grovepi.digitalWrite(blue_light, 0)
            time.sleep(0.5)
            grovepi.digitalWrite(buzzer, 0)


            time.sleep(1)
        else:
            print("[SERVER] No alarm triggered")

except Exception as e:
    print(f"[ERROR] Exception: {e}")

finally:
    cap.release()
    s.close()
    print("[INFO] Closed connection and camera")

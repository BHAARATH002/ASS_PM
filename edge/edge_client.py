import cv2
import pickle
import socket
import struct
import time
from datetime import datetime
from collections import deque
import grovepi
import os

# GrovePi 端口定义
ultrasonic_ranger = 4
blue_light = 3
buzzer = 8

# 初始化 GrovePi 引脚
grovepi.pinMode(blue_light, "OUTPUT")
grovepi.pinMode(buzzer, "OUTPUT")

# 服务器 IP 和端口
ip = '192.168.164.213'  # 改成你的服务器 IP
port = 12346

# 连接服务器
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((ip, port))
print('Connected to server')

# 摄像头配置
cap = cv2.VideoCapture(0)
FPS = 10  # 帧率设置为 10，适合树莓派
VIDEO_SECONDS = 10
FRAME_BUFFER = deque(maxlen=FPS * VIDEO_SECONDS)
encode_param = [int(cv2.IMWRITE_JPEG_QUALITY), 90]

# 加载 OpenCV 的人脸检测模型
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')

# 保存帧列表为视频
def save_video_from_frames(frames, filename, fps=10):
    if not frames:
        return
    height, width, _ = frames[0].shape
    fourcc = cv2.VideoWriter_fourcc(*'XVID')
    out = cv2.VideoWriter(filename, fourcc, fps, (width, height))
    for frame in frames:
        out.write(frame)
    out.release()

try:
    while True:
        FRAME_BUFFER.clear()  # 每10秒重新记录帧

        faces_detected = False
        distance_snapshot = 0

        # 每10秒采集图像
        for _ in range(FPS * VIDEO_SECONDS):
            time.sleep(1 / FPS)

            distance = grovepi.ultrasonicRead(ultrasonic_ranger)
            if distance == -1 or distance is None:
                distance = 0
            distance_snapshot = distance

            ret, frame = cap.read()
            if not ret:
                continue

            FRAME_BUFFER.append(frame.copy())

            # 检测人脸
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))
            if len(faces) > 0:
                faces_detected = True

        # 10秒采集完毕后统一判断和发送
        if faces_detected:
            print("检测到人脸，start send")

            # 发送图像和距离
            result, img_encoded = cv2.imencode('.jpg', frame, encode_param)
            data = pickle.dumps({'type': 'image', 'distance': distance_snapshot, 'image': img_encoded}, 0)
            size = len(data)
            s.sendall(struct.pack(">L", size) + data)

            # 接收服务器反馈
            feedback = s.recv(1)
            if feedback == b'1':
                grovepi.digitalWrite(blue_light, 1)
                grovepi.digitalWrite(buzzer, 1)
                print("** ALERT: Light and buzzer ON **")
                time.sleep(2)
                grovepi.digitalWrite(blue_light, 0)
                grovepi.digitalWrite(buzzer, 0)
            else:
                print("No alert")

            # 保存并发送视频
            video_filename = "last10s.avi"
            save_video_from_frames(list(FRAME_BUFFER), video_filename, FPS)
            with open(video_filename, 'rb') as f:
                video_data = f.read()
            video_packet = pickle.dumps({'type': 'video', 'video': video_data})
            s.sendall(struct.pack(">L", len(video_packet)) + video_packet)
            print("[CLIENT] Sent last 10 seconds of video")
            os.remove(video_filename)
        else:
            print("10秒内未检测到人脸,no face")


finally:
    cap.release()
    s.close()
# server.py
import cv2
import socket
import pickle
import struct
import os
from datetime import datetime

# 保存目录
image_dir = "./images"
video_dir = "./videos"
os.makedirs(image_dir, exist_ok=True)
os.makedirs(video_dir, exist_ok=True)

# 启动服务器
host = '0.0.0.0'
port = 12346
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((host, port))
s.listen(5)
print("Server listening...")

conn, addr = s.accept()
print(f"Connected by {addr}")

def recv_full_message(conn):
    """从 socket 接收完整一包 pickle 数据"""
    data = b""
    payload_size = struct.calcsize(">L")

    while len(data) < payload_size:
        data += conn.recv(4096)
    packed_msg_size = data[:payload_size]
    data = data[payload_size:]
    msg_size = struct.unpack(">L", packed_msg_size)[0]

    while len(data) < msg_size:
        data += conn.recv(4096)

    return data[:msg_size]

try:
    while True:
        # 先接收图像数据（含距离）
        image_data = recv_full_message(conn)
        payload = pickle.loads(image_data, fix_imports=True, encoding="bytes")

        if payload.get('type') == 'image':
            distance = payload['distance']
            img_data = payload['image']
            frame = cv2.imdecode(img_data, cv2.IMREAD_COLOR)

            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            image_filename = f"{image_dir}/image_{timestamp}_dist{distance}.jpg"
            cv2.imwrite(image_filename, frame)
            print(f"Saved image: {image_filename}, Distance: {distance} cm")

            # 判断距离并反馈
            if distance > 30:
                conn.sendall(b'1')
                print("Sent Alert: 1")
            else:
                conn.sendall(b'0')
                print("Sent Alert: 0")
        else:
            print("Unexpected message type in image slot")

        # 然后接收视频数据
        video_data = recv_full_message(conn)
        video_payload = pickle.loads(video_data, fix_imports=True, encoding="bytes")

        if video_payload.get('type') == 'video':
            video_bytes = video_payload['video']
            video_filename = f"{video_dir}/video_{timestamp}.avi"
            with open(video_filename, 'wb') as f:
                f.write(video_bytes)
            print(f"Saved video: {video_filename}")
        else:
            print("Unexpected message type in video slot")

finally:
    conn.close()
    s.close()

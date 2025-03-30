import base64
from datetime import datetime

# Read and encode the image
with open("video.mp4", "rb") as image_file:
    base64_string = base64.b64encode(image_file.read()).decode("utf-8")

# Print or save the encoded string
print(base64_string)
print(datetime.now().timestamp())

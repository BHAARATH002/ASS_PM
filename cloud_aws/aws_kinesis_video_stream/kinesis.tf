provider "aws" {
  region = "us-east-1"
}
resource "aws_kinesis_video_stream" "video_stream" {
  name                = "intruder-detection-stream"
  media_type          = "video/h264"
  data_retention_in_hours = 24
}

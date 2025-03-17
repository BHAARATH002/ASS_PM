resource "aws_s3_bucket" "intruder_images" {
  bucket = "intruder-images-bucket"
  acl    = "private"
}

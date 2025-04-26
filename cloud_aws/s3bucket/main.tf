resource "aws_s3_bucket" "intruder_images" {
  bucket = "intruder-images-bucket"
  acl    = "private"
}
resource "aws_s3_bucket_cors_configuration" "intruder_images_cors" {
  bucket = aws_s3_bucket.intruder_images.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
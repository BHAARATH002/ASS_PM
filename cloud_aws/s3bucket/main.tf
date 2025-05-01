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

resource "aws_s3_bucket_lifecycle_configuration" "intruder_images_lifecycle" {
  bucket = aws_s3_bucket.intruder_images.id

  rule {
    id     = "transition_images_to_glacier"
    status = "Enabled"

    filter {
      prefix = "image/"
    }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 210 # 30 days in S3 + 180 days in Glacier
    }
  }

  rule {
    id     = "transition_videos_to_glacier"
    status = "Enabled"

    filter {
      prefix = "video/"
    }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 210 # 30 + 180
    }
  }
}
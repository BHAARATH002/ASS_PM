terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
resource "aws_iam_role" "ec2_role" {
  name = "WebServerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_policy" "ec2_policy" {
  name        = "EC2DBKinesisPolicy"
  description = "Allows EC2 to access RDS, DynamoDB, and Kinesis for video streaming"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "rds-data:ExecuteStatement"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "kinesisvideo:GetDataEndpoint",
          "kinesisvideo:GetMedia"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::intruder-images-bucket",
          "arn:aws:s3:::intruder-images-bucket/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_attach" {
  policy_arn = aws_iam_policy.ec2_policy.arn
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "WebServerInstanceProfile"
  role = aws_iam_role.ec2_role.name
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
resource "aws_iam_role" "raspberry_pi_role" {
  name = "RaspberryPiRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "iot.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "raspberry_pi_policy" {
  name        = "customRaspberryPiPolicy"
  description = "Policy for Raspberry Pi to send data to IoT and Kinesis"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iot:Publish",
          "iot:Connect",
          "iot:Receive",
          "iot:Subscribe"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "kinesisvideo:PutMedia"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "raspberry_pi_attach" {
  policy_arn = aws_iam_policy.raspberry_pi_policy.arn
  role       = aws_iam_role.raspberry_pi_role.name
}

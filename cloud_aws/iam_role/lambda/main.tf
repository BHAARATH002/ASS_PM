terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
resource "aws_iam_role" "lambda_exec" {
  name = "LambdaExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = ["lambda.amazonaws.com", "iot.amazonaws.com"]
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "LambdaPolicy"
  description = "Allows Lambda to access DynamoDB & S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # CloudWatch Logging permissions
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      # Lambda permissions
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "rds-data:ExecuteStatement",
          "s3:PutObject",
          "sns:Publish",
          "lambda:InvokeFunction"
        ],
        Resource = "*"
      },
      # IoT permissions
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
      # Kinesis Video Streams permissions
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

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_exec.name
}

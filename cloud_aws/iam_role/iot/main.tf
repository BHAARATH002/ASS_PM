terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
resource "aws_iam_role" "iot_role" {
  name = "IoTCoreLambdaTriggerRole"

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
resource "aws_iam_policy" "iot_lambda_policy" {
  name        = "IoTLambdaInvokePolicy"
  description = "Allows IoT Core to trigger Lambda when a new intruder image is detected"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "iot_attach" {
  policy_arn = aws_iam_policy.iot_lambda_policy.arn
  role       = aws_iam_role.iot_role.name
}

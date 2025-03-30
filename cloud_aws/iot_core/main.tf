variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

# Create an IoT Certificate
resource "aws_iot_certificate" "intruder_cert" {
  active = true
}

resource "aws_iot_domain_configuration" "intruder_domain" {
  name           = "iot:Data-ATS"
  domain_name    = "intruder-domain"
  service_type = "DATA"
  status       = "ENABLED"

  tls_config {
    security_policy = "IoTSecurityPolicy_TLS13_1_2_2022_10"
  }
}

resource "aws_iot_thing" "intruder_thing" {
  name = "IntruderThing"
}

resource "aws_iot_policy" "intruder_thing_policy" {
  name   = "IntruderThingPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["iot:Connect"],
        Resource = [
          "arn:aws:iot:us-east-1:${var.aws_account_id}:client/sdk-java",
          "arn:aws:iot:us-east-1:${var.aws_account_id}:client/basicPubSub",
          "arn:aws:iot:us-east-1:${var.aws_account_id}:client/sdk-nodejs-*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = ["iot:Publish"],
        Resource = [
          "arn:aws:iot:us-east-1:${var.aws_account_id}:topic/sdk/test/java",
          "arn:aws:iot:us-east-1:${var.aws_account_id}:topic/sdk/test/python",
          "arn:aws:iot:us-east-1:${var.aws_account_id}:topic/sdk/test/js"
        ]
      },
      {
        Effect   = "Allow",
        Action   = ["iot:Subscribe"],
        Resource = [
          "arn:aws:iot:us-east-1:${var.aws_account_id}:topicfilter/sdk/test/java",
          "arn:aws:iot:us-east-1:${var.aws_account_id}:topicfilter/sdk/test/python",
          "arn:aws:iot:us-east-1:${var.aws_account_id}:topicfilter/sdk/test/js"
        ]
      }
    ]
  })
}

# Attach Certificate to IoT Thing
resource "aws_iot_thing_principal_attachment" "intruder_cert_attachment" {
  thing     = aws_iot_thing.intruder_thing.name
  principal = aws_iot_certificate.intruder_cert.arn
}

# Attach Policy to Certificate
resource "aws_iot_policy_attachment" "intruder_policy_attachment" {
  policy = aws_iot_policy.intruder_thing_policy.name
  target = aws_iot_certificate.intruder_cert.arn
}

resource "aws_iot_topic_rule" "intruder_rule" {
  name        = "IntruderRule"
  enabled     = true
  sql         = "SELECT * FROM 'intruder/topic'"
  sql_version = "2016-03-23"

  lambda {
    function_arn = "arn:aws:lambda:us-east-1:${var.aws_account_id}:function:IntruderAlertLambda"
  }
}

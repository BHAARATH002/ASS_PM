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
        Action   = [
            "iot:Publish",
            "iot:Receive",
            "iot:Subscribe",
            "iot:PublishRetain"
            ],
        Resource = [
          "arn:aws:iot:us-east-1:${var.aws_account_id}:topic/sdk/test/java",
          "arn:aws:iot:us-east-1:${var.aws_account_id}:topic/sdk/test/python",
          "arn:aws:iot:us-east-1:${var.aws_account_id}:topic/sdk/test/python1",
          "arn:aws:iot:us-east-1:${var.aws_account_id}:topic/sdk/test/python2",
          "arn:aws:iot:us-east-1:${var.aws_account_id}:topic/sdk/test/js"
        ]
      },
      {
        Effect   = "Allow",
        Action   = [
            "iot:Subscribe",
            "iot:Receive"
            ],
        Resource = [
          "arn:aws:iot:us-east-1:${var.aws_account_id}:topicfilter/sdk/test/java",
          "arn:aws:iot:us-east-1:${var.aws_account_id}:topicfilter/sdk/test/python",
          "arn:aws:iot:us-east-1:${var.aws_account_id}:topicfilter/sdk/test/python1",
          "arn:aws:iot:us-east-1:${var.aws_account_id}:topicfilter/sdk/test/python1",
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
  name        = "Intruder_To_Lambda"
  enabled     = true
  sql         = "SELECT * FROM 'sdk/test/python'"
  sql_version = "2016-03-23"

  lambda {
    function_arn = "arn:aws:lambda:us-east-1:${var.aws_account_id}:function:IntruderAlertLambda"
  }
}

resource "aws_cloudwatch_log_group" "iot_logs" {
  name              = "AWSIotLogsV2"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "iot_device_state_logs" {
  name              = "device_state"
  retention_in_days = 30
}

resource "aws_iam_role" "iot_reply_role" {
  name = "IOT_reply_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "iot.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "iot_rule_policy" {
  name        = "aws-iot-rule-Lambda_To_Device-action-1-role-IOT_reply_role"
  description = "IAM policy for IoT rule to send logs to CloudWatch"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:us-east-1:746441023300:log-group:AWSIotLogsV2:*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "iot_rule_policy_device" {
  name        = "aws-iot-rule-Device_state-action-1-role-IOT_reply_role"
  description = "IAM policy for IoT rule to send logs to CloudWatch"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:us-east-1:746441023300:log-group:device_state:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "iot_reply_role_attach" {
  role       = aws_iam_role.iot_reply_role.name
  policy_arn = aws_iam_policy.iot_rule_policy.arn
}

resource "aws_iam_role_policy_attachment" "iot_reply_role_attach_policy2" {
  role       = aws_iam_role.iot_reply_role.name
  policy_arn = aws_iam_policy.iot_rule_policy_device.arn
}

resource "aws_iot_topic_rule" "intruder_rule_outgoing" {
    enabled     = true
    name        = "Lambda_To_Device"
    sql         = "SELECT * FROM 'sdk/test/python1'"
    sql_version = "2016-03-23"

    cloudwatch_logs {
        batch_mode     = false
        log_group_name = aws_cloudwatch_log_group.iot_logs.name
        role_arn       = aws_iam_role.iot_reply_role.arn
    }
}

resource "aws_iot_topic_rule" "device_state" {
    enabled     = true
    name        = "Device_state"
    sql         = "SELECT * FROM 'sdk/test/python2'"
    sql_version = "2016-03-23"

    cloudwatch_logs {
        batch_mode     = false
        log_group_name = aws_cloudwatch_log_group.iot_device_state_logs.name
        role_arn       = aws_iam_role.iot_reply_role.arn
    }
}
provider "aws" {
  region = "us-east-1"
}
resource "aws_iot_topic_rule" "iot_rule" {
  name        = "intruder_alert_rule"
  description = "Processes intruder alerts"
  enabled     = true
  sql = "SELECT * FROM 'intruder/alert'"
  sql_version = "2016-03-23"

  lambda {
    function_arn = aws_lambda_function.intruder_alert.arn
  }
}

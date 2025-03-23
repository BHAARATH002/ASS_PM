resource "aws_iot_topic_rule" "iot_rule" {
  name        = "intruder_alert_rule"
  description = "Processes intruder alerts"
  enabled     = true
  sql = "SELECT * FROM 'intruder/alert'"
  sql_version = "2016-03-23"

  lambda {
    function_arn = "arn:aws:lambda:us-east-1:746441023300:function:IntruderAlertLambda"
  }
}

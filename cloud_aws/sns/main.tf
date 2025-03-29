resource "aws_sns_topic" "intruder_alerts" {
  name = "intruder-alerts"
}

resource "aws_sns_topic_subscription" "email_subscription_1" {
  topic_arn = aws_sns_topic.intruder_alerts.arn
  protocol  = "email"
  endpoint  = "bhaarathan23@hotmail.sg" # Change this to your first email
}

resource "aws_sns_topic_subscription" "email_subscription_2" {
  topic_arn = aws_sns_topic.intruder_alerts.arn
  protocol  = "email"
  endpoint  = "e1221839@u.nus.edu" # Change this to your second email
}

resource "aws_sns_topic_subscription" "email_subscription_3" {
  topic_arn = aws_sns_topic.intruder_alerts.arn
  protocol  = "email"
  endpoint  = "e1351221@u.nus.edu" # Change this to your third email
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.intruder_alerts.arn

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sns:Publish",
      "Resource": "${aws_sns_topic.intruder_alerts.arn}"
    }
  ]
}
POLICY
}

output "sns_topic_arn" {
  value = aws_sns_topic.intruder_alerts.arn
}

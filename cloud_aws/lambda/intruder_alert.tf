resource "aws_lambda_function" "intruder_alert" {
  function_name    = "IntruderAlertLambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  runtime         = "python3.8"
  filename        = "lambda_function_payload.zip"
}

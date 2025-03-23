resource "aws_lambda_function" "intruder_alert" {
  function_name    = "IntruderAlertLambda"
  role             = "arn:aws:iam::746441023300:role/LambdaExecutionRole"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip") # Ensures new deployment when ZIP changes
}

resource "aws_lambda_function" "intruder_alert" {
  function_name    = "IntruderAlertLambda"
  role             = "arn:aws:iam::746441023300:role/LambdaExecutionRole"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip") # Ensures new deployment when ZIP changes

  # Set the timeout to a higher value (e.g., 10 seconds)
  timeout          = 10  # Adjust based on your requirements
  memory_size      = 128  # Adjust memory size if necessary
}

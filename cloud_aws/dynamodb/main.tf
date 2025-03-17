resource "aws_dynamodb_table" "intruder_logs" {
  name         = "intruderLogs"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "device_id"

  attribute {
    name = "device_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }
}

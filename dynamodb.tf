resource "aws_dynamodb_table" "workflow_logs" {
  name         = "${local.name_prefix}-logs"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "workflow_id"

  attribute {
    name = "workflow_id"
    type = "S"
  }
}

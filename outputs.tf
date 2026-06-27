output "step_functions_state_machine_arn" {
  description = "ARN of the Step Functions State Machine"
  value       = aws_sfn_state_machine.workflow.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.workflow_logs.name
}

output "job_generator_lambda_arn" {
  description = "ARN of the Job Generator Lambda"
  value       = aws_lambda_function.job_generator.arn
}

output "validator_lambda_arn" {
  description = "ARN of the Validator Lambda"
  value       = aws_lambda_function.validator.arn
}

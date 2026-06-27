resource "aws_cloudwatch_log_group" "sfn_log_group" {
  name              = "/aws/vendedlogs/states/${local.name_prefix}-workflow"
  retention_in_days = 7
}

resource "aws_sfn_state_machine" "workflow" {
  name     = "${local.name_prefix}-workflow"
  role_arn = aws_iam_role.sfn_exec.arn

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.sfn_log_group.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  definition = jsonencode({
    Comment = "Enterprise Serverless Workflow Orchestration",
    StartAt = "GenerateJob",
    States = {
      GenerateJob = {
        Type       = "Task",
        Resource   = aws_lambda_function.job_generator.arn,
        Next       = "ValidateJob",
        ResultPath = "$.job"
      },
      ValidateJob = {
        Type       = "Task",
        Resource   = aws_lambda_function.validator.arn,
        Next       = "ChoiceState",
        ResultPath = "$.validation"
      },
      ChoiceState = {
        Type = "Choice",
        Choices = [
          {
            Variable     = "$.validation.status",
            StringEquals = "SUCCESS",
            Next         = "SuccessLogger"
          },
          {
            Variable     = "$.validation.status",
            StringEquals = "FAILED",
            Next         = "FailureLogger"
          }
        ],
        Default = "FailureLogger"
      },
      SuccessLogger = {
        Type     = "Task",
        Resource = "arn:aws:states:::dynamodb:putItem",
        Parameters = {
          TableName = aws_dynamodb_table.workflow_logs.name,
          Item = {
            workflow_id = {
              "S.$" = "$.job.workflow_id"
            },
            timestamp = {
              "S.$" = "$.job.timestamp"
            },
            status = {
              "S" = "SUCCESS"
            },
            validation_result = {
              "S.$" = "$.validation.status"
            },
            execution_id = {
              "S.$" = "$$.Execution.Id"
            },
            payload = {
              "S.$" = "States.JsonToString($.job)"
            }
          }
        },
        End = true
      },
      FailureLogger = {
        Type     = "Task",
        Resource = "arn:aws:states:::dynamodb:putItem",
        Parameters = {
          TableName = aws_dynamodb_table.workflow_logs.name,
          Item = {
            workflow_id = {
              "S.$" = "$.job.workflow_id"
            },
            timestamp = {
              "S.$" = "$.job.timestamp"
            },
            status = {
              "S" = "FAILED"
            },
            validation_result = {
              "S.$" = "$.validation.status"
            },
            execution_id = {
              "S.$" = "$$.Execution.Id"
            },
            payload = {
              "S.$" = "States.JsonToString($.job)"
            }
          }
        },
        End = true
      }
    }
  })
}

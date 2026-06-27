# IAM Role for Lambda
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${local.name_prefix}-lambda-exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# Basic execution policy for Lambda (CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# IAM Role for Step Functions
data "aws_iam_policy_document" "sfn_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sfn_exec" {
  name               = "${local.name_prefix}-sfn-exec"
  assume_role_policy = data.aws_iam_policy_document.sfn_assume_role.json
}

# Step Functions Policy (invoke Lambda, put item in DynamoDB, and CloudWatch logs)
data "aws_iam_policy_document" "sfn_policy" {
  statement {
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      aws_lambda_function.job_generator.arn,
      aws_lambda_function.validator.arn
    ]
  }

  statement {
    actions = [
      "dynamodb:PutItem"
    ]
    resources = [
      aws_dynamodb_table.workflow_logs.arn
    ]
  }

  statement {
    actions = [
      "logs:CreateLogDelivery",
      "logs:CreateLogStream",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutLogEvents",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "sfn_policy_attachment" {
  name   = "${local.name_prefix}-sfn-policy"
  role   = aws_iam_role.sfn_exec.id
  policy = data.aws_iam_policy_document.sfn_policy.json
}

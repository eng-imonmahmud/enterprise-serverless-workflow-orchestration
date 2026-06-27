data "archive_file" "job_generator_zip" {
  type        = "zip"
  source_file = "${path.module}/src/job_generator.py"
  output_path = "${path.module}/job_generator.zip"
}

resource "aws_lambda_function" "job_generator" {
  filename         = data.archive_file.job_generator_zip.output_path
  function_name    = "${local.name_prefix}-job-generator"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "job_generator.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.job_generator_zip.output_base64sha256

  environment {
    variables = {
      REGION = var.aws_region
    }
  }
}

data "archive_file" "validator_zip" {
  type        = "zip"
  source_file = "${path.module}/src/validator.py"
  output_path = "${path.module}/validator.zip"
}

resource "aws_lambda_function" "validator" {
  filename         = data.archive_file.validator_zip.output_path
  function_name    = "${local.name_prefix}-validator"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "validator.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.validator_zip.output_base64sha256
}

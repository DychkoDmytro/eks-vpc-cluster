provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "lambda_role" {
  name = "mlops-train-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "step_functions_role" {
  name = "mlops-train-step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "step_functions_policy" {
  name = "mlops-train-step-functions-policy"
  role = aws_iam_role.step_functions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "lambda:InvokeFunction"
      ]
      Resource = [
        aws_lambda_function.validate.arn,
        aws_lambda_function.log_metrics.arn
      ]
    }]
  })
}

resource "aws_lambda_function" "validate" {
  function_name = "mlops-train-validate"
  role          = aws_iam_role.lambda_role.arn

  filename         = "${path.module}/lambda/validate.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/validate.zip")

  handler = "validate.lambda_handler"
  runtime = "python3.12"
}

resource "aws_lambda_function" "log_metrics" {
  function_name = "mlops-train-log-metrics"
  role          = aws_iam_role.lambda_role.arn

  filename         = "${path.module}/lambda/log_metrics.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/log_metrics.zip")

  handler = "log_metrics.lambda_handler"
  runtime = "python3.12"
}

resource "aws_sfn_state_machine" "train_pipeline" {
  name     = "mlops-train-pipeline"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = jsonencode({
    Comment = "MLOps training automation workflow"
    StartAt = "ValidateData"

    States = {
      ValidateData = {
        Type     = "Task"
        Resource = aws_lambda_function.validate.arn
        Next     = "LogMetrics"
      }

      LogMetrics = {
        Type     = "Task"
        Resource = aws_lambda_function.log_metrics.arn
        End      = true
      }
    }
  })
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lab-lambda-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = { Service = "lambda.amazonaws.com" },
        Effect = "Allow",
        Sid = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_secrets_policy" {
  name = "lambda-read-secret-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = aws_secretsmanager_secret.db_secret.arn
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt"
        ],
        Resource = aws_kms_key.lab_kms.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_secret_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_secrets_policy.arn
}

# Lambda function - requires ../lambda.zip to exist prior to `terraform apply`
resource "aws_lambda_function" "lab_lambda" {
  function_name = var.lambda_name
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "app.handler"
  runtime       = "python3.11"
  filename      = "../lambda.zip"
  source_code_hash = filebase64sha256("../lambda.zip")
  timeout       = 10
  environment {
    variables = {
      DB_SECRET_NAME = aws_secretsmanager_secret.db_secret.name
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.lab_lambda.function_name}"
  retention_in_days = 7
}

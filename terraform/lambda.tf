# Lambda function
resource "aws_lambda_function" "main" {
  function_name = "${local.name_prefix}-${var.lambda_function_name}"
  role         = aws_iam_role.lambda_execution_role.arn
  
  s3_bucket = aws_s3_bucket.lambda_artifacts.id
  s3_key    = aws_s3_object.lambda_package.key
  
  handler = var.lambda_handler
  runtime = var.lambda_runtime
  timeout = var.lambda_timeout
  
  memory_size = var.lambda_memory_size
  
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  environment {
    variables = {
      ENVIRONMENT = var.environment
      PROJECT     = var.project_name
    }
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_cloudwatch_log_group.lambda_logs
  ]
  
  tags = local.common_tags
}

# Lambda function alias for deployment
resource "aws_lambda_alias" "main" {
  name             = var.environment
  description      = "Alias for ${var.environment} environment"
  function_name    = aws_lambda_function.main.function_name
  function_version = aws_lambda_function.main.version
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.main.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.main.arn
}

output "lambda_function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.main.invoke_arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.arn
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for Lambda packages"
  value       = aws_s3_bucket.lambda_artifacts.id
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

output "api_gateway_url" {
  description = "API Gateway URL"
  value       = var.enable_api_gateway ? aws_api_gateway_deployment.main[0].invoke_url : "API Gateway not enabled"
}

output "api_gateway_test_url" {
  description = "API Gateway test URL"
  value       = var.enable_api_gateway ? "${aws_api_gateway_deployment.main[0].invoke_url}/hello" : "API Gateway not enabled"
}

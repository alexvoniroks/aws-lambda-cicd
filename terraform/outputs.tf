output "artifact_bucket" {
  value = aws_s3_bucket.artifacts.id
}

output "lambda_name" {
  value = aws_lambda_function.lab_lambda.function_name
}

output "github_oidc_role_arn" {
  value = aws_iam_role.github_oidc_role.arn
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.db_secret.arn
}

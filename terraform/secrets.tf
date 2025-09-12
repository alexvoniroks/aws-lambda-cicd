resource "aws_secretsmanager_secret" "db_secret" {
  name       = "lab/db-secret"
  description = "Demo DB secret for Lambda"
  kms_key_id = aws_kms_key.lab_kms.arn
}

resource "aws_secretsmanager_secret_version" "db_secret_value" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({ username = "admin", password = "ChangeMe123!" })
}

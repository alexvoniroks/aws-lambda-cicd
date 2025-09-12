resource "aws_kms_key" "lab_kms" {
  description             = "KMS key for lab secrets and S3 encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "lab_alias" {
  name          = "alias/lab-ci-cd-key"
  target_key_id = aws_kms_key.lab_kms.key_id
}

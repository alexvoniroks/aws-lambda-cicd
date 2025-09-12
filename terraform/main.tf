resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "lambda-ci-cd-artifacts-${random_id.bucket_id.hex}"
  acl    = "private"

  lifecycle_rule {
    id      = "auto-delete-old"
    enabled = true
    expiration {
      days = 7
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts_enc" {
  bucket = aws_s3_bucket.artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.lab_kms.arn
    }
  }
}

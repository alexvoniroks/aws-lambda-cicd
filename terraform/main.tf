resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "lambda-ci-cd-artifacts-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket_acl" "artifacts_acl" {
  bucket = aws_s3_bucket.artifacts.id
  acl    = "private"
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

resource "aws_s3_bucket_lifecycle_configuration" "artifacts_lifecycle" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    id     = "auto-delete-old"
    status = "Enabled"

    filter {} # applies to all objects in the bucket

    expiration {
      days = 7
    }
  }
}

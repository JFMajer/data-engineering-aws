resource "aws_s3_bucket" "bucket" {
  bucket_prefix = var.bucket_prefix
  force_destroy = true

  tags = {
    Name        = var.bucket_prefix
    Environment = "Dev"
  }
}
resource "aws_s3_bucket" "main" {
  count  = var.create_bucket ? 1 : 0
  bucket = "${local.environment}-${local.service}-model"
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "distilbert" {
  count               = var.create_bucket ? 1 : 0
  bucket              = aws_s3_bucket.distilbert.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}
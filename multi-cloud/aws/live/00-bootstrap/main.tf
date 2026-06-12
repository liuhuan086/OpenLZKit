locals {
  create_state_bucket = var.state_bucket_name != null
  create_lock_table   = var.lock_table_name != null
  create_ci_cd_role   = var.ci_cd_role_name != null
  create_kms_key      = local.create_state_bucket && var.create_kms_key

  ci_cd_policy_attachments = {
    for policy_arn in var.ci_cd_managed_policy_arns :
    policy_arn => policy_arn
    if local.create_ci_cd_role
  }
}

resource "aws_kms_key" "state" {
  count = local.create_kms_key ? 1 : 0

  description             = "Terraform state encryption key."
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = true
  tags                    = var.common_tags
}

resource "aws_kms_alias" "state" {
  count = local.create_kms_key ? 1 : 0

  name          = "alias/terraform-state"
  target_key_id = aws_kms_key.state[0].key_id
}

resource "aws_s3_bucket" "state" {
  count = local.create_state_bucket ? 1 : 0

  bucket        = var.state_bucket_name
  force_destroy = var.state_bucket_force_destroy
  tags          = var.common_tags
}

resource "aws_s3_bucket_public_access_block" "state" {
  count = local.create_state_bucket ? 1 : 0

  bucket                  = aws_s3_bucket.state[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "state" {
  count = local.create_state_bucket ? 1 : 0

  bucket = aws_s3_bucket.state[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "state" {
  count = local.create_state_bucket ? 1 : 0

  bucket = aws_s3_bucket.state[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  count = local.create_state_bucket ? 1 : 0

  bucket = aws_s3_bucket.state[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = local.create_kms_key ? aws_kms_key.state[0].arn : null
      sse_algorithm     = local.create_kms_key ? "aws:kms" : "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "state" {
  count = local.create_state_bucket ? 1 : 0

  bucket = aws_s3_bucket.state[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyInsecureTransport"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource = [
        aws_s3_bucket.state[0].arn,
        "${aws_s3_bucket.state[0].arn}/*",
      ]
      Condition = {
        Bool = {
          "aws:SecureTransport" = "false"
        }
      }
    }]
  })
}

resource "aws_dynamodb_table" "lock" {
  count = local.create_lock_table ? 1 : 0

  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  tags         = var.common_tags

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_iam_role" "ci_cd" {
  count = local.create_ci_cd_role ? 1 : 0

  name = var.ci_cd_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        AWS = var.ci_cd_trusted_principal_arns
      }
    }]
  })
  tags = var.common_tags

  lifecycle {
    precondition {
      condition     = length(var.ci_cd_trusted_principal_arns) > 0
      error_message = "ci_cd_trusted_principal_arns must not be empty when ci_cd_role_name is set."
    }
  }
}

resource "aws_iam_role_policy_attachment" "ci_cd" {
  for_each = local.ci_cd_policy_attachments

  role       = aws_iam_role.ci_cd[0].name
  policy_arn = each.value
}

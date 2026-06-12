provider "alicloud" {
  region = var.region
}

data "alicloud_account" "this" {}

# --- Resource Directory (org root) --------------------------------------------
# Creating this resource enables the Resource Directory so live/10-org can build
# folders on top of it.
resource "alicloud_resource_manager_resource_directory" "this" {
  count = var.enable_resource_directory ? 1 : 0
}

# --- Remote state bucket ------------------------------------------------------
resource "alicloud_oss_bucket" "state" {
  bucket = var.state_bucket_name

  versioning {
    status = "Enabled"
  }

  server_side_encryption_rule {
    sse_algorithm = "AES256"
  }

  tags = var.tags
}

resource "alicloud_oss_bucket_acl" "state" {
  bucket = alicloud_oss_bucket.state.bucket
  acl    = "private"
}

# --- GitHub Actions OIDC federation for CI/CD ---------------------------------
resource "alicloud_ims_oidc_provider" "github" {
  oidc_provider_name = "github-actions"
  issuer_url         = "https://token.actions.githubusercontent.com"
  client_ids         = ["sts.aliyuncs.com"]
}

# Plan-only CI role: read state + describe resources, no writes.
resource "alicloud_ram_role" "cicd_plan" {
  role_name   = "lz-cicd-plan"
  description = "CI/CD plan/validate role assumed by GitHub Actions via OIDC."
  assume_role_policy_document = jsonencode({
    Version = "1"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Federated = ["acs:ram::${data.alicloud_account.this.id}:oidc-provider/${alicloud_ims_oidc_provider.github.oidc_provider_name}"]
      }
      Condition = {
        StringEquals = {
          "oidc:aud" = "sts.aliyuncs.com"
          "oidc:iss" = "https://token.actions.githubusercontent.com"
        }
        StringLike = {
          "oidc:sub" = "repo:${var.github_owner}/${var.github_repo}:*"
        }
      }
    }]
  })
}

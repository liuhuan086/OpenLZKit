provider "tencentcloud" {
  region = var.region
}

# --- Remote state bucket ---------------------------------------------------
resource "tencentcloud_cos_bucket" "state" {
  bucket               = var.state_bucket_name
  acl                  = "private"
  versioning_enable    = true
  encryption_algorithm = "AES256"
  tags                 = var.tags
}

# --- CI/CD plan role (assumed via STS; no long-lived SecretKey) -------------
resource "tencentcloud_cam_role" "cicd_plan" {
  name        = "${var.name_prefix}cicd-plan"
  description = "CI/CD plan/validate role assumed via STS from the management account."

  document = jsonencode({
    version = "2.0"
    statement = [{
      effect    = "allow"
      action    = ["name/sts:AssumeRole"]
      principal = { qcs = ["qcs::cam::uin/${var.management_uin}:root"] }
    }]
  })
}

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = ">= 1.230.0"
    }
  }

  # Remote state lives in the OSS bucket provisioned by live/00-bootstrap.
  # Concrete values are supplied at init time via -backend-config to keep the
  # bucket name and account out of the repository:
  #   terraform init -backend-config=backend.hcl
  backend "oss" {
    prefix = "alicloud/10-org"
  }
}

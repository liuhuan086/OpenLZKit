terraform {
  required_version = ">= 1.5.0"

  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = ">= 1.230.0"
    }
  }

  backend "oss" {
    prefix = "alicloud/24-cross-account-access"
  }
}

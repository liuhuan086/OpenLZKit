terraform {
  required_version = ">= 1.5.0"

  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = ">= 1.230.0"
    }
  }

  # Bootstrap runs with LOCAL state: it creates the OSS bucket that later stacks
  # use as their backend. After apply, migrate this stack's state into OSS.
}

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    tencentcloud = {
      source  = "tencentcloudstack/tencentcloud"
      version = ">= 1.81"
    }
  }

  # Bootstrap runs with LOCAL state: it creates the COS bucket that later stacks
  # use as their backend. After apply, migrate this state into the bucket.
}

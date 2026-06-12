terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }
  }

  # Bootstrap runs with LOCAL state: it creates the GCS bucket that later stacks
  # use as their backend. After apply, migrate this state into the bucket.
}

package openlzkit.aws.s3_state

import rego.v1

test_deny_open_public_access_block if {
  result := deny with input as {
    "resource_changes": [{
      "address": "aws_s3_bucket_public_access_block.bad",
      "type": "aws_s3_bucket_public_access_block",
      "change": {"after": {
        "block_public_acls": false,
        "block_public_policy": true,
        "ignore_public_acls": true,
        "restrict_public_buckets": true,
      }},
    }],
  }

  count(result) == 1
}

test_allow_public_access_block if {
  result := deny with input as {
    "resource_changes": [{
      "address": "aws_s3_bucket_public_access_block.good",
      "type": "aws_s3_bucket_public_access_block",
      "change": {"after": {
        "block_public_acls": true,
        "block_public_policy": true,
        "ignore_public_acls": true,
        "restrict_public_buckets": true,
      }},
    }],
  }

  count(result) == 0
}

test_deny_suspended_versioning if {
  result := deny with input as {
    "resource_changes": [{
      "address": "aws_s3_bucket_versioning.bad",
      "type": "aws_s3_bucket_versioning",
      "change": {"after": {"versioning_configuration": [{"status": "Suspended"}]}},
    }],
  }

  count(result) == 1
}

test_allow_default_encryption if {
  result := deny with input as {
    "resource_changes": [{
      "address": "aws_s3_bucket_server_side_encryption_configuration.good",
      "type": "aws_s3_bucket_server_side_encryption_configuration",
      "change": {"after": {"rule": [{
        "apply_server_side_encryption_by_default": [{"sse_algorithm": "aws:kms"}],
      }]}},
    }],
  }

  count(result) == 0
}

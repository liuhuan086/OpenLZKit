package openlzkit.aws.tags

import rego.v1

test_deny_missing_managed_by if {
  result := deny with input as {
    "resource_changes": [{
      "address": "aws_s3_bucket.bad",
      "type": "aws_s3_bucket",
      "change": {"after": {"tags": {"owner": "platform"}}},
    }],
  }

  count(result) == 2
}

test_deny_partial_enterprise_tags if {
  result := deny with input as {
    "resource_changes": [{
      "address": "aws_iam_policy.partial",
      "type": "aws_iam_policy",
      "change": {"after": {"tags": {"managed_by": "terraform", "owner": "platform"}}},
    }],
  }

  count(result) == 1
}

test_allow_managed_resource_tags if {
  result := deny with input as {
    "resource_changes": [{
      "address": "aws_s3_bucket.good",
      "type": "aws_s3_bucket",
      "change": {"after": {"tags": {"managed_by": "terraform"}}},
    }],
  }

  count(result) == 0
}

test_allow_complete_enterprise_tags if {
  result := deny with input as {
    "resource_changes": [{
      "address": "aws_iam_role.good",
      "type": "aws_iam_role",
      "change": {"after": {"tags": {
        "managed_by": "terraform",
        "owner": "platform",
        "cost_center": "cc-1000",
        "env": "prod",
        "project": "landing-zone",
      }}},
    }],
  }

  count(result) == 0
}

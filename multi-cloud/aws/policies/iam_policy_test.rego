package openlzkit.aws.iam_policy

import rego.v1

test_deny_broad_managed_policy if {
  result := deny with input as {
    "resource_changes": [{
      "address": "aws_iam_policy.bad",
      "type": "aws_iam_policy",
      "change": {"after": {
        "name": "platform-admin",
        "policy": json.marshal({
          "Version": "2012-10-17",
          "Statement": [{"Effect": "Allow", "Action": "*", "Resource": "*"}],
        }),
      }},
    }],
  }

  count(result) == 1
}

test_allow_permission_boundary_policy if {
  result := deny with input as {
    "resource_changes": [{
      "address": "aws_iam_policy.boundary",
      "type": "aws_iam_policy",
      "change": {"after": {
        "name": "workload-operator-boundary",
        "policy": json.marshal({
          "Version": "2012-10-17",
          "Statement": [{"Effect": "Allow", "Action": "*", "Resource": "*"}],
        }),
      }},
    }],
  }

  count(result) == 0
}

test_allow_scoped_managed_policy if {
  result := deny with input as {
    "resource_changes": [{
      "address": "aws_iam_policy.good",
      "type": "aws_iam_policy",
      "change": {"after": {
        "name": "workload-metadata-read",
        "policy": json.marshal({
          "Version": "2012-10-17",
          "Statement": [{"Effect": "Allow", "Action": ["ssm:GetParameter"], "Resource": "arn:aws:ssm:*:*:parameter/openlzkit/*"}],
        }),
      }},
    }],
  }

  count(result) == 0
}

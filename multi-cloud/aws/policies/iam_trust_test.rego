package openlzkit.aws.iam_trust

import rego.v1

test_deny_wildcard_aws_principal if {
  result := deny with input as {
    "resource_changes": [{
      "address": "aws_iam_role.bad",
      "type": "aws_iam_role",
      "change": {"after": {
        "assume_role_policy": json.marshal({
          "Version": "2012-10-17",
          "Statement": [{
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Principal": {"AWS": "*"},
          }],
        }),
      }},
    }],
  }

  count(result) == 1
}

test_allow_precise_aws_principal if {
  result := deny with input as {
    "resource_changes": [{
      "address": "aws_iam_role.good",
      "type": "aws_iam_role",
      "change": {"after": {
        "assume_role_policy": json.marshal({
          "Version": "2012-10-17",
          "Statement": [{
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Principal": {"AWS": ["arn:aws:iam::111122223333:root"]},
          }],
        }),
      }},
    }],
  }

  count(result) == 0
}

test_deny_wildcard_federated_principal if {
  result := deny with input as {
    "resource_changes": [{
      "address": "aws_iam_role.bad_oidc",
      "type": "aws_iam_role",
      "change": {"after": {
        "assume_role_policy": json.marshal({
          "Version": "2012-10-17",
          "Statement": [{
            "Effect": "Allow",
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Principal": {"Federated": "*"},
          }],
        }),
      }},
    }],
  }

  count(result) == 1
}

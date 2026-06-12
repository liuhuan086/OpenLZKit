package openlzkit.aws.organizations

import rego.v1

test_deny_broad_allow_scp if {
  result := deny with input as {
    "resource_changes": [{
      "address": "aws_organizations_policy.bad",
      "type": "aws_organizations_policy",
      "change": {"after": {
        "type": "SERVICE_CONTROL_POLICY",
        "content": json.marshal({
          "Version": "2012-10-17",
          "Statement": [{"Effect": "Allow", "Action": "*", "Resource": "*"}],
        }),
      }},
    }],
  }

  count(result) == 1
}

test_allow_deny_guardrail_scp if {
  result := deny with input as {
    "resource_changes": [{
      "address": "aws_organizations_policy.good",
      "type": "aws_organizations_policy",
      "change": {"after": {
        "type": "SERVICE_CONTROL_POLICY",
        "content": json.marshal({
          "Version": "2012-10-17",
          "Statement": [{"Effect": "Deny", "Action": ["cloudtrail:StopLogging"], "Resource": "*"}],
        }),
      }},
    }],
  }

  count(result) == 0
}

test_deny_wildcard_principal_exception if {
  result := deny with input as {
    "resource_changes": [{
      "address": "aws_organizations_policy.bypass",
      "type": "aws_organizations_policy",
      "change": {"after": {
        "type": "SERVICE_CONTROL_POLICY",
        "content": json.marshal({
          "Version": "2012-10-17",
          "Statement": [{
            "Effect": "Deny",
            "Action": ["cloudtrail:StopLogging"],
            "Resource": "*",
            "Condition": {"StringLike": {"aws:PrincipalArn": "*"}},
          }],
        }),
      }},
    }],
  }

  count(result) == 1
}

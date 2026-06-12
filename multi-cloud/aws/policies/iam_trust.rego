package openlzkit.aws.iam_trust

import rego.v1

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "aws_iam_role"
  statement := trust_statement(resource)
  principal := statement.Principal.AWS
  has_star(principal)
  msg := sprintf("%s must not trust wildcard AWS principals", [resource.address])
}

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "aws_iam_role"
  statement := trust_statement(resource)
  principal := statement.Principal.Federated
  has_star(principal)
  msg := sprintf("%s must not trust wildcard federated principals", [resource.address])
}

trust_statement(resource) := statement if {
  policy := json.unmarshal(resource.change.after.assume_role_policy)
  is_array(policy.Statement)
  statement := policy.Statement[_]
}

trust_statement(resource) := statement if {
  policy := json.unmarshal(resource.change.after.assume_role_policy)
  is_object(policy.Statement)
  statement := policy.Statement
}

has_star(value) if {
  value == "*"
}

has_star(value) if {
  is_array(value)
  value[_] == "*"
}

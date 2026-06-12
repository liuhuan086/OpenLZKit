package openlzkit.aws.iam_policy

import rego.v1

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "aws_iam_policy"
  not is_boundary_policy(resource.change.after.name)
  statement := policy_statement(resource)
  statement.Effect == "Allow"
  has_star(statement.Action)
  has_star(statement.Resource)
  msg := sprintf("%s must not allow * on * outside a permission boundary policy", [resource.address])
}

policy_statement(resource) := statement if {
  policy := json.unmarshal(resource.change.after.policy)
  is_array(policy.Statement)
  statement := policy.Statement[_]
}

policy_statement(resource) := statement if {
  policy := json.unmarshal(resource.change.after.policy)
  is_object(policy.Statement)
  statement := policy.Statement
}

is_boundary_policy(name) if {
  contains(lower(name), "boundary")
}

has_star(value) if {
  value == "*"
}

has_star(value) if {
  is_array(value)
  value[_] == "*"
}

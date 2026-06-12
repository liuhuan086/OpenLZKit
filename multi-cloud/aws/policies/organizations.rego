package openlzkit.aws.organizations

import rego.v1

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "aws_organizations_policy"
  policy_type(resource) == "SERVICE_CONTROL_POLICY"
  statement := policy_statement(resource)
  statement.Effect == "Allow"
  has_star(statement.Action)
  has_star(statement.Resource)
  msg := sprintf("%s must not create an SCP with Allow * on *", [resource.address])
}

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "aws_organizations_policy"
  policy_type(resource) == "SERVICE_CONTROL_POLICY"
  statement := policy_statement(resource)
  statement.Effect == "Deny"
  has_star_principal_exception(statement)
  msg := sprintf("%s must not bypass an SCP deny with aws:PrincipalArn wildcard", [resource.address])
}

policy_type(resource) := policy_type if {
  policy_type := resource.change.after.type
}

policy_statement(resource) := statement if {
  content := json.unmarshal(resource.change.after.content)
  is_array(content.Statement)
  statement := content.Statement[_]
}

policy_statement(resource) := statement if {
  content := json.unmarshal(resource.change.after.content)
  is_object(content.Statement)
  statement := content.Statement
}

has_star(value) if {
  value == "*"
}

has_star(value) if {
  is_array(value)
  value[_] == "*"
}

has_star_principal_exception(statement) if {
  condition := statement.Condition.StringLike
  has_star(condition["aws:PrincipalArn"])
}

has_star_principal_exception(statement) if {
  condition := statement.Condition.StringLikeIfExists
  has_star(condition["aws:PrincipalArn"])
}

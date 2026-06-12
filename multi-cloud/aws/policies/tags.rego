package openlzkit.aws.tags

import rego.v1

deny contains msg if {
  resource := input.resource_changes[_]
  tags := resource.change.after.tags
  is_object(tags)
  not has_non_empty_tag(tags, "managed_by")
  msg := sprintf("%s must include a non-empty managed_by tag", [resource.address])
}

deny contains msg if {
  resource := input.resource_changes[_]
  tags := resource.change.after.tags
  is_object(tags)
  has_enterprise_tag(tags)
  required := {"owner", "cost_center", "env", "project"}
  present := {key | required[key]; has_non_empty_tag(tags, key)}
  missing := required - present
  count(missing) > 0
  msg := sprintf("%s must include complete owner/cost_center/env/project tags", [resource.address])
}

has_enterprise_tag(tags) if {
  has_non_empty_tag(tags, "owner")
}

has_enterprise_tag(tags) if {
  has_non_empty_tag(tags, "cost_center")
}

has_enterprise_tag(tags) if {
  has_non_empty_tag(tags, "env")
}

has_enterprise_tag(tags) if {
  has_non_empty_tag(tags, "project")
}

has_non_empty_tag(tags, key) if {
  value := tags[key]
  is_string(value)
  value != ""
}

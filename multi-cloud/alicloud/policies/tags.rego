# Require the FinOps tag set on taggable resources.
# Input: terraform plan JSON (terraform show -json).
package main

import rego.v1

required_tags := {"owner", "cost_center", "env", "project"}

# Resource types expected to carry FinOps tags.
taggable_types := {
	"alicloud_resource_manager_resource_group",
	"alicloud_log_project",
	"alicloud_vpc",
}

deny contains msg if {
	some rc in input.resource_changes
	taggable_types[rc.type]
	after := object.get(rc, ["change", "after"], {})
	tags := object.get(after, "tags", {})
	present := {k | some k, _ in tags}
	missing := required_tags - present
	count(missing) > 0
	msg := sprintf("%s is missing required tags: %v", [rc.address, missing])
}

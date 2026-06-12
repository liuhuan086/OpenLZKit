package main

import rego.v1

_compliant_rg := {"resource_changes": [{
	"address": "module.payment_dev.alicloud_resource_manager_resource_group.this",
	"type": "alicloud_resource_manager_resource_group",
	"change": {"after": {"tags": {
		"owner": "app-team",
		"cost_center": "cc-1",
		"env": "dev",
		"project": "payment",
	}}},
}]}

_missing_tags_rg := {"resource_changes": [{
	"address": "alicloud_resource_manager_resource_group.bad",
	"type": "alicloud_resource_manager_resource_group",
	"change": {"after": {"tags": {"owner": "app-team"}}},
}]}

test_allows_fully_tagged_resource if {
	count(deny) == 0 with input as _compliant_rg
}

test_denies_missing_required_tags if {
	count(deny) == 1 with input as _missing_tags_rg
}

test_ignores_non_taggable_types if {
	count(deny) == 0 with input as {"resource_changes": [{
		"address": "alicloud_ram_role.x",
		"type": "alicloud_ram_role",
		"change": {"after": {}},
	}]}
}

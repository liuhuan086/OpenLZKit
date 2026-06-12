package main

import rego.v1

_public_ssh := {"resource_changes": [{
	"address": "alicloud_security_group_rule.bad",
	"type": "alicloud_security_group_rule",
	"change": {"after": {
		"type": "ingress",
		"cidr_ip": "0.0.0.0/0",
		"port_range": "22/22",
	}},
}]}

_scoped_ssh := {"resource_changes": [{
	"address": "alicloud_security_group_rule.ok",
	"type": "alicloud_security_group_rule",
	"change": {"after": {
		"type": "ingress",
		"cidr_ip": "10.0.0.0/16",
		"port_range": "22/22",
	}},
}]}

test_denies_public_ssh if {
	count(deny) == 1 with input as _public_ssh
}

test_allows_scoped_ssh if {
	count(deny) == 0 with input as _scoped_ssh
}

test_allows_public_https if {
	count(deny) == 0 with input as {"resource_changes": [{
		"address": "alicloud_security_group_rule.web",
		"type": "alicloud_security_group_rule",
		"change": {"after": {
			"type": "ingress",
			"cidr_ip": "0.0.0.0/0",
			"port_range": "443/443",
		}},
	}]}
}

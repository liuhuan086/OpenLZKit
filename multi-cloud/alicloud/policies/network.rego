# Deny public ingress (0.0.0.0/0) to high-risk ports.
# Input: terraform plan JSON (terraform show -json).
package main

import rego.v1

high_risk_port_ranges := {"22/22", "3389/3389"}

deny contains msg if {
	some rc in input.resource_changes
	rc.type == "alicloud_security_group_rule"
	after := object.get(rc, ["change", "after"], {})
	after.type == "ingress"
	after.cidr_ip == "0.0.0.0/0"
	high_risk_port_ranges[after.port_range]
	msg := sprintf("%s allows public ingress (0.0.0.0/0) on %s", [rc.address, after.port_range])
}

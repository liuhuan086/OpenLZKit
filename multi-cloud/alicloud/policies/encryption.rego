# Require OSS bucket encryption and forbid public bucket ACLs.
# Input: terraform plan JSON (terraform show -json).
package main

import rego.v1

public_acls := {"public-read", "public-read-write"}

deny contains msg if {
	some rc in input.resource_changes
	rc.type == "alicloud_oss_bucket"
	after := object.get(rc, ["change", "after"], {})
	not has_encryption(after)
	msg := sprintf("%s has no server-side encryption rule", [rc.address])
}

has_encryption(after) if {
	some rule in object.get(after, "server_side_encryption_rule", [])
	rule.sse_algorithm != ""
}

deny contains msg if {
	some rc in input.resource_changes
	rc.type == "alicloud_oss_bucket_acl"
	after := object.get(rc, ["change", "after"], {})
	public_acls[after.acl]
	msg := sprintf("%s sets a public ACL: %s", [rc.address, after.acl])
}

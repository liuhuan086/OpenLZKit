package main

import rego.v1

_encrypted_bucket := {"resource_changes": [{
	"address": "alicloud_oss_bucket.state",
	"type": "alicloud_oss_bucket",
	"change": {"after": {"server_side_encryption_rule": [{"sse_algorithm": "AES256"}]}},
}]}

_plain_bucket := {"resource_changes": [{
	"address": "alicloud_oss_bucket.bad",
	"type": "alicloud_oss_bucket",
	"change": {"after": {}},
}]}

_public_acl := {"resource_changes": [{
	"address": "alicloud_oss_bucket_acl.bad",
	"type": "alicloud_oss_bucket_acl",
	"change": {"after": {"acl": "public-read"}},
}]}

_private_acl := {"resource_changes": [{
	"address": "alicloud_oss_bucket_acl.ok",
	"type": "alicloud_oss_bucket_acl",
	"change": {"after": {"acl": "private"}},
}]}

test_allows_encrypted_bucket if {
	count(deny) == 0 with input as _encrypted_bucket
}

test_denies_unencrypted_bucket if {
	count(deny) == 1 with input as _plain_bucket
}

test_denies_public_acl if {
	count(deny) == 1 with input as _public_acl
}

test_allows_private_acl if {
	count(deny) == 0 with input as _private_acl
}

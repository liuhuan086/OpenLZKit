package openlzkit.aws.s3_state

import rego.v1

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket_public_access_block"
  after := resource.change.after
  not after.block_public_acls
  msg := sprintf("%s must block public ACLs", [resource.address])
}

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket_public_access_block"
  after := resource.change.after
  not after.block_public_policy
  msg := sprintf("%s must block public bucket policies", [resource.address])
}

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket_public_access_block"
  after := resource.change.after
  not after.ignore_public_acls
  msg := sprintf("%s must ignore public ACLs", [resource.address])
}

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket_public_access_block"
  after := resource.change.after
  not after.restrict_public_buckets
  msg := sprintf("%s must restrict public buckets", [resource.address])
}

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket_versioning"
  after := resource.change.after
  config := after.versioning_configuration[_]
  config.status != "Enabled"
  msg := sprintf("%s must enable bucket versioning", [resource.address])
}

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket_server_side_encryption_configuration"
  not has_default_encryption(resource.change.after)
  msg := sprintf("%s must configure default server-side encryption", [resource.address])
}

has_default_encryption(after) if {
  rule := after.rule[_]
  encryption := rule.apply_server_side_encryption_by_default[_]
  encryption.sse_algorithm != ""
}

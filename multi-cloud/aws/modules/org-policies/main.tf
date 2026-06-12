locals {
  policy_tags = {
    for key, policy in var.policies :
    key => merge(var.common_tags, policy.tags)
  }
}

resource "aws_organizations_policy" "this" {
  for_each = var.policies

  name        = "${var.name_prefix}${each.value.name}"
  description = each.value.description
  type        = each.value.type
  content     = each.value.content
  tags        = local.policy_tags[each.key]
}

resource "aws_organizations_policy_attachment" "this" {
  for_each = var.attachments

  policy_id = try(aws_organizations_policy.this[each.value.policy_key].id, null)
  target_id = each.value.target_id

  lifecycle {
    precondition {
      condition     = contains(keys(var.policies), each.value.policy_key)
      error_message = "Each attachment policy_key must exist in var.policies."
    }
  }
}

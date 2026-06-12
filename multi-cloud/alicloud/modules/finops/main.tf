locals {
  # Tag policy requiring each key to be present. Value constraints can be added
  # per key later; here we enforce presence of the FinOps tag set.
  policy_content = jsonencode({
    tags = {
      for key in var.required_tag_keys : key => {
        tag_key = { "@@assign" = key }
      }
    }
  })
}

resource "alicloud_tag_policy" "required_tags" {
  policy_name    = var.policy_name
  policy_desc    = "Require FinOps governance tags on resources."
  policy_content = local.policy_content
  user_type      = "RD"
}

resource "alicloud_tag_policy_attachment" "this" {
  count = var.attach_target_id == null ? 0 : 1

  policy_id   = alicloud_tag_policy.required_tags.id
  target_id   = var.attach_target_id
  target_type = var.attach_target_type
}

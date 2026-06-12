locals {
  # Flatten (role, system policy) pairs for attachment.
  role_system_policies = merge([
    for role_key, role in var.roles : {
      for policy in role.system_policies :
      "${role_key}:${policy}" => { role = role_key, policy = policy }
    }
  ]...)
}

resource "alicloud_ram_role" "this" {
  for_each = var.roles

  role_name            = "${var.name_prefix}${each.key}"
  description          = each.value.description
  max_session_duration = var.max_session_duration

  assume_role_policy_document = jsonencode({
    Version = "1"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { RAM = each.value.trusted_principals }
    }]
  })
}

resource "alicloud_ram_role_policy_attachment" "system" {
  for_each = local.role_system_policies

  role_name   = alicloud_ram_role.this[each.value.role].role_name
  policy_name = each.value.policy
  policy_type = "System"
}

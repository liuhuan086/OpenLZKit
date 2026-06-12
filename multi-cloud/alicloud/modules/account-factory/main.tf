locals {
  account_tags = {
    for key, account in var.accounts :
    key => merge(var.common_tags, account.tags)
  }
}

resource "alicloud_resource_manager_account" "this" {
  for_each = var.accounts

  display_name = "${var.name_prefix}${each.value.display_name}"
  folder_id    = var.folder_ids[each.value.folder_key]
  tags         = local.account_tags[each.key]

  lifecycle {
    precondition {
      condition     = contains(keys(var.folder_ids), each.value.folder_key)
      error_message = "Each account folder_key must exist in var.folder_ids."
    }

    precondition {
      condition     = alltrue([for tag_key in var.required_tag_keys : contains(keys(local.account_tags[each.key]), tag_key)])
      error_message = "Each account must include all required FinOps tag keys after merging common_tags and account tags."
    }
  }
}

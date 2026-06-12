locals {
  account_tags = {
    for key, account in var.accounts :
    key => merge(var.common_tags, account.tags)
  }
}

resource "aws_organizations_account" "this" {
  for_each = var.accounts

  name                       = each.value.name
  email                      = each.value.email
  parent_id                  = lookup(var.ou_ids, each.value.ou_key, null)
  role_name                  = each.value.role_name
  iam_user_access_to_billing = each.value.iam_user_access_to_billing
  close_on_deletion          = each.value.close_on_deletion
  tags                       = local.account_tags[each.key]

  lifecycle {
    precondition {
      condition     = contains(keys(var.ou_ids), each.value.ou_key)
      error_message = "Each account ou_key must exist in var.ou_ids."
    }

    precondition {
      condition     = alltrue([for tag_key in var.required_tag_keys : contains(keys(local.account_tags[each.key]), tag_key)])
      error_message = "Each account must include all required governance tag keys after merging common_tags and account tags."
    }
  }
}

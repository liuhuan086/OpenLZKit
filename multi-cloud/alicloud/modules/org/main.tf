# Resource Directory is enabled once during bootstrap (live/00-bootstrap), not here.
# This module assumes it already exists and reads its root folder id.
data "alicloud_resource_manager_resource_directories" "this" {}

locals {
  root_folder_id = data.alicloud_resource_manager_resource_directories.this.directories[0].root_folder_id

  # Flatten one level of children into "<parent_key>/<child_key>" => { parent_key, display_name }.
  child_folders = merge([
    for parent_key, parent in var.folders : {
      for child_key, child in parent.children :
      "${parent_key}/${child_key}" => {
        parent_key   = parent_key
        display_name = child.display_name
      }
    }
  ]...)

  # Unified lookup of every folder id by key, for account placement.
  folder_ids = merge(
    { for k, f in alicloud_resource_manager_folder.top : k => f.folder_id },
    { for k, f in alicloud_resource_manager_folder.child : k => f.folder_id },
  )
}

resource "alicloud_resource_manager_folder" "top" {
  for_each = var.folders

  folder_name      = "${var.name_prefix}${each.value.display_name}"
  parent_folder_id = local.root_folder_id
}

resource "alicloud_resource_manager_folder" "child" {
  for_each = local.child_folders

  folder_name      = "${var.name_prefix}${each.value.display_name}"
  parent_folder_id = alicloud_resource_manager_folder.top[each.value.parent_key].folder_id
}

resource "alicloud_resource_manager_account" "this" {
  for_each = var.accounts

  display_name = each.value.display_name
  folder_id    = local.folder_ids[each.value.folder_key]
  tags         = merge(var.tags, each.value.tags)
}

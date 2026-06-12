locals {
  child_folders = merge(concat([{}], [
    for parent_key, parent in var.folders : {
      for child_key, child in parent.children :
      "${parent_key}/${child_key}" => {
        parent_key   = parent_key
        display_name = child.display_name
      }
    }
  ])...)

  # Folder resource names ("folders/<number>") by key, for parents and IAM scopes.
  folder_names = merge(
    { for k, f in google_folder.top : k => f.name },
    { for k, f in google_folder.child : k => f.name },
  )
}

resource "google_folder" "top" {
  for_each = var.folders

  display_name = "${var.name_prefix}${each.value.display_name}"
  parent       = var.parent
}

resource "google_folder" "child" {
  for_each = local.child_folders

  display_name = "${var.name_prefix}${each.value.display_name}"
  parent       = google_folder.top[each.value.parent_key].name
}

locals {
  role_system_policies = merge(concat([{}], [
    for department_key, department in var.departments : {
      for policy in department.system_policies :
      "${department_key}:${policy}" => {
        department = department_key
        policy     = policy
      }
    }
  ])...)

  control_policy_attachments = merge(concat([{}], [
    for department_key, department in var.departments : {
      for policy_id in department.control_policy_ids :
      "${department_key}:${policy_id}" => {
        department = department_key
        policy_id  = policy_id
      }
    }
  ])...)

  department_tags = {
    for key, department in var.departments :
    key => merge({
      owner               = department.owner
      cost_center         = department.cost_center
      env                 = "shared"
      project             = key
      managed_by          = "terraform"
      data_classification = "internal"
    }, department.tags)
  }

  tag_policy_content = {
    for key, department in var.departments : key => jsonencode({
      tags = {
        owner = {
          tag_key   = { "@@assign" = "owner" }
          tag_value = { "@@assign" = [department.owner] }
        }
        cost_center = {
          tag_key   = { "@@assign" = "cost_center" }
          tag_value = { "@@assign" = [department.cost_center] }
        }
        env = {
          tag_key   = { "@@assign" = "env" }
          tag_value = { "@@assign" = department.envs }
        }
        data_classification = {
          tag_key   = { "@@assign" = "data_classification" }
          tag_value = { "@@assign" = department.data_classification_values }
        }
      }
    })
  }
}

resource "alicloud_resource_manager_folder" "department" {
  for_each = var.departments

  folder_name      = "${var.name_prefix}${each.value.display_name}"
  parent_folder_id = var.parent_folder_id
}

resource "alicloud_ram_role" "department_admin" {
  for_each = var.departments

  role_name            = "${var.name_prefix}${each.key}-department-admin"
  description          = "Department administration role for ${each.value.display_name}."
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

resource "alicloud_ram_role_policy_attachment" "department_admin_system" {
  for_each = local.role_system_policies

  role_name   = alicloud_ram_role.department_admin[each.value.department].role_name
  policy_name = each.value.policy
  policy_type = "System"
}

resource "alicloud_resource_manager_control_policy_attachment" "department" {
  for_each = local.control_policy_attachments

  policy_id = each.value.policy_id
  target_id = alicloud_resource_manager_folder.department[each.value.department].folder_id
}

resource "alicloud_tag_policy" "department" {
  for_each = var.create_tag_policies ? var.departments : {}

  policy_name    = "${var.name_prefix}${each.key}-department-tags"
  policy_desc    = "Department tag policy for ${each.value.display_name}."
  policy_content = local.tag_policy_content[each.key]
  user_type      = "RD"
}

resource "alicloud_tag_policy_attachment" "department" {
  for_each = var.create_tag_policies ? var.departments : {}

  policy_id   = alicloud_tag_policy.department[each.key].id
  target_id   = alicloud_resource_manager_folder.department[each.key].folder_id
  target_type = "FOLDER"
}

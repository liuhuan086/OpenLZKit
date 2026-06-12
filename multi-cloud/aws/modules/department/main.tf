locals {
  role_policy_attachments = merge(concat([{}], [
    for department_key, department in var.departments : {
      for policy_arn in department.managed_policy_arns :
      "${department_key}:${policy_arn}" => {
        department = department_key
        policy_arn = policy_arn
      }
    }
  ])...)

  organization_policy_attachments = merge(concat([{}], [
    for department_key, department in var.departments : {
      for policy_id in department.organization_policy_ids :
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

resource "aws_organizations_organizational_unit" "department" {
  for_each = var.departments

  name      = "${var.name_prefix}${each.value.display_name}"
  parent_id = var.parent_ou_id
  tags      = local.department_tags[each.key]
}

resource "aws_iam_role" "department_admin" {
  for_each = var.departments

  name                 = "${var.name_prefix}${each.key}-department-admin"
  description          = "Department administration role for ${each.value.display_name}."
  max_session_duration = var.max_session_duration
  tags                 = local.department_tags[each.key]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        AWS = each.value.trusted_principal_arns
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "department_admin" {
  for_each = local.role_policy_attachments

  role       = aws_iam_role.department_admin[each.value.department].name
  policy_arn = each.value.policy_arn
}

resource "aws_organizations_policy_attachment" "department" {
  for_each = local.organization_policy_attachments

  policy_id = each.value.policy_id
  target_id = aws_organizations_organizational_unit.department[each.value.department].id
}

resource "aws_organizations_policy" "department_tags" {
  for_each = var.create_tag_policies ? var.departments : {}

  name        = "${var.name_prefix}${each.key}-department-tags"
  description = "Department tag policy for ${each.value.display_name}."
  type        = "TAG_POLICY"
  content     = local.tag_policy_content[each.key]
  tags        = local.department_tags[each.key]
}

resource "aws_organizations_policy_attachment" "department_tags" {
  for_each = var.create_tag_policies ? var.departments : {}

  policy_id = aws_organizations_policy.department_tags[each.key].id
  target_id = aws_organizations_organizational_unit.department[each.key].id
}

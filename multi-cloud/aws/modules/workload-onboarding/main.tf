locals {
  workload_tags = {
    for key, workload in var.workloads : key => merge(
      var.common_tags,
      {
        department          = workload.department
        owner               = workload.owner
        cost_center         = workload.cost_center
        env                 = workload.env
        project             = workload.project
        data_classification = workload.data_classification
      },
      workload.tags
    )
  }

  role_workloads = {
    for key, workload in var.workloads : key => workload
    if length(workload.trusted_principal_arns) > 0
  }

  assume_role_conditions = {
    for key, workload in local.role_workloads : key => (
      workload.external_id == null
      ? workload.condition
      : merge(
        workload.condition == null ? {} : workload.condition,
        {
          StringEquals = merge(
            try(workload.condition.StringEquals, {}),
            { "sts:ExternalId" = workload.external_id }
          )
        }
      )
    )
  }

  assume_role_policies = {
    for key, workload in local.role_workloads : key => jsonencode({
      Version = "2012-10-17"
      Statement = [
        merge({
          Effect = "Allow"
          Action = "sts:AssumeRole"
          Principal = {
            AWS = workload.trusted_principal_arns
          }
        }, local.assume_role_conditions[key] == null ? {} : { Condition = local.assume_role_conditions[key] })
      ]
    })
  }

  managed_policy_attachments = merge(concat([{}], [
    for workload_key, workload in local.role_workloads : {
      for policy_arn in workload.managed_policy_arns :
      "${workload_key}:${policy_arn}" => {
        workload   = workload_key
        policy_arn = policy_arn
      }
    }
  ])...)

  inline_policies = merge(concat([{}], [
    for workload_key, workload in local.role_workloads : {
      for policy_name, policy in workload.inline_policies :
      "${workload_key}:${policy_name}" => {
        workload = workload_key
        name     = policy_name
        policy   = policy
      }
    }
  ])...)

  metadata = {
    for key, workload in var.workloads : key => merge({
      name                 = workload.name
      description          = workload.description
      department           = workload.department
      owner                = workload.owner
      cost_center          = workload.cost_center
      env                  = workload.env
      project              = workload.project
      data_classification  = workload.data_classification
      account_id           = workload.account_id
      vpc_id               = workload.vpc_id
      subnet_ids           = jsonencode(workload.subnet_ids)
      permission_set_names = jsonencode(workload.permission_set_names)
      role_arn             = try(aws_iam_role.workload[key].arn, "")
    }, workload.additional_metadata)
  }

  metadata_parameters = var.create_metadata_parameters ? merge(concat([{}], [
    for workload_key, metadata in local.metadata : {
      for name, value in metadata :
      "${workload_key}:${name}" => {
        workload = workload_key
        name     = name
        value    = value
      }
    }
  ])...) : {}
}

resource "aws_iam_role" "workload" {
  for_each = local.role_workloads

  name                 = "${var.name_prefix}${each.value.name}-workload-access"
  description          = each.value.description
  max_session_duration = var.max_session_duration
  assume_role_policy   = local.assume_role_policies[each.key]
  tags                 = local.workload_tags[each.key]
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = local.managed_policy_attachments

  role       = aws_iam_role.workload[each.value.workload].name
  policy_arn = each.value.policy_arn
}

resource "aws_iam_role_policy" "inline" {
  for_each = local.inline_policies

  name   = each.value.name
  role   = aws_iam_role.workload[each.value.workload].id
  policy = each.value.policy
}

resource "aws_ssm_parameter" "metadata" {
  for_each = local.metadata_parameters

  name        = "${var.parameter_prefix}/${each.value.workload}/${each.value.name}"
  description = "OpenLZKit workload onboarding metadata for ${each.value.workload}."
  type        = "String"
  value       = each.value.value
  tags        = local.workload_tags[each.value.workload]
}

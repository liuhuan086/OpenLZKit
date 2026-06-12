locals {
  role_tags = {
    for key, role in var.access_roles :
    key => merge(var.common_tags, role.tags)
  }

  oidc_tags = {
    for key, provider in var.oidc_providers :
    key => merge(var.common_tags, provider.tags)
  }

  share_tags = {
    for key, share in var.resource_shares :
    key => merge(var.common_tags, share.tags)
  }

  role_managed_policy_attachments = merge(concat([{}], [
    for role_key, role in var.access_roles : {
      for policy_arn in role.managed_policy_arns :
      "${role_key}:${policy_arn}" => {
        role       = role_key
        policy_arn = policy_arn
      }
    }
  ])...)

  role_inline_policies = merge(concat([{}], [
    for role_key, role in var.access_roles : {
      for policy_name, policy in role.inline_policies :
      "${role_key}:${policy_name}" => {
        role   = role_key
        name   = policy_name
        policy = policy
      }
    }
  ])...)

  ram_principal_associations = merge(concat([{}], [
    for share_key, share in var.resource_shares : {
      for principal in share.principals :
      "${share_key}:${principal}" => {
        share     = share_key
        principal = principal
      }
    }
  ])...)

  ram_resource_associations = merge(concat([{}], [
    for share_key, share in var.resource_shares : {
      for resource_arn in share.resource_arns :
      "${share_key}:${resource_arn}" => {
        share        = share_key
        resource_arn = resource_arn
      }
    }
  ])...)

  assume_role_conditions = {
    for key, role in var.access_roles : key => (
      role.external_id == null
      ? role.condition
      : merge(
        role.condition == null ? {} : role.condition,
        {
          StringEquals = merge(
            try(role.condition.StringEquals, {}),
            { "sts:ExternalId" = role.external_id }
          )
        }
      )
    )
  }

  generated_federated_principals = {
    for key, role in var.access_roles : key => compact(concat(
      role.federated_principal_arns,
      [for provider_key in role.oidc_provider_keys : try(aws_iam_openid_connect_provider.this[provider_key].arn, null)]
    ))
  }

  assume_role_policies = {
    for key, role in var.access_roles : key => jsonencode({
      Version = "2012-10-17"
      Statement = concat(
        length(role.trusted_principal_arns) == 0 ? [] : [
          merge({
            Effect = "Allow"
            Action = "sts:AssumeRole"
            Principal = {
              AWS = role.trusted_principal_arns
            }
          }, local.assume_role_conditions[key] == null ? {} : { Condition = local.assume_role_conditions[key] })
        ],
        length(local.generated_federated_principals[key]) == 0 ? [] : [
          merge({
            Effect = "Allow"
            Action = "sts:AssumeRoleWithWebIdentity"
            Principal = {
              Federated = local.generated_federated_principals[key]
            }
          }, role.oidc_condition == null ? {} : { Condition = role.oidc_condition })
        ]
      )
    })
  }
}

resource "aws_iam_openid_connect_provider" "this" {
  for_each = var.oidc_providers

  url             = each.value.url
  client_id_list  = each.value.client_id_list
  thumbprint_list = each.value.thumbprint_list
  tags            = local.oidc_tags[each.key]
}

resource "aws_iam_role" "cross_account" {
  for_each = var.access_roles

  name                 = "${var.name_prefix}${each.value.role_name}"
  description          = each.value.description
  max_session_duration = var.max_session_duration
  assume_role_policy   = local.assume_role_policies[each.key]
  tags                 = local.role_tags[each.key]

  lifecycle {
    precondition {
      condition     = alltrue([for provider_key in each.value.oidc_provider_keys : contains(keys(var.oidc_providers), provider_key)])
      error_message = "Each oidc_provider_key must exist in var.oidc_providers."
    }
  }
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = local.role_managed_policy_attachments

  role       = aws_iam_role.cross_account[each.value.role].name
  policy_arn = each.value.policy_arn
}

resource "aws_iam_role_policy" "inline" {
  for_each = local.role_inline_policies

  name   = each.value.name
  role   = aws_iam_role.cross_account[each.value.role].id
  policy = each.value.policy
}

resource "aws_ram_resource_share" "this" {
  for_each = var.resource_shares

  name                      = "${var.name_prefix}${each.value.name}"
  allow_external_principals = each.value.allow_external_principals
  permission_arns           = each.value.permission_arns
  tags                      = local.share_tags[each.key]
}

resource "aws_ram_principal_association" "this" {
  for_each = local.ram_principal_associations

  resource_share_arn = aws_ram_resource_share.this[each.value.share].arn
  principal          = each.value.principal
}

resource "aws_ram_resource_association" "this" {
  for_each = local.ram_resource_associations

  resource_share_arn = aws_ram_resource_share.this[each.value.share].arn
  resource_arn       = each.value.resource_arn
}

locals {
  share_tags = {
    for key, share in var.resource_shares :
    key => merge(var.common_tags, share.tags)
  }

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

}

resource "aws_ram_sharing_with_organization" "this" {
  count = var.enable_ram_sharing_with_organization ? 1 : 0
}

resource "aws_organizations_delegated_administrator" "this" {
  for_each = var.delegated_administrators

  account_id        = each.value.account_id
  service_principal = each.value.service_principal
}

resource "aws_ram_resource_share" "this" {
  for_each = var.resource_shares

  name                      = "${var.name_prefix}${each.value.name}"
  allow_external_principals = each.value.allow_external_principals
  permission_arns           = each.value.permission_arns
  tags                      = local.share_tags[each.key]

  depends_on = [aws_ram_sharing_with_organization.this]
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

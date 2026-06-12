module "delegation" {
  source = "../../modules/delegation"

  name_prefix                          = "lz-"
  enable_ram_sharing_with_organization = var.enable_ram_sharing_with_organization
  delegated_administrators             = var.delegated_administrators
  resource_shares                      = var.resource_shares
}

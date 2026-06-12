resource "azurerm_virtual_network" "this" {
  name                = "${var.name_prefix}${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
}

# Baseline NSG with no custom rules: Azure's default rules already deny inbound
# from the internet (allowing only intra-VNet and load-balancer traffic). Workloads
# add narrowly-scoped allow rules; public ingress is never the default.
resource "azurerm_network_security_group" "baseline" {
  name                = "${var.name_prefix}${var.name}-baseline"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.baseline.id
}

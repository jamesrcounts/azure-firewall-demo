module "routes" {
  source = "../modules/routes"

  firewall_ip_address = module.firewall.private_ip_address
  resource_group      = data.azurerm_resource_group.rg
  route_table         = module.networks.route_table
  subnet              = module.networks.subnet
}
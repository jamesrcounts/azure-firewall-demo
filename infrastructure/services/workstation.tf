module "workstation" {
  source = "../modules/workstation"

  depends_on = [module.app_service]

  ca_certificate     = local.ca_certificate
  firewall_policy_id = local.firewall_policy_id
  instance_id        = var.env_instance_id
  subnet             = local.subnet["worker"]["WorkerSubnet"]
  resource_group     = data.azurerm_resource_group.rg
  tags               = local.tags
}
module "workstation" {
  source = "../modules/workstation"

  depends_on = [module.app_service]

  ca_certificate     = nonsensitive(data.azurerm_key_vault_secret.import["RootCA"].value)
  firewall_policy_id = local.firewall_policy_id
  instance_id        = var.env_instance_id
  subnet             = local.subnet["worker"]["WorkerSubnet"]
  resource_group     = data.azurerm_resource_group.rg
  tags               = local.tags
}
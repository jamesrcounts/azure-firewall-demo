module "workstation" {
  source = "../modules/workstation"

  ca_certificate     = data.azurerm_key_vault_certificate_data.rootca.pem
  firewall_policy_id = local.firewall_policy_id
  instance_id        = var.env_instance_id
  subnet             = local.subnet["worker"]["WorkerSubnet"]
  resource_group     = data.azurerm_resource_group.rg
  tags               = local.tags
}
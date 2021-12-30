module "workstation" {
  source = "../modules/workstation"

  depends_on = [
    azurerm_firewall_policy_rule_collection_group.appservice_rules
  ]

  ca_certificate       = data.azurerm_key_vault_certificate_data.rootca.pem
  instance_id          = var.env_instance_id
  network_interface_id = module.networks.worker_network_interface.id
  resource_group       = data.azurerm_resource_group.rg
  tags                 = local.tags
}
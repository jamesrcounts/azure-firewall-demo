resource "azurerm_firewall" "fw" {
  firewall_policy_id  = azurerm_firewall_policy.afwp.id
  location            = data.azurerm_resource_group.rg.location
  name                = "fw-${var.env_instance_id}"
  resource_group_name = data.azurerm_resource_group.rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"
  tags                = local.tags

  ip_configuration {
    name                 = "FirewallIPConfiguration"
    subnet_id            = azurerm_subnet.fw.id
    public_ip_address_id = azurerm_public_ip.fw.id
  }
}

resource "azurerm_firewall_policy" "afwp" {
  location            = data.azurerm_resource_group.rg.location
  name                = "afwp-${var.env_instance_id}"
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Premium"
  tags                = local.tags

  identity {
    type                       = "UserAssigned"
    user_assigned_identity_ids = [azurerm_user_assigned_identity.afwp.id]
  }

  tls_certificate {
    name                = "CACert"
    key_vault_secret_id = data.azurerm_key_vault_secret.certificate["prd"].id
  }
}

resource "azurerm_user_assigned_identity" "afwp" {
  location            = data.azurerm_resource_group.rg.location
  name                = "uai-afwp-${var.env_instance_id}"
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.tags
}
# {

#     "dependsOn": [
#         "[resourceId('Microsoft.KeyVault/vaults/secrets', variables('keyVaultName'), variables('keyVaultCASecretName'))]",
#     ],
#     "properties": {
#         "transportSecurity": {
#             "certificateAuthority": {
#                 "name": "[variables('keyVaultCASecretName')]",
#                 "keyVaultSecretId": "[concat(reference(resourceId('Microsoft.KeyVault/vaults', variables('keyVaultName')), '2019-09-01').vaultUri, 'secrets/', variables('keyVaultCASecretName'), '/')]"
#             }
#         },
#         "intrusionDetection": {
#             "mode": "Alert",
#             "configuration": {
#                 "signatureOverrides": [
#                     {
#                         "id": "[parameters('sigOverrideParam1')]",
#                         "mode": "Deny"
#                     },
#                     {
#                         "id": "[parameters('sigOverrideParam2')]",
#                         "mode": "Alert"
#                     }
#                 ],
#                 "bypassTrafficSettings": [
#                     {
#                         "name": "SecretBypass",
#                         "protocol": "TCP",
#                         "sourceAddresses": [
#                             "*"
#                         ],
#                         "destinationAddresses": [
#                             "1.1.1.1"
#                         ],
#                         "destinationPorts": [
#                             "80"
#                         ]
#                     }
#                 ]
#             }
#         }
#     }
# },
# {
#     "type": "Microsoft.Network/firewallPolicies/ruleCollectionGroups",
#     "apiVersion": "2020-07-01",
#     "name": "DemoFirewallPolicy/PolicyRules",
#     "location": "[parameters('location')]",
#     "dependsOn": [
#         "[resourceId('Microsoft.Network/firewallPolicies', 'DemoFirewallPolicy')]"
#     ],
#     "properties": {
#         "priority": 200,
#         "ruleCollections": [
#             {
#                 "name": "AllowWeb",
#                 "priority": 101,
#                 "ruleCollectionType": "FirewallPolicyFilterRuleCollection",
#                 "action": {
#                     "type": "Allow"
#                 },
#                 "rules": [
#                     {
#                         "ruleType": "ApplicationRule",
#                         "name": "AllowAzure",
#                         "protocols": [
#                             {
#                                 "protocolType": "Https",
#                                 "port": 443
#                             }
#                         ],
#                         "targetFqdns": [
#                             "*azure.com",
#                             "*microsoft.com"
#                         ],
#                         "sourceAddresses": [
#                             "*"
#                         ],
#                         "terminateTLS": true
#                     },
#                     {
#                         "ruleType": "ApplicationRule",
#                         "name": "AllowNews",
#                         "protocols": [
#                             {
#                                 "protocolType": "Https",
#                                 "port": 443
#                             }
#                         ],
#                         "webCategories": [
#                             "business",
#                             "webbasedemail"
#                         ],
#                         "sourceAddresses": [
#                             "*"
#                         ],
#                         "terminateTLS": true
#                     }
#                 ]
#             },
#             {
#                 "name": "BlockPage",
#                 "priority": 100,
#                 "ruleCollectionType": "FirewallPolicyFilterRuleCollection",
#                 "action": {
#                     "type": "Deny"
#                 },
#                 "rules": [
#                     {
#                         "ruleType": "ApplicationRule",
#                         "name": "BlockAzureEvents",
#                         "protocols": [
#                             {
#                                 "protocolType": "Https",
#                                 "port": 443
#                             }
#                         ],
#                         "targetUrls": [
#                             "azure.microsoft.com/en-us/community/events",
#                             "azure.microsoft.com/en-us/community/events/*"
#                         ],
#                         "sourceAddresses": [
#                             "*"
#                         ],
#                         "terminateTLS": true
#                     }
#                 ]
#             }
#         ]
#     }
# },
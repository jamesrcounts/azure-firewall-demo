variable "allowed_source_addresses" {
  description = "(Required) Specifies a list of source IP addresses (including CIDR and *) that are allowed to communicate with this server."
  type        = list(string)
}

variable "certificate" {
  description = "Private key and public certificate for TLS."
  sensitive   = true
  type = object({
    cert_pem        = string
    private_key_pem = string
  })
}

variable "firewall_policy_id" {
  description = "The ID of the Firewall Policy where the Firewall Policy Rule Collection Group should exist."
  type        = string
}

variable "instance_id" {
  description = "ID to use when generating names."
  type        = string
}

variable "resource_group" {
  description = "The resource group to deploy the networks into."
  type = object({
    name     = string
    location = string
  })
}

variable "subnet" {
  description = "(Required) The subnet where this server's Network Interface should be located in."
  type = object({
    id             = string
    address_prefix = string
  })
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
}
variable "ca_certificate" {
  description = "Trusted root CA certificate."
  type        = string
}

variable "firewall_policy_id" {
  description = "The ID of the Firewall Policy where the Firewall Policy Rule Collection Group should exist."
  type        = string
}

variable "instance_id" {
  description = "ID to use when generating names."
  type        = string
}

variable "subnet" {
  description = "(Required) The subnet where this server's Network Interface should be located in."
  type = object({
    id             = string
    address_prefix = string
  })
}

variable "resource_group" {
  description = "The resource group to deploy the networks into."
  type = object({
    name     = string
    location = string
  })
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
}
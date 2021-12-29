variable "ca_certificate" {
  description = "Trusted root CA certificate."
  type        = string
}

variable "instance_id" {
  description = "ID to use when generating names."
  type        = string
}

variable "network_interface_id" {
  description = "A Network Interface ID which should be attached to this Virtual Machine."
  type        = string
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
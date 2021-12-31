variable "firewall_ip_address" {
  description = "The firewall IP address will be the next hop for most routes."
  type        = string
}

variable "resource_group" {
  description = "The resource group to deploy the networks into."
  type = object({
    name     = string
    location = string
  })
}

variable "route_table" {
  description = "A collection of route tables to add routes to."
  type = map(object({
    name = string
  }))
}

variable "subnet" {
  description = "A table of subnet data, organized by virtual network."
  type = map(
    map(
      object({
        address_prefix = string
      })
    )
  )
}
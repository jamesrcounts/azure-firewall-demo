variable "backend_addresses" {
  description = "The IP addresses to add to the application gateway's backend pool."
  type        = list(string)
}

variable "ca_certificate" {
  description = "Trusted root CA certificate."
  type        = string
}

variable "host_name" {
  description = "The hostname to use for listeners and backend probes."
  type        = string
}

variable "certificate_secret_id" {
  description = "The key vault secret id for the frontend certificate data."
  type        = string
}

variable "instance_id" {
  description = "ID to use when generating names."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The workspace to write logs into."
  type        = string
}

variable "resource_groups" {
  description = "The resource group to deploy the networks into."
  type = map(object({
    id       = string
    location = string
    name     = string
  }))
}

variable "subnet_id" {
  description = "The subnet to deploy the bastion into."
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
}
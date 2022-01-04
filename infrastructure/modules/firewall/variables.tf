variable "ca_secret_id" {
  description = "The key vault secret id for the certificate authority data."
  type        = string
}

variable "instance_id" {
  description = "ID to use when generating names."
  type        = string
}

variable "log_analytics_workspace" {
  description = "The workspace to write logs into."
  type = object({
    id                  = string
    resource_group_name = string
    subscription_id     = string
    name                = string
  })
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
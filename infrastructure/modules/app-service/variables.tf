variable "firewall_policy_id" {
  description = "The ID of the Firewall Policy where the Firewall Policy Rule Collection Group should exist."
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

variable "resource_group" {
  description = "The resource group to deploy the service into."
  type = object({
    name     = string
    location = string
  })
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
}
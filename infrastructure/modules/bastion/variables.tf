variable "log_analytics_workspace_id" {
  description = "The workspace to write logs into."
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

variable "instance_id" {
  description = "ID to use when generating names."
  type        = string
}

variable "subnet_id" {
  description = "The subnet to deploy the bastion into."
  type        = string
}
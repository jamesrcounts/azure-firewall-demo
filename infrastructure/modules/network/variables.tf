variable "resource_group" {
  description = "The resource group to deploy the networks into."
  type = object({
    location = string
    name     = string
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

variable "log_analytics_workspace" {
  description = "The workspace to write logs into."
  type = object({
    id           = string
    location     = string
    workspace_id = string
  })
}

variable "log_storage_account_id" {
  description = "The storage account to write flow logs into."
  type        = string
}
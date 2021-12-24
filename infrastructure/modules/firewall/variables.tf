variable "ca_secret_id" {
  description = "The key vault secret id for the certificate authority data."
  type        = string
}

variable "instance_id" {
  description = "ID to use when generating names."
  type        = string
}

variable "resource_group" {
  description = "The resource group to deploy the networks into."
  type = object({
    id       = string
    name     = string
    location = string
  })
}

variable "subnet_id" {
  description = "The subnet to deploy the bastion into."
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
}
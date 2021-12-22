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

variable "certificate" {
  description = "Private key and public certificate for TLS."
  sensitive   = true
  type = object({
    cert_pem        = string
    private_key_pem = string
  })
}

variable "subnet_id" {
  description = "Subnet to deploy the server into."
  type        = string
}
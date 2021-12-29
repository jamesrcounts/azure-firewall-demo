variable "ip_address" {
  description = "(Required) The IP to create DNS records for."
  type        = string
}

variable "name" {
  description = "(Required) The record's host name."
  type        = string
}

variable "zone_name" {
  description = "(Required) The record's DNS zone name."
  type        = string
}
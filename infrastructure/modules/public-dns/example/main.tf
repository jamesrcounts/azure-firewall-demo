provider "aws" {
  region = "us-west-2"
}

module "test" {
  source = "../"

  name       = "test"
  ip_address = "127.0.0.1"
  zone_name  = "jamesrcounts.com"
}
module "public_dns" {
  source = "../modules/public-dns"

  name       = "firewall"
  ip_address = module.agw.ip_address
  zone_name  = "jamesrcounts.com"
}
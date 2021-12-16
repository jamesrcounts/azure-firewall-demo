locals {
  allowed_uses = [
    "cert_signing",      # keyCertSign
    "crl_signing",       #  cRLSign
    "digital_signature", # digitalSignature, 
  ]
}
resource "tls_private_key" "root_ca" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "root_ca" {
  is_ca_certificate     = true
  key_algorithm         = tls_private_key.root_ca.algorithm
  private_key_pem       = tls_private_key.root_ca.private_key_pem
  set_subject_key_id    = true
  validity_period_hours = 1024 * 24

  allowed_uses = local.allowed_uses

  subject {
    common_name  = "Self Signed Root CA"
    country      = "US"
    organization = "Self Signed"
    province     = "US"
  }
}

resource "tls_private_key" "inter_ca" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_cert_request" "inter_ca" {
  key_algorithm   = tls_private_key.inter_ca.algorithm
  private_key_pem = tls_private_key.inter_ca.private_key_pem

  subject {
    common_name  = "Self Signed Intermediate CA"
    organization = "Self Signed"
  }
}

resource "tls_locally_signed_cert" "inter_ca" {
  cert_request_pem   = tls_cert_request.inter_ca.cert_request_pem
  ca_key_algorithm   = tls_private_key.root_ca.algorithm
  ca_private_key_pem = tls_private_key.root_ca.private_key_pem
  ca_cert_pem        = tls_private_key.root_ca.public_key_pem

  validity_period_hours = 1024 * 24
  is_ca_certificate     = true
  allowed_uses          = local.allowed_uses
}

# resource "tls_locally_signed_cert" "inter_ca" {
#   cert_request_pem = tls_cert_request.inter_ca.cert_request_pem

#   ca_key_algorithm   = "RSA"
#   ca_private_key_pem = tls_private_key.root_ca.private_key_pem
#   ca_cert_pem        = tls_private_key.root_ca.public_key_pem
#   is_ca_certificate  = true

#   validity_period_hours = 1024 * 24
#   allowed_uses = [
#     "cert_signing",
#     "key_encipherment",
#     "digital_signature",
#   ]
# }

# resource "pkcs12_from_pem" "inter_pkcs12" {
#   password        = ""
#   cert_pem        = tls_locally_signed_cert.inter_ca.cert_pem
#   private_key_pem = tls_private_key.inter_ca.private_key_pem
# }
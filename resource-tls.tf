#
# CA
#

resource "tls_private_key" "ca" {
  count       = "${var.certificate_self_signed == 1 ? 1 : 0}"
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "ca" {
  count                 = "${var.certificate_self_signed == 1 ? 1 : 0}"
  key_algorithm         = "ECDSA"
  private_key_pem       = "${tls_private_key.ca.private_key_pem}"
  is_ca_certificate     = true
  validity_period_hours = 8760

  allowed_uses = [
    "cert_signing",
  ]

  subject {
    common_name  = "${var.prefix}"
    organization = "${var.prefix}"
  }
}

#
# GitLab server
#

resource "tls_private_key" "gitlab" {
  count       = "${var.certificate_self_signed == 1 ? 1 : 0}"
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "gitlab" {
  count           = "${var.certificate_self_signed == 1 ? 1 : 0}"
  key_algorithm   = "ECDSA"
  private_key_pem = "${tls_private_key.gitlab.private_key_pem}"
  dns_names       = ["${local.gitlab_domain}"]

  subject {
    common_name  = "${local.gitlab_domain}"
    organization = "${var.prefix}"
  }
}

resource "tls_locally_signed_cert" "gitlab" {
  count                 = "${var.certificate_self_signed == 1 ? 1 : 0}"
  cert_request_pem      = "${tls_cert_request.gitlab.cert_request_pem}"
  ca_key_algorithm      = "ECDSA"
  ca_private_key_pem    = "${tls_private_key.ca.private_key_pem}"
  ca_cert_pem           = "${tls_self_signed_cert.ca.cert_pem}"
  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

#
# SSH
#

resource "tls_private_key" "runners-ssh" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

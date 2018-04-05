# CA
resource "tls_private_key" "ca" {
  count       = "${var.load_balancer["self_signed"] == 1 ? 1 : 0}"
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "ca" {
  count                 = "${var.load_balancer["self_signed"] == 1 ? 1 : 0}"
  key_algorithm         = "ECDSA"
  private_key_pem       = "${tls_private_key.ca.private_key_pem}"
  is_ca_certificate     = true
  validity_period_hours = 8760
  allowed_uses          = [
    "cert_signing"
  ]
  subject {
    common_name  = "${var.prefix}"
    organization = "${var.prefix}"
  }
}

# GitLab server
resource "tls_private_key" "gitlab" {
  count       = "${var.load_balancer["self_signed"] == 1 ? 1 : 0}"
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "gitlab" {
  count           = "${var.load_balancer["self_signed"] == 1 ? 1 : 0}"
  key_algorithm   = "ECDSA"
  private_key_pem = "${tls_private_key.gitlab.private_key_pem}"
  dns_names       = [ "*.${data.aws_region.current.name}.elb.amazonaws.com" ]
  subject {
    common_name  = "*.${data.aws_region.current.name}.elb.amazonaws.com"
    organization = "${var.prefix}"
  }
}

resource "tls_locally_signed_cert" "gitlab" {
  count                 = "${var.load_balancer["self_signed"] == 1 ? 1 : 0}"
  cert_request_pem      = "${tls_cert_request.gitlab.cert_request_pem}"
  ca_key_algorithm      = "ECDSA"
  ca_private_key_pem    = "${tls_private_key.ca.private_key_pem}"
  ca_cert_pem           = "${tls_self_signed_cert.ca.cert_pem}"
  validity_period_hours = 8760
  allowed_uses          = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

#
# SSH
#

resource "tls_private_key" "ssh" {
  algorithm   = "RSA"
  ecdsa_curve = "2048"
}

resource "local_file" "ssh_private_key_pem" {
  content   = "${tls_private_key.ssh.private_key_pem}"
  filename  = "${path.module}/keys/${var.prefix}.key"
  provisioner "local-exec" {
    command = "chmod 0600 ${path.module}/keys/${var.prefix}.key"
  }
}

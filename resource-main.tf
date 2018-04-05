resource "aws_key_pair" "main" {
  key_name_prefix = "${var.prefix}"
  public_key      = "${tls_private_key.ssh.public_key_openssh}"
}

resource "random_string" "gitlab_root_password" {
  length  = 16
  upper   = true
  lower   = true
  number  = true
  keepers = {
    rds_id = "${aws_db_instance.main.id}"
  }
}

resource "random_string" "gitlab_postgres_password" {
  length  = 16
  upper   = true
  lower   = true
  number  = true
  special = false
}

resource "random_string" "gitlab_shared_runners_registration_token" {
  length  = 16
  upper   = true
  lower   = true
  number  = true
  special = false
}

output "Gitlab root password" {
  value = "${random_string.gitlab_root_password.result}"
}

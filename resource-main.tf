resource "aws_key_pair" "main" {
  key_name   = "${var.prefix}"
  public_key = "${file("./keys/ribose.pub")}"
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
}

output "Gitlab root password" {
  value = "${random_string.gitlab_root_password.result}"
}

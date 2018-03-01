resource "aws_db_subnet_group" "main" {
  name_prefix = "${var.prefix}"
  tags        = "${var.default_tags}"
  subnet_ids  = [ "${aws_subnet.private.*.id}" ]
}

resource "random_id" "rds" {
  keepers = {
    ami_id = "${var.rds["database"]}"
  }
  byte_length = 8
}

resource "aws_db_instance" "main" {
  name                      = "${var.rds["database"]}"
  tags                      = "${var.default_tags}"
  allocated_storage         = "${var.rds["allocated_storage"]}"
  storage_type              = "${var.rds["storage_type"]}"
  engine                    = "postgres"
  engine_version            = "9.6.6"
  instance_class            = "${var.rds["instance_class"]}"
  username                  = "${var.rds["username"]}"
  password                  = "${random_string.gitlab_postgres_password.result}"
  db_subnet_group_name      = "${aws_db_subnet_group.main.name}"
  skip_final_snapshot       = "${var.rds["skip_final_snapshot"]}"
  final_snapshot_identifier = "${var.prefix}-snapshot-postgresql-${var.rds["database"]}-${random_id.rds.hex}"
  vpc_security_group_ids    = [
    "${aws_security_group.allow_all_egress.id}",
    "${aws_security_group.allow_postgresql.id}"
  ]
}

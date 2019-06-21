resource "random_string" "gitlab_postgres_password" {
  length  = 16
  upper   = true
  lower   = true
  number  = true
  special = false
}

resource "aws_db_subnet_group" "main" {
  name_prefix = var.prefix
  subnet_ids  = var.subnets
}

resource "random_id" "rds" {
  keepers = {
    ami_id = var.rds["database"]
  }

  byte_length = 8
}

resource "aws_db_instance" "main" {
  name                      = var.rds["database"]
  allocated_storage         = var.rds["allocated_storage"]
  storage_type              = var.rds["storage_type"]
  engine                    = "postgres"
  engine_version            = var.rds["version"]
  instance_class            = var.rds["instance_class"]
  username                  = var.rds["username"]
  password                  = random_string.gitlab_postgres_password.result
  db_subnet_group_name      = aws_db_subnet_group.main.name
  skip_final_snapshot       = var.rds["skip_final_snapshot"]
  final_snapshot_identifier = "${var.prefix}-snapshot-postgresql-${var.rds["database"]}-${random_id.rds.hex}"
  backup_retention_period   = 3
  backup_window             = "02:00-03:00"
  maintenance_window        = "sun:03:01-sun:05:00"

  vpc_security_group_ids = [
    aws_security_group.allow_all_egress.id,
    aws_security_group.allow_postgresql.id,
  ]
}

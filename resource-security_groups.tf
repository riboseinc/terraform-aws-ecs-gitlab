data "aws_subnet" "main" {
  count = length(var.subnets)
  id    = var.subnets[count.index]
}

resource "aws_security_group" "allow_all_egress" {
  name_prefix = var.prefix
  description = "Allow All Egress"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_postgresql" {
  name_prefix = var.prefix
  description = "Allow PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    cidr_blocks = data.aws_subnet.main.*.cidr_block
  }
}

resource "aws_security_group" "allow_web_public" {
  name_prefix = var.prefix
  description = "Allow Web Public"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_all_subnets_vpc" {
  name_prefix = var.prefix
  description = "Allow Web Private"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = data.aws_subnet.main.*.cidr_block
  }
}

resource "aws_security_group" "allow_redis" {
  name_prefix = var.prefix
  description = "Allow Redis"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"

    cidr_blocks = data.aws_subnet.main.*.cidr_block
  }
}

resource "aws_security_group" "allow_all_public" {
  name_prefix = var.prefix
  description = "Allow all inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "runner" {
  name_prefix = var.prefix
  description = "Security group for gitlab runners"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2376
    to_port     = 2376
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


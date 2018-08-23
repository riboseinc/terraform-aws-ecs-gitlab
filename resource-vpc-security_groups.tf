resource "aws_security_group" "allow_all_egress" {
  name_prefix = "${var.prefix}"
  description = "Allow All Egress"
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${var.default_tags}"

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = [ "0.0.0.0/0" ]
  }
}

resource "aws_security_group" "allow_icmp" {
  name_prefix = "${var.prefix}"
  description = "Allow ICMP"
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${var.default_tags}"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "icmp"
    cidr_blocks     = [ "0.0.0.0/0" ]
  }
}

resource "aws_security_group" "allow_postgresql" {
  name_prefix = "${var.prefix}"
  description = "Allow PostgreSQL"
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${var.default_tags}"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks     = [
      "${values(var.vpc_public_subnets)}"
    ]
  }
}

resource "aws_security_group" "allow_web_public" {
  name_prefix = "${var.prefix}"
  description = "Allow Web Public"
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${var.default_tags}"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_all_public_subnets_vpc" {
  name_prefix = "${var.prefix}"
  description = "Allow Web Private"
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${var.default_tags}"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = [
      "${values(var.vpc_public_subnets)}"
    ]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = [
      "${values(var.vpc_public_subnets)}"
    ]
  }
}

resource "aws_security_group" "allow_redis" {
  name_prefix = "${var.prefix}"
  description = "Allow Redis"
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${var.default_tags}"

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    cidr_blocks     = [
      "${values(var.vpc_public_subnets)}"
    ]
  }
}

resource "aws_security_group" "allow_ssh" {
  name_prefix = "${var.prefix}"
  description = "Allow SSH"
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${var.default_tags}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_security_group" "allow_all_public" {
  name_prefix = "${var.prefix}"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${var.default_tags}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "runner" {
  name_prefix = "${var.prefix}"
  description = "Security group for gitlab runners"
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${var.default_tags}"

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
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

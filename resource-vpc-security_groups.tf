resource "aws_security_group" "allow_all_egress" {
  name        = "Allow All Egress"
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
  name        = "Allow ICMP"
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
  name        = "Allow PostgreSQL"
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${var.default_tags}"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks     = [
      "${var.vpc_subnets["services"]}",
      "${var.vpc_subnets["frontend"]}"
    ]
  }
}

resource "aws_security_group" "allow_web_public" {
  name        = "Allow Web Public"
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

resource "aws_security_group" "allow_web_private" {
  name        = "Allow Web Private"
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${var.default_tags}"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = [
      "${var.vpc_subnets["services"]}",
      "${var.vpc_subnets["frontend"]}"
    ]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = [
      "${var.vpc_subnets["services"]}",
      "${var.vpc_subnets["frontend"]}"
    ]
  }
}

resource "aws_security_group" "allow_redis" {
  name        = "Allow Redis"
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${var.default_tags}"

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    cidr_blocks     = [
      "${var.vpc_subnets["services"]}",
      "${var.vpc_subnets["frontend"]}"
    ]
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "Allow SSH"
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${var.default_tags}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = [
      "${var.vpc_subnets["services"]}",
      "${var.vpc_subnets["frontend"]}"
    ]
  }
}

resource "aws_security_group" "allow_all_private" {
  name        = "allow_all_private"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${var.default_tags}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks     = [
      "${var.vpc_subnets["services"]}",
      "${var.vpc_subnets["frontend"]}"
    ]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = [
      "${var.vpc_subnets["services"]}"
    ]
  }
}

resource "aws_security_group" "allow_all_public" {
  name        = "allow_all_public"
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

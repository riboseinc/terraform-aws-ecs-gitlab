data "aws_region" "current" {}

resource "aws_vpc" "main" {
  cidr_block            = "${var.vpc_cidr_block}"
  tags                  = "${var.default_tags}"
  instance_tenancy      = "default"
  enable_dns_hostnames  = true
  enable_dns_support    = true
}

resource "aws_internet_gateway" "main" {
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${var.default_tags}"
}

resource "aws_subnet" "services" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.vpc_subnets["services"]}"
  tags                    = "${var.default_tags}"
  availability_zone       = "${data.aws_region.current.name}a"
}

resource "aws_subnet" "frontend" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.vpc_subnets["frontend"]}"
  tags                    = "${var.default_tags}"
  availability_zone       = "${data.aws_region.current.name}b"
}

resource "aws_subnet" "rds_a" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.vpc_subnets["rds_a"]}"
  tags                    = "${var.default_tags}"
  availability_zone       = "${data.aws_region.current.name}a"
}

resource "aws_subnet" "rds_b" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.vpc_subnets["rds_b"]}"
  tags                    = "${var.default_tags}"
  availability_zone       = "${data.aws_region.current.name}b"
}

resource "aws_route_table" "main" {
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${var.default_tags}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
}

resource "aws_eip" "nat" {
  vpc   = true
  tags  = "${var.default_tags}"
}

resource "aws_nat_gateway" "main" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.frontend.id}"
  tags          = "${var.default_tags}"
}

resource "aws_route_table" "nat" {
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${var.default_tags}"

  route {
    cidr_block      = "0.0.0.0/0"
    nat_gateway_id  = "${aws_nat_gateway.main.id}"
  }
}

resource "aws_route_table_association" "services" {
  subnet_id      = "${aws_subnet.services.id}"
  route_table_id = "${aws_route_table.nat.id}"
}

resource "aws_route_table_association" "frontend" {
  subnet_id      = "${aws_subnet.frontend.id}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_route_table_association" "rds_a" {
  subnet_id      = "${aws_subnet.rds_a.id}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_route_table_association" "rds_b" {
  subnet_id      = "${aws_subnet.rds_b.id}"
  route_table_id = "${aws_route_table.main.id}"
}

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

#
# Public subnets (IGW)
#

resource "aws_subnet" "public" {
  count             = "${length(var.vpc_public_subnets)}"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${element(values(var.vpc_public_subnets), count.index)}"
  tags              = "${var.default_tags}"
  availability_zone = "${data.aws_region.current.name}${element(keys(var.vpc_public_subnets), count.index)}"
}

resource "aws_route_table" "public" {
  count   = "${length(var.vpc_public_subnets)}"
  vpc_id  = "${aws_vpc.main.id}"
  tags    = "${var.default_tags}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
}

resource "aws_route_table_association" "frontend_a" {
  count          = "${length(var.vpc_public_subnets)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}

#
# Private subnets (NAT)
#

resource "aws_eip" "private" {
  count = "${length(var.vpc_private_subnets)}"
  vpc   = true
  tags  = "${var.default_tags}"
}

resource "aws_subnet" "private" {
  count             = "${length(var.vpc_private_subnets)}"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${element(values(var.vpc_private_subnets), count.index)}"
  tags              = "${var.default_tags}"
  availability_zone = "${data.aws_region.current.name}${element(keys(var.vpc_private_subnets), count.index)}"
}

resource "aws_nat_gateway" "private" {
  count         = "${length(var.vpc_private_subnets)}"
  allocation_id = "${element(aws_eip.private.*.id, count.index)}"
  subnet_id     = "${aws_subnet.public.0.id}"
  tags          = "${var.default_tags}"
}

resource "aws_route_table" "private" {
  count       = "${length(var.vpc_private_subnets)}"
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${var.default_tags}"
  route {
    cidr_block      = "0.0.0.0/0"
    nat_gateway_id  = "${element(aws_nat_gateway.private.*.id, count.index)}"
  }
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.vpc_private_subnets)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

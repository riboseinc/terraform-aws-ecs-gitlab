resource "aws_vpc" "main" {
  cidr_block            = "${var.vpc_cidr_block}"
  tags                  = "${var.default_tags}"
  instance_tenancy      = "default"
  enable_dns_hostnames  = true
  enable_dns_support    = true
}

#
# Public subnets (IGW)
#

resource "aws_internet_gateway" "main" {
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${var.default_tags}"
}

resource "aws_subnet" "public" {
  count             = "${length(var.vpc_public_subnets)}"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${element(values(var.vpc_public_subnets), count.index)}"
  tags              = "${var.default_tags}"
  availability_zone = "${data.aws_region.current.name}${element(keys(var.vpc_public_subnets), count.index)}"
}

resource "aws_route_table" "public" {
  vpc_id  = "${aws_vpc.main.id}"
  tags    = "${var.default_tags}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.vpc_public_subnets)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

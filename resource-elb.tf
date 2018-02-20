resource "aws_elb" "main" {
  name                        = "${var.prefix}"
  tags                        = "${var.default_tags}"
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  subnets                     = [
    "${aws_subnet.services.id}",
    "${aws_subnet.frontend.id}"
  ]
  security_groups             = [
    "${aws_security_group.allow_all_egress.id}",
    "${aws_security_group.allow_web_public.id}"
  ]

  listener {
    instance_port       = 80
    instance_protocol   = "http"
    lb_port             = 80
    lb_protocol         = "http"
  }
}

output "Web access" {
  value = "http://${aws_elb.main.dns_name}"
}

resource "aws_lb" "gitlab" {
  name              = "${var.prefix}"
  internal          = false
  tags              = "${var.default_tags}"
  security_groups   = [
    "${aws_security_group.allow_all_egress.id}",
    "${aws_security_group.allow_web_public.id}"
  ]
  subnets           = [ "${aws_subnet.public.*.id}" ]
}

resource "aws_lb_target_group" "http" {
  name_prefix   = "${var.prefix}"
  tags          = "${var.default_tags}"
  port          = 80
  protocol      = "HTTP"
  vpc_id        = "${aws_vpc.main.id}"
  health_check {
    interval            = 60
    timeout             = 10
    healthy_threshold   = 5
    unhealthy_threshold = 5
    protocol = "HTTP"
    matcher  = "200"
    path     = "/users/sign_in"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.gitlab.arn}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = "${aws_lb_target_group.http.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "https" {
  count             = "${var.load_balancer["https"] == 1 ? 1 : 0}"
  load_balancer_arn = "${aws_lb.gitlab.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-0-2015-04"
  certificate_arn   = "${aws_iam_server_certificate.gitlab.arn}"
  default_action {
    target_group_arn = "${aws_lb_target_group.http.arn}"
    type             = "forward"
  }
}

output "Web_access" {
  value = "${local.gitlab_address}"
}

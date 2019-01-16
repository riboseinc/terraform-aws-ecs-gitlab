resource "aws_iam_server_certificate" "gitlab" {
  count            = "${var.certificate_self_signed == 1 ? 1 : 0}"
  name_prefix      = "${var.prefix}"
  certificate_body = "${tls_locally_signed_cert.gitlab.cert_pem}"
  private_key      = "${tls_private_key.gitlab.private_key_pem}"
}

resource "aws_lb" "gitlab" {
  name     = "${var.prefix}"
  internal = false
  subnets  = ["${var.subnets}"]

  security_groups = [
    "${aws_security_group.allow_all_egress.id}",
    "${aws_security_group.allow_web_public.id}",
  ]
}

resource "aws_lb_target_group" "http" {
  name_prefix = "${replace(var.prefix, "/(.{0,6})(.*)/", "$1")}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"

  health_check {
    interval            = 60
    timeout             = 10
    healthy_threshold   = 5
    unhealthy_threshold = 5
    protocol            = "HTTP"
    matcher             = "200"
    path                = "/users/sign_in"
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
  load_balancer_arn = "${aws_lb.gitlab.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-0-2015-04"
  certificate_arn   = "${var.certificate_self_signed == 1 ? element(concat(aws_iam_server_certificate.gitlab.*.arn, list("")), 0) : var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.http.arn}"
    type             = "forward"
  }
}

output "gitlab_web_endpoint" {
  value = "${local.gitlab_address}"
}

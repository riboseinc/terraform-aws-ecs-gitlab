# resource "aws_instance" "gitlab_runner" {
#   count                       = "${var.gitlab_runners["count"]}"
#   ami                         = "${data.aws_ami.amazon_linux.id}"
#   instance_type               = "${var.gitlab_runners["instance-type"]}"
#   associate_public_ip_address = false
#   subnet_id                   = "${aws_subnet.private.0.id}"
#   tags                        = "${var.default_tags}"
#   key_name                    = "${aws_key_pair.main.key_name}"
#   user_data                   = "${data.template_file.ranners.rendered}"
#   iam_instance_profile        = "${aws_iam_instance_profile.runner.name}"
#   vpc_security_group_ids      = [
#     "${aws_security_group.allow_all_public.id}"
#   ]
# }

resource "aws_instance" "test" {
  count                       = "${var.test == 1 ? 1 : 0}"
  ami                         = "${data.aws_ami.amazon-ecs-optimized.id}"
  instance_type               = "t2.nano"
  associate_public_ip_address = true
  subnet_id                   = "${aws_subnet.public.0.id}"
  tags                        = "${var.default_tags}"
  key_name                    = "${aws_key_pair.main.key_name}"
  vpc_security_group_ids      = [
    "${aws_security_group.allow_all_public.id}"
  ]
}

output "Test Instance" {
  value = "${element(concat(aws_instance.test.*.public_ip, list("")), 0)}"
}

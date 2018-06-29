resource "aws_instance" "test_instance" {
  count                       = "${var.test_instance == 1 ? 1 : 0}"
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
  value = "${element(concat(aws_instance.test_instance.*.public_ip, list("")), 0)}"
}

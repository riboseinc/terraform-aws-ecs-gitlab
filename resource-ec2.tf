resource "aws_instance" "ecs" {
  depends_on                  = [ "aws_route_table.nat" ]
  count                       = "${var.ecs_instances["count"]}"
  ami                         = "${data.aws_ami.amazon-ecs-optimized.id}"
  tags                        = "${var.default_tags}"
  instance_type               = "${var.ecs_instances["instance_type"]}"
  subnet_id                   = "${aws_subnet.services.id}"
  key_name                    = "${aws_key_pair.main.key_name}"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs.name}"
  user_data                   = "${data.template_file.ecs_instances.rendered}"
  vpc_security_group_ids      = [
    "${aws_security_group.allow_all_public.id}"
  ]
}

resource "aws_instance" "test" {
  count                       = "${var.test == 1 ? 1 : 0}"
  ami                         = "${data.aws_ami.amazon-ecs-optimized.id}"
  instance_type               = "t2.nano"
  associate_public_ip_address = true
  subnet_id                   = "${aws_subnet.frontend.id}"
  tags                        = "${var.default_tags}"
  key_name                    = "${aws_key_pair.main.key_name}"
  vpc_security_group_ids      = [
    "${aws_security_group.allow_all_public.id}"
  ]
}

output "Test Instance" {
  value = "${element(concat(aws_instance.test.*.public_ip, list("")), 0)}"
}

output "ECS Instances" {
  value = "${join(",", aws_instance.ecs.*.private_ip)}"
}

resource "aws_launch_configuration" "ecs_instances" {
  name_prefix                 = "${var.prefix}"
  image_id                    = "${data.aws_ami.amazon-ecs-optimized.id}"
  instance_type               = "${var.ecs_instances["instance_type"]}"
  key_name                    = "${aws_key_pair.main.key_name}"
  security_groups             = [ "${aws_security_group.allow_all_public.id}" ]
  iam_instance_profile        = "${aws_iam_instance_profile.ecs.name}"
  user_data                   = "${data.template_file.ecs_instances.rendered}"
  associate_public_ip_address = false
  enable_monitoring           = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs_instances" {
  name                 = "${var.prefix}"
  vpc_zone_identifier  = [ "${aws_subnet.private.*.id}" ]
  launch_configuration = "${aws_launch_configuration.ecs_instances.name}"
  min_size             = "${var.ecs_instances["min_size"]}"
  max_size             = "${var.ecs_instances["max_size"]}"
  termination_policies = [ "OldestLaunchConfiguration" ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "ecs_instances_scale_up" {
    name                    = "${var.prefix}-ecs_instances_scale_up"
    adjustment_type         = "ChangeInCapacity"
    policy_type             = "SimpleScaling"
    cooldown                = 300
    autoscaling_group_name  = "${aws_autoscaling_group.ecs_instances.name}"
    scaling_adjustment      = 1
}

resource "aws_autoscaling_policy" "ecs_instances_scale_down" {
    name                    = "${var.prefix}-ecs_instances_scale_down"
    adjustment_type         = "ChangeInCapacity"
    policy_type             = "SimpleScaling"
    cooldown                = 300
    autoscaling_group_name  = "${aws_autoscaling_group.ecs_instances.name}"
    scaling_adjustment      = -1
}

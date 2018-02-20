data "aws_ami" "amazon-ecs-optimized" {
  most_recent = true

  filter {
    name   = "name"
    values = [ "amzn-ami*amazon-ecs-optimized" ]
  }

  filter {
    name   = "virtualization-type"
    values = [ "hvm" ]
  }

  owners = [ "amazon" ]
}

data "template_file" "ecs_instances" {
  template = "${file("${path.module}/scripts/user-data.sh")}"
  vars {
    efs_address      = "${aws_efs_mount_target.main.ip_address}"
    ecs_cluster      = "${aws_ecs_cluster.main.name}"
  }
}

resource "aws_efs_file_system" "gitlab" {
  creation_token = "${var.prefix}"
}

resource "aws_efs_mount_target" "gitlab" {
  count          = "${length(var.subnets)}"
  file_system_id = "${aws_efs_file_system.gitlab.id}"
  subnet_id      = "${var.subnets[count.index]}"

  security_groups = [
    "${aws_security_group.allow_all_egress.id}",
    "${aws_security_group.allow_all_subnets_vpc.id}",
  ]
}

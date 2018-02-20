resource "aws_efs_file_system" "main" {
  tags = "${var.default_tags}"
}

resource "aws_efs_mount_target" "main" {
  file_system_id = "${aws_efs_file_system.main.id}"
  subnet_id      = "${aws_subnet.services.id}"
  security_groups = [
    "${aws_security_group.allow_all_public.id}"
  ]
}

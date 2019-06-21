resource "aws_key_pair" "runners" {
  key_name_prefix = "${var.prefix}-runners"
  public_key      = tls_private_key.runners-ssh.public_key_openssh
}

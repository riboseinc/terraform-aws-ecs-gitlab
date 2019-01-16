resource "random_id" "s3-gitlab" {
  byte_length = 8
}

resource "aws_s3_bucket" "gitlab" {
  bucket        = "${var.prefix}-gitlab-${random_id.s3-gitlab.hex}"
  force_destroy = true
}

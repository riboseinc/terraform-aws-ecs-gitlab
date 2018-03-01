resource "random_id" "s3-gitlab-backups" {
  byte_length = 8
}

resource "aws_s3_bucket" "s3-gitlab-backups" {
  bucket        = "${var.prefix}-gitlab-backups-${random_id.s3-gitlab-backups.hex}"
  tags          = "${var.default_tags}"
  force_destroy = "${var.force_destroy_backups}"
}

resource "aws_s3_bucket" "s3-gitlab-runner-cache" {
  bucket        = "${var.prefix}-gitlab-runner-cache"
  tags          = "${var.default_tags}"
  force_destroy = true
}

output "Backup butcket" {
  value = "${aws_s3_bucket.s3-gitlab-backups.id}"
}

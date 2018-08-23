resource "random_id" "s3-gitlab" {
  byte_length = 8
}

resource "aws_s3_bucket" "s3-gitlab-backups" {
  bucket        = "${var.prefix}-gitlab-backups-${random_id.s3-gitlab.hex}"
  tags          = "${var.default_tags}"
  force_destroy = "${var.force_destroy_backups}"
}

resource "aws_s3_bucket" "s3-gitlab-runner-cache" {
  bucket        = "${var.prefix}-gitlab-runner-cache-${random_id.s3-gitlab.hex}"
  tags          = "${var.default_tags}"
  force_destroy = true
}

resource "aws_s3_bucket" "s3-gitlab-artifacts" {
  bucket        = "${var.prefix}-gitlab-rartifacts-${random_id.s3-gitlab.hex}"
  tags          = "${var.default_tags}"
  force_destroy = true
}

resource "aws_s3_bucket" "s3-gitlab-lfs" {
  bucket        = "${var.prefix}-gitlab-lfs-${random_id.s3-gitlab.hex}"
  tags          = "${var.default_tags}"
  force_destroy = true
}

resource "aws_s3_bucket" "s3-gitlab-uploads" {
  bucket        = "${var.prefix}-gitlab-uploads-${random_id.s3-gitlab.hex}"
  tags          = "${var.default_tags}"
  force_destroy = true
}

output "Backup_butcket" {
  value = "${aws_s3_bucket.s3-gitlab-backups.id}"
}

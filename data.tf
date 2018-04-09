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

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = [ "amzn-ami-hvm-*-x86_64-gp2" ]
  }

  filter {
    name   = "virtualization-type"
    values = [ "hvm" ]
  }

  owners = [ "amazon" ]
}

data "template_file" "ecs_instances" {
  template = "${file("${path.module}/cloud-init/ecs.yml")}"
  vars {
    efs_address      = "${aws_efs_mount_target.main.ip_address}"
    ecs_cluster      = "${aws_ecs_cluster.main.name}"
    GITLAB_CONCURRENT_JOB     = "${var.gitlab_runners["concurrent"]}"
    GITLAB_CHECK_INTERVAL     = "${var.gitlab_runners["check_interval"]}"
    GITLAB_RUNNER_URL         = "${local.gitlab_address}"
    GITLAB_RUNNER_TOKEN       = "${random_string.gitlab_shared_runners_registration_token.result}"
    GITLAB_IMAGE              = "${var.gitlab_runners["docker_image"]}"
    GITLAB_CACHE_BUCKET_NAME  = "${aws_s3_bucket.s3-gitlab-runner-cache.id}"
    GITLAB_SELF_SIGNED        = "${var.load_balancer["self_signed"] == 1 ? 1 : 0}"
    GITLAB_SELF_SIGNED_CA     = "${jsonencode(tls_self_signed_cert.ca.cert_pem)}"
    REGION                    = "${data.aws_region.current.name}"
  }
}

data "aws_caller_identity" "current" {}

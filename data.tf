data "aws_region" "current" {}

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
    ecs_cluster               = "${aws_ecs_cluster.main.name}"
    GITLAB_CONCURRENT_JOB     = "${var.gitlab_runners["concurrent"]}"
    GITLAB_CHECK_INTERVAL     = "${var.gitlab_runners["check_interval"]}"
    GITLAB_RUNNER_URL         = "${local.gitlab_address}"
    GITLAB_RUNNER_TOKEN       = "${random_string.gitlab_shared_runners_registration_token.result}"
    GITLAB_CACHE_BUCKET_NAME  = "${aws_s3_bucket.s3-gitlab-runner-cache.id}"
    GITLAB_SELF_SIGNED        = "${var.load_balancer["self_signed"] == 1 ? 1 : 0}"
    GITLAB_SELF_SIGNED_CA     = "${jsonencode(tls_self_signed_cert.ca.cert_pem)}"
    REGION                    = "${data.aws_region.current.name}"
    RUNNER_LIMIT              = "${var.gitlab_runners["RUNNER_LIMIT"]}"
    DOCKER_IMAGE              = "${var.gitlab_runners["DOCKER_IMAGE"]}"
    RUNNER_INSTANCE_TYPE      = "${var.gitlab_runners["instance_type"]}"
    RUNNER_VPC                = "${aws_vpc.main.id}"
    RUNNER_SUBNET             = "${aws_subnet.public.1.id}"
    RUNNER_IAM                = "${aws_iam_instance_profile.runner.name}"
    RUNNER_SG                 = "${aws_security_group.runner.name}"
    RUNNER_KEY_NAME           = "${aws_key_pair.runners.key_name}"
    RUNNER_KEY_PRIVATE        = "${jsonencode(tls_private_key.runners-ssh.private_key_pem)}"
    RUNNER_KEY_PUB            = "${tls_private_key.runners-ssh.public_key_openssh}"
    IDLE_COUNT                = "${var.gitlab_runners["IDLE_COUNT"]}"
    IDLE_TIME                 = "${var.gitlab_runners["IDLE_TIME"]}"
  }
}

data "aws_caller_identity" "current" {}

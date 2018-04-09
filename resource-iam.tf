#
# ECS
#

resource "aws_iam_role" "ecs_instance_role" {
  name_prefix         = "${var.prefix}"
  assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ecs" {
  name_prefix = "${var.prefix}"
  path        = "/"
  role        = "${aws_iam_role.ecs_instance_role.name}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy_attachment" "ecs_instance_AmazonEC2ContainerServiceforEC2Role" {
  name        = "${var.prefix}-ecs_service_ec2_role"
  roles       = [ "${aws_iam_role.ecs_instance_role.name}" ]
  policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_policy_attachment" "ecs_instance_AmazonRoute53FullAccess" {
  name        = "${var.prefix}-ecs_service_ec2_role"
  roles       = [ "${aws_iam_role.ecs_instance_role.name}" ]
  policy_arn  = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_policy_attachment" "ecs_instance_AmazonEC2ContainerRegistryPowerUser" {
  name        = "${var.prefix}-ecs_service_ec2_role"
  roles       = [ "${aws_iam_role.ecs_instance_role.name}" ]
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_policy_attachment" "ecs_instance_CloudWatchEventsFullAccess" {
  name        = "${var.prefix}-ecs_service_ec2_role"
  roles       = [ "${aws_iam_role.ecs_instance_role.name}" ]
  policy_arn  = "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"
}

resource "aws_iam_role_policy" "ecs_instance_role" {
  name_prefix = "${var.prefix}"
  role        = "${aws_iam_role.ecs_instance_role.id}"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeAutoScalingGroups",
        "ec2:Describe*",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecs:StartTask",
        "cloudwatch:PutMetricData",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:DeregisterTargets"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListAllMyBuckets"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:GetBucketAcl",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.s3-gitlab-backups.id}",
        "arn:aws:s3:::${aws_s3_bucket.s3-gitlab-backups.id}/*"
      ]
    }
  ]
}
EOF
}

#
# GitLab Runner
#
resource "aws_iam_role" "runner_instance_role" {
  name_prefix         = "${var.prefix}"
  assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "runner" {
  name_prefix = "${var.prefix}"
  path        = "/"
  role        = "${aws_iam_role.runner_instance_role.name}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "runner_instance_role" {
  name_prefix = "${var.prefix}"
  role        = "${aws_iam_role.runner_instance_role.id}"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListAllMyBuckets"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:GetBucketAcl",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.s3-gitlab-runner-cache.id}",
        "arn:aws:s3:::${aws_s3_bucket.s3-gitlab-runner-cache.id}/*"
      ]
    }
  ]
}
EOF
}

#
# Other
#

resource "aws_iam_server_certificate" "gitlab" {
  name_prefix      = "${var.prefix}"
  count            = "${var.load_balancer["https"] == 1 ? 1 : 0}"
  name_prefix      = "${var.prefix}"
  certificate_body = "${var.load_balancer["self_signed"] == 1 ? tls_locally_signed_cert.gitlab.cert_pem : var.load_balancer["certificate_body"]}"
  private_key      = "${var.load_balancer["self_signed"] == 1 ? tls_private_key.gitlab.private_key_pem : var.load_balancer["private_key"]}"
}

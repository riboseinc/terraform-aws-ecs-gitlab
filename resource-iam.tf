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
        "ec2:CreateKeyPair",
        "ec2:DeleteKeyPair",
        "ec2:ImportKeyPair",
        "ec2:CreateSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateTags",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ec2:RunInstances",
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
      "Sid": "TheseActionsSupportResourceLevelPermissions",
      "Effect": "Allow",
      "Action": [
          "ec2:TerminateInstances",
          "ec2:StopInstances",
          "ec2:StartInstances",
          "ec2:RebootInstances"
      ],
      "Condition": {
          "StringEquals": {
              "ec2:ResourceTag/created-by": "gitlab-ci-runners"
          }
      },
      "Resource": [
          "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.runner_instance_role.name}"
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
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.s3-gitlab-backups.id}",
        "arn:aws:s3:::${aws_s3_bucket.s3-gitlab-backups.id}/*",
        "arn:aws:s3:::${aws_s3_bucket.s3-gitlab-runner-cache.id}",
        "arn:aws:s3:::${aws_s3_bucket.s3-gitlab-runner-cache.id}/*",
        "arn:aws:s3:::${aws_s3_bucket.s3-gitlab-artifacts.id}",
        "arn:aws:s3:::${aws_s3_bucket.s3-gitlab-artifacts.id}/*",
        "arn:aws:s3:::${aws_s3_bucket.s3-gitlab-lfs.id}",
        "arn:aws:s3:::${aws_s3_bucket.s3-gitlab-lfs.id}/*",
        "arn:aws:s3:::${aws_s3_bucket.s3-gitlab-uploads.id}",
        "arn:aws:s3:::${aws_s3_bucket.s3-gitlab-uploads.id}/*"
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
      "Sid": "TheseActionsSupportResourceLevelPermissions",
      "Effect": "Allow",
      "Action": [
          "ec2:Describe*"
      ],
      "Resource": [
          "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
          "ec2:TerminateInstances",
          "ec2:StopInstances"
      ],
      "Condition": {
          "StringEquals": {
              "ec2:ResourceTag/created-by": "gitlab-ci-runners"
          }
      },
      "Resource": [
          "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:DescribeClusters"
      ],
      "Resource": "*"
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

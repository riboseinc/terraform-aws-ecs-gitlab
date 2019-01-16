resource "aws_iam_role" "ecs_task" {
  name_prefix = "${var.prefix}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com",
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = "${aws_iam_role.ecs_task.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_task" {
  name_prefix = "${var.prefix}"
  role        = "${aws_iam_role.ecs_task.id}"

  policy = <<EOF
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
      "Action": [
        "iam:PassRole",
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
        "s3:GetBucketLocation",
        "s3:ListAllMyBuckets"
      ],
      "Resource": [
          "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.gitlab.id}",
        "arn:aws:s3:::${aws_s3_bucket.gitlab.id}/*"
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

resource "aws_iam_role" "ecs_service" {
  name_prefix = "${var.prefix}"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
        "Service": [
          "ec2.amazonaws.com",
          "ecs.amazonaws.com"
        ]
        }
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "ecs_service" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  role       = "${aws_iam_role.ecs_service.id}"
}

resource "aws_iam_role_policy" "ecs_service" {
  name_prefix = "${var.prefix}"
  role        = "${aws_iam_role.ecs_service.id}"

  policy = <<EOF
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
    }
  ]
}
EOF
}

#
# GitLab runner instance
#

resource "aws_iam_role" "gitlab_runner_instance" {
  name_prefix = "${var.prefix}"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "ec2.amazonaws.com"
          ]
        }
      }
    ]
  }
  EOF
}

resource "aws_iam_instance_profile" "gitlab_runner_instance" {
  name_prefix = "${var.prefix}"
  path        = "/"
  role        = "${aws_iam_role.gitlab_runner_instance.name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "gitlab_runner_instance" {
  name_prefix = "${var.prefix}"
  role        = "${aws_iam_role.gitlab_runner_instance.id}"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "TheseActionsSupportResourceLevelPermissions",
        "Effect": "Allow",
        "Action": [
          "s3:GetBucketLocation",
          "s3:ListAllMyBuckets",
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
          "s3:*"
        ],
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.gitlab.id}",
          "arn:aws:s3:::${aws_s3_bucket.gitlab.id}/*"
        ]
      }
    ]
  }
  EOF
}

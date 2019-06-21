resource "random_string" "gitlab_root_password" {
  length = 16
  upper  = true
  lower  = true
  number = true

  keepers = {
    rds_id = aws_db_instance.main.id
  }
}

resource "random_string" "gitlab_shared_runners_registration_token" {
  length  = 32
  upper   = true
  lower   = true
  number  = false
  special = false
}

resource "random_id" "ecs_id" {
  byte_length = 4
}

resource "aws_ecs_task_definition" "gitlab" {
  family                   = "gitlab-${random_id.ecs_id.hex}"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  task_role_arn            = aws_iam_role.ecs_task.arn
  execution_role_arn       = aws_iam_role.ecs_task.arn
  cpu                      = 2048
  memory                   = 4096

  container_definitions = <<-EOF
    [
      {
        "name": "gitlab-server",
        "image": "gitlab/gitlab-ce:latest",
        "essential": true,
        "environment" : [
            {
              "name" : "GITLAB_OMNIBUS_CONFIG",
              "value" : "${join("; ", local.gitlab_omnibus_config)}"
            },
            {
              "name" : "GITLAB_ROOT_PASSWORD",
              "value" : "${random_string.gitlab_root_password.result}"
            },
            {
              "name" : "GITLAB_SHARED_RUNNERS_REGISTRATION_TOKEN",
              "value" : "${random_string.gitlab_shared_runners_registration_token.result}"
            }
        ],
        "portMappings": [
          {
            "containerPort": 80,
            "protocol": "tcp"
          }
        ],
        "mountPoints": [
          {
            "sourceVolume": "gitlab-${random_id.ecs_id.hex}-server-config",
            "containerPath": "/etc/gitlab/"
          },
          {
            "sourceVolume": "gitlab-${random_id.ecs_id.hex}-server-data",
            "containerPath": "/gitlab-data"
          }
        ]
      },
      {
        "name": "provisioner",
        "image": "centos:7",
        "essential": false,
        "entrypoint": [
          "bash",
          "-cx"
        ],
        "command": [
          "mkdir -p /etc/efs/{server,runner} && mkdir -p /etc/efs/server/{data,config} && echo -e \"$CA_BUNDLE\" | tee /etc/efs/runner/ca_bundle.pem && echo -e \"$SSH_KEY_RUNNERS\" | tee /etc/efs/runner/id_rsa && chmod 0600 /etc/efs/runner/id_rsa && ssh-keygen -y -f /etc/efs/runner/id_rsa > /etc/efs/runner/id_rsa.pub"
        ],
        "environment" : [
          {
            "name" : "CA_BUNDLE",
            "value" : "${replace(var.certificate_self_signed == 1 ? element(concat(tls_self_signed_cert.ca.*.cert_pem, list("")), 0) : "", "\n", "\\n")}"
          },
          {
            "name" : "SSH_KEY_RUNNERS",
            "value" : "${replace(tls_private_key.runners-ssh.private_key_pem, "\n", "\\n")}"
          }
        ],
        "mountPoints": [
          {
            "sourceVolume": "gitlab-${random_id.ecs_id.hex}-provisioner",
            "containerPath": "/etc/efs/"
          }
        ]
      },
      {
        "name": "gitlab-runner",
        "image": "${var.gitlab_runners["image"]}",
        "essential": true,
        "entrypoint": [
          "bash",
          "-cx"
        ],
        "command": [
          "until curl -sk --connect-timeout 3 --max-time 10 ${local.gitlab_address}/users/sign_in | grep -w 'Sign in'; do sleep 10; done && gitlab-runner verify -n gitlab-runner-${random_id.ecs_id.hex} || until gitlab-runner register --description gitlab-runner-${random_id.ecs_id.hex} --machine-machine-options amazonec2-tags=created-by,gitlab-ci-runners --machine-machine-options amazonec2-region=${data.aws_region.current.name} --machine-machine-options amazonec2-instance-type=${var.gitlab_runners["instance_type"]} --machine-machine-options amazonec2-vpc-id=${var.vpc_id} --machine-machine-options amazonec2-keypair-name=${aws_key_pair.runners.key_name} --machine-machine-options amazonec2-ssh-keypath=/etc/gitlab-runner/id_rsa --machine-machine-options amazonec2-request-spot-instance=false --machine-machine-options amazonec2-iam-instance-profile=${aws_iam_instance_profile.gitlab_runner_instance.name} ${var.certificate_self_signed == 1 ? "--tls-ca-file /etc/gitlab-runner/ca_bundle.pem" : ""}; do sleep 30; done && gitlab-runner run"
        ],
        "environment" : [
            {
              "name" : "RUNNER_NAME",
              "value" : "gitlab-runner-${random_id.ecs_id.hex}"
            },
            {
              "name" : "REGISTER_NON_INTERACTIVE",
              "value" : "true"
            },
            {
              "name" : "REGISTER_LOCKED",
              "value" : "false"
            },
            {
              "name" : "REGISTER_RUN_UNTAGGED",
              "value" : "true"
            },
            {
              "name" : "CI_SERVER_URL",
              "value" : "${local.gitlab_address}"
            },
            {
              "name" : "REGISTRATION_TOKEN",
              "value" : "${random_string.gitlab_shared_runners_registration_token.result}"
            },
            {
              "name" : "DOCKER_IMAGE",
              "value" : "${var.gitlab_runners["DOCKER_IMAGE"]}"
            },
            {
              "name" : "DOCKER_PRIVILEGED",
              "value" : "true"
            },
            {
              "name" : "DOCKER_DISABLE_CACHE",
              "value" : "false"
            },
            {
              "name" : "CACHE_TYPE",
              "value" : "s3"
            },
            {
              "name" : "CACHE_S3_BUCKET_NAME",
              "value" : "${aws_s3_bucket.gitlab.id}"
            },
            {
              "name" : "CACHE_S3_BUCKET_LOCATION",
              "value" : "${data.aws_region.current.name}"
            },
            {
              "name" : "S3_CACHE_INSECURE",
              "value" : "false"
            },
            {
              "name" : "CACHE_SHARED",
              "value" : "true"
            },
            {
              "name" : "MACHINE_IDLE_COUNT",
              "value" : "${var.gitlab_runners["IDLE_COUNT"]}"
            },
            {
              "name" : "MACHINE_IDLE_TIME",
              "value" : "${var.gitlab_runners["IDLE_TIME"]}"
            },
            {
              "name" : "MACHINE_DRIVER",
              "value" : "amazonec2"
            },
            {
              "name" : "MACHINE_NAME",
              "value" : "runner-%s"
            },
            {
              "name" : "CONFIG_FILE",
              "value" : "/etc/gitlab-runner/gitlab-runner-config.toml"
            },
            {
              "name" : "RUNNER_EXECUTOR",
              "value" : "docker+machine"
            }
        ],
        "mountPoints": [
          {
            "sourceVolume": "gitlab-${random_id.ecs_id.hex}-runner",
            "containerPath": "/etc/gitlab-runner/"
          }
        ]
      }
    ]
EOF


  volume {
    name = "gitlab-${random_id.ecs_id.hex}-server-data"

    docker_volume_configuration {
      autoprovision = true
      scope = "shared"
      driver = "local"

      driver_opts = {
        type = "nfs"
        device = "${aws_efs_file_system.gitlab.dns_name}:/server/data"
        o = "addr=${aws_efs_file_system.gitlab.dns_name},nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport"
      }
    }
  }

  volume {
    name = "gitlab-${random_id.ecs_id.hex}-server-config"

    docker_volume_configuration {
      autoprovision = true
      scope = "shared"
      driver = "local"

      driver_opts = {
        type = "nfs"
        device = "${aws_efs_file_system.gitlab.dns_name}:/server/config"
        o = "addr=${aws_efs_file_system.gitlab.dns_name},nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport"
      }
    }
  }

  volume {
    name = "gitlab-${random_id.ecs_id.hex}-runner"

    docker_volume_configuration {
      autoprovision = true
      scope = "shared"
      driver = "local"

      driver_opts = {
        type = "nfs"
        device = "${aws_efs_file_system.gitlab.dns_name}:/runner"
        o = "addr=${aws_efs_file_system.gitlab.dns_name},nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport"
      }
    }
  }

  volume {
    name = "gitlab-${random_id.ecs_id.hex}-provisioner"

    docker_volume_configuration {
      autoprovision = true
      scope = "shared"
      driver = "local"

      driver_opts = {
        type = "nfs"
        device = "${aws_efs_file_system.gitlab.dns_name}:/"
        o = "addr=${aws_efs_file_system.gitlab.dns_name},nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport"
      }
    }
  }
}

resource "aws_ecs_service" "gitlab" {
  name = "${var.prefix}-gitlab-${random_id.ecs_id.hex}"
  cluster = var.aws_ecs_cluster_id
  task_definition = aws_ecs_task_definition.gitlab.arn
  desired_count = 1
  launch_type = "EC2"
  iam_role = aws_iam_role.ecs_service.arn
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent = 100

  load_balancer {
    target_group_arn = aws_lb_target_group.http.arn
    container_name = "gitlab-server"
    container_port = 80
  }
}

output "gitlab_root_password" {
  value = random_string.gitlab_root_password.result
}

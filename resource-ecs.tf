resource "random_string" "gitlab_root_password" {
  length  = 16
  upper   = true
  lower   = true
  number  = true
  keepers = {
    rds_id = "${aws_db_instance.main.id}"
  }
}

resource "random_string" "gitlab_shared_runners_registration_token" {
  length  = 16
  upper   = true
  lower   = true
  number  = true
  special = false
}

resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}"
}

resource "aws_ecs_task_definition" "gitlab-servers" {
  depends_on                = [ "aws_instance.ecs_instances" ]
  family                    = "gitlab"
  requires_compatibilities  = [ "EC2" ]
  cpu                       = "${var.gitlab_servers["cpu"]}"
  memory                    = "${var.gitlab_servers["memory"]}"
  network_mode              = "bridge"
  volume {
    name      = "gitlab-config"
    host_path = "/srv/gitlab/configs"
  }
  volume {
    name      = "gitlab-logs"
    host_path = "/srv/gitlab/logs"
  }
  volume {
    name      = "gitlab-data"
    host_path = "/data/gitlab/"
  }
  volume {
    name      = "gitlab-ssh"
    host_path = "/data/gitlab/.ssh/"
  }
  volume {
    name      = "gitlab-runner-configs"
    host_path = "/srv/gitlab-runner/config/"
  }
  container_definitions     = <<EOF
[
  {
    "name": "gitlab",
    "image": "${var.gitlab_servers["image"]}",
    "essential": true,
    "dockerLabels": {
      "service": "gitlab-server"
    },
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
        "sourceVolume": "gitlab-config",
        "containerPath": "/etc/gitlab"
      },
      {
        "sourceVolume": "gitlab-logs",
        "containerPath": "/var/log/gitlab"
      },
      {
        "sourceVolume": "gitlab-data",
        "containerPath": "/gitlab-data"
      },
      {
        "sourceVolume": "gitlab-ssh",
        "containerPath": "/var/opt/gitlab/.ssh"
      }
    ]
  }
]
EOF
}

resource "aws_ecs_service" "gitlab-servers" {
  depends_on            = ["aws_lb_listener.http"]
  name                  = "${var.prefix}-gitlab"
  cluster               = "${aws_ecs_cluster.main.id}"
  task_definition       = "${aws_ecs_task_definition.gitlab-servers.arn}"
  desired_count         = "${var.gitlab_servers["count"]}"
  launch_type           = "EC2"
  load_balancer {
    target_group_arn  = "${aws_lb_target_group.http.arn}"
    container_name    = "gitlab"
    container_port    = 80
  }
}

output "Gitlab_root_password" {
  value = "${random_string.gitlab_root_password.result}"
}

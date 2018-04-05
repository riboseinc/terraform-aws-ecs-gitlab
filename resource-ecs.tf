resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}"
}

resource "aws_ecs_task_definition" "gitlab-servers" {
  depends_on                = [ "aws_autoscaling_group.ecs_instances" ]
  family                    = "gitlab"
  requires_compatibilities  = [ "EC2" ]
  cpu                       = "${var.gitlab_servers["cpu"]}"
  memory                    = "${var.gitlab_servers["memory"]}"
  network_mode              = "bridge"
  volume {
    name      = "gitlab-config"
    host_path = "/srv/gitlab/config"
  }
  volume {
    name      = "gitlab-logs"
    host_path = "/srv/gitlab/logs"
  }
  volume {
    name      = "gitlab-data"
    host_path = "/efs/gitlab/"
  }
  volume {
    name      = "gitlab-ssh"
    host_path = "/efs/gitlab/.ssh/"
  }
  volume {
    name      = "gitlab-secrets"
    host_path = "/efs/gitlab-secrets.json"
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
          "protocol": "tcp",
          "hostPort": 80
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

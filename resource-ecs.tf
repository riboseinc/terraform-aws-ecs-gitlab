locals {
  gitlab_omnibus_config = [
    "external_url 'http://${aws_elb.main.dns_name}'",
    "redis['enable'] = false",
    "gitlab_rails['redis_host'] = '${aws_elasticache_cluster.main.cache_nodes.0.address}'",
    "gitlab_rails['redis_port'] = 6379",
    "postgresql['enable'] = false",
    "gitlab_rails['db_adapter'] = 'postgresql'",
    "gitlab_rails['db_encoding'] = 'utf8'",
    "gitlab_rails['db_host'] = '${aws_db_instance.main.address}'",
    "gitlab_rails['db_database'] = '${var.rds["database"]}'",
    "gitlab_rails['db_port'] = 5432",
    "gitlab_rails['db_username'] = '${var.rds["username"]}'",
    "gitlab_rails['db_password'] = '${random_string.gitlab_postgres_password.result}'",
    "git_data_dirs({'default' => '/gitlab-data/git-data'})",
    "user['home'] = '/gitlab-data/home'",
    "gitlab_rails['uploads_directory'] = '/gitlab-data/uploads'",
    "gitlab_rails['shared_path'] = '/gitlab-data/shared'",
    "gitlab_ci['builds_directory'] = '/gitlab-data/builds'",
    "high_availability['mountpoint'] = '/gitlab-data'",
    "gitlab_rails['backup_upload_connection'] = { 'provider' => 'AWS', 'region' => '${data.aws_region.current.name}', 'use_iam_profile' => true }",
    "gitlab_rails['backup_upload_remote_directory'] = '${aws_s3_bucket.s3-gitlab-backups.id}'",
    "gitlab_rails['backup_keep_time'] = ${var.gitlab_servers["backup_keep_time"]}"
  ]
}

resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}"
}

resource "aws_ecs_task_definition" "gitlab" {
  depends_on                = [ "aws_instance.ecs" ]
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
  container_definitions     = <<EOF
  [
    {
      "name": "gitlab",
      "image": "${var.gitlab_servers["image"]}",
      "hostname": "gitlab.example.com",
      "essential": true,
      "environment" : [
          {
            "name" : "GITLAB_OMNIBUS_CONFIG",
            "value" : "${join("; ", local.gitlab_omnibus_config)}"
          },
          {
            "name" : "GITLAB_ROOT_PASSWORD",
            "value" : "${random_string.gitlab_root_password.result}"
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
        }
      ]
    }
  ]
EOF
}

resource "aws_ecs_service" "gitlab" {
  name                  = "${var.prefix}-gitlab"
  cluster               = "${aws_ecs_cluster.main.id}"
  task_definition       = "${aws_ecs_task_definition.gitlab.arn}"
  desired_count         = "${var.gitlab_servers["count"]}"
  launch_type           = "EC2"

  load_balancer {
    elb_name       = "${aws_elb.main.name}"
    container_name = "gitlab"
    container_port = 80
  }
}

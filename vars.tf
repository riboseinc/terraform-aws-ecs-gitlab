variable "gitlab_domain" {
  default = ""
}

variable "prefix" {
  default = "ribose"
}

variable "aws_ecs_cluster_id" {
  default = ""
}

variable "vpc_id" {
  default = ""
}

# Minimum 2 subnets should be configured
variable "subnets" {
  type    = "list"
  default = []
}

variable "certificate_self_signed" {
  default = false
}

variable "certificate_arn" {
  default = "arn:..."
}

variable "gitlab_runners" {
  type = "map"

  default = {
    image          = "gitlab/gitlab-runner:latest"
    concurrent     = 10
    check_interval = 3
    instance_type  = "t2.small"
    RUNNER_LIMIT   = 3
    DOCKER_IMAGE   = "centos:7"
    IDLE_COUNT     = 0
    IDLE_TIME      = 300
  }
}

variable "elasticache" {
  type = "map"

  default = {
    node_type = "cache.t2.micro"
    version   = "5.0.0"
  }
}

variable "rds" {
  type = "map"

  default = {
    allocated_storage   = 20
    storage_type        = "gp2"
    instance_class      = "db.m3.medium"
    database            = "gitlab"
    username            = "gitlab"
    skip_final_snapshot = true
    version             = "10.6"
  }
}

locals {
  gitlab_domain  = "${var.gitlab_domain == "" ? aws_lb.gitlab.dns_name : var.gitlab_domain}"
  gitlab_address = "https://${local.gitlab_domain}/"

  gitlab_omnibus_config = [
    "external_url '${local.gitlab_address}'",
    "nginx['http2_enabled'] = true",
    "gitlab_rails['time_zone'] = 'UTC'",
    "gitlab_rails['smtp_enable'] = true",
    "nginx['listen_port'] = 80",
    "nginx['listen_https'] = false",
    "nginx['redirect_http_to_https'] = true",
    "nginx['proxy_set_headers'] = {'X-Forwarded-Proto' => 'https', 'X-Forwarded-Ssl' => 'on'}",
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
    "git_data_dirs({'default': {'path': '/gitlab-data'}})",
    "user['home'] = '/gitlab-data/home'",
    "gitlab_rails['uploads_directory'] = '/gitlab-data/uploads'",
    "gitlab_rails['shared_path'] = '/gitlab-data/shared'",
    "gitlab_ci['builds_directory'] = '/gitlab-data/builds'",
    "high_availability['mountpoint'] = '/gitlab-data'",
    "gitlab_rails['backup_upload_connection'] = { 'provider' => 'AWS', 'region' => '${data.aws_region.current.name}', 'use_iam_profile' => true }",
    "gitlab_rails['backup_upload_remote_directory'] = '${aws_s3_bucket.gitlab.id}'",
    "gitlab_rails['backup_keep_time'] = 604800",
    "gitlab_shell['secret_file'] = '/data/gitlab-secrets/gitlab-secrets.json'",
    "gitlab_rails['artifacts_enabled'] = true",
    "gitlab_rails['artifacts_object_store_enabled'] = true",
    "gitlab_rails['artifacts_object_store_remote_directory'] = '${aws_s3_bucket.gitlab.id}'",
    "gitlab_rails['artifacts_object_store_direct_upload'] = true",
    "gitlab_rails['artifacts_object_store_connection'] = { 'provider' => 'AWS', 'region' => '${data.aws_region.current.name}', 'use_iam_profile' => true }",
    "gitlab_rails['lfs_enabled'] = false",
    "gitlab_rails['lfs_object_store_enabled'] = true",
    "gitlab_rails['lfs_object_store_direct_upload'] = true",
    "gitlab_rails['lfs_object_store_remote_directory'] = '${aws_s3_bucket.gitlab.id}'",
    "gitlab_rails['lfs_object_store_connection'] = { 'provider' => 'AWS', 'region' => '${data.aws_region.current.name}', 'use_iam_profile' => true }",
    "gitlab_rails['uploads_object_store_enabled'] = true",
    "gitlab_rails['uploads_object_store_direct_upload'] = true",
    "gitlab_rails['uploads_object_store_remote_directory'] = '${aws_s3_bucket.gitlab.id}'",
    "gitlab_rails['uploads_object_store_connection'] = { 'provider' => 'AWS', 'region' => '${data.aws_region.current.name}', 'use_iam_profile' => true }",
    "gitlab_rails['gitlab_email_enabled'] = true",
    "gitlab_rails['gitlab_email_from'] = 'gitlab@${local.gitlab_domain}'",
    "gitlab_rails['gitlab_email_reply_to'] = 'noreply@${local.gitlab_domain}'",
  ]
}

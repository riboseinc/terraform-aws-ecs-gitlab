variable "force_destroy_backups" { default = true }

variable "prefix" {
  default = "ribose"
}

variable "load_balancer" {
  type    = "map"
  default = {
    https             = true
    self_signed       = true # if false, private_key and certificate_body should be set
    private_key       = <<EOF
-----BEGIN RSA PRIVATE KEY-----
...
-----END RSA PRIVATE KEY-----
EOF
    certificate_body  = <<EOF
-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----
EOF
  }
}

variable "gitlab_servers" {
  type    = "map"
  default = {
    image             = "gitlab/gitlab-ce:latest"
    count             = 1 # no more than 1 at the moment
    cpu               = 2048
    memory            = 4096
    backup_keep_time  = 604800
    volume_size       = 100
  }
}

variable "gitlab_runners" {
  type    = "map"
  default = {
    count           = 2
    concurrent      = 10
    check_interval  = 3
    instance_type   = "t2.small"
  }
}

variable "ecs_instances" {
  type      = "map"
  default   = {
    min_size        = 2
    max_size        = 5
    instance_type   = "t2.large"
  }
}

variable "elasticache" {
  type = "map"
  default = {
    node_type       = "cache.t2.micro"
    version         = "4.0.10"
  }
}

variable "rds" {
  type    = "map"
  default = {
    allocated_storage   = 20
    storage_type        = "gp2"
    instance_class      = "db.m3.medium"
    database            = "gitlab"
    username            = "gitlab"
    password            = "-g1tl4b_Passw0rd!-"
    skip_final_snapshot = true
    version             = "9.6.8"
  }
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "vpc_public_subnets" {
  type = "map"
  default = {
    a  = "10.0.30.0/24"
    b  = "10.0.40.0/24"
  }
}

variable "default_tags" {
  type = "map"
  default = {
    Name        = "GitLab"
    Provisioner = "Terraform"
  }
}

locals {
  gitlab_domain         = "${aws_lb.gitlab.dns_name}"
  gitlab_address        = "http${var.load_balancer["https"] == 1 ? "s" : ""}://${local.gitlab_domain}/"
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
    "git_data_dirs({'default': {'path': '/gitlab-data/git-data'}})",
    "user['home'] = '/gitlab-data/home'",
    "gitlab_rails['uploads_directory'] = '/gitlab-data/uploads'",
    "gitlab_rails['shared_path'] = '/gitlab-data/shared'",
    "gitlab_ci['builds_directory'] = '/gitlab-data/builds'",
    "high_availability['mountpoint'] = '/gitlab-data'",
    "gitlab_rails['backup_upload_connection'] = { 'provider' => 'AWS', 'region' => '${data.aws_region.current.name}', 'use_iam_profile' => true }",
    "gitlab_rails['backup_upload_remote_directory'] = '${aws_s3_bucket.s3-gitlab-backups.id}'",
    "gitlab_rails['backup_keep_time'] = ${var.gitlab_servers["backup_keep_time"]}",
    "gitlab_shell['secret_file'] = '/data/gitlab-secrets/gitlab-secrets.json'",
    "gitlab_rails['artifacts_enabled'] = true",
    "gitlab_rails['artifacts_object_store_enabled'] = true",
    "gitlab_rails['artifacts_object_store_remote_directory'] = '${aws_s3_bucket.s3-gitlab-artifacts.id}'",
    "gitlab_rails['artifacts_object_store_direct_upload'] = true",
    "gitlab_rails['artifacts_object_store_connection'] = { 'provider' => 'AWS', 'region' => '${data.aws_region.current.name}', 'use_iam_profile' => true }",
    "gitlab_rails['lfs_enabled'] = false",
    "gitlab_rails['lfs_object_store_enabled'] = true",
    "gitlab_rails['lfs_object_store_direct_upload'] = true",
    "gitlab_rails['lfs_object_store_remote_directory'] = '${aws_s3_bucket.s3-gitlab-lfs.id}'",
    "gitlab_rails['lfs_object_store_connection'] = { 'provider' => 'AWS', 'region' => '${data.aws_region.current.name}', 'use_iam_profile' => true }",
    "gitlab_rails['uploads_object_store_enabled'] = true",
    "gitlab_rails['uploads_object_store_direct_upload'] = true",
    "gitlab_rails['uploads_object_store_remote_directory'] = '${aws_s3_bucket.s3-gitlab-uploads.id}'",
    "gitlab_rails['uploads_object_store_connection'] = { 'provider' => 'AWS', 'region' => '${data.aws_region.current.name}', 'use_iam_profile' => true }",
    "gitlab_rails['gitlab_email_enabled'] = true",
    "gitlab_rails['gitlab_email_from'] = 'gitlab@${local.gitlab_domain}'",
    "gitlab_rails['gitlab_email_reply_to'] = 'noreply@${local.gitlab_domain}'"
  ]
}

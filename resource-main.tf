resource "aws_key_pair" "main" {
  key_name_prefix = "${var.prefix}"
  public_key      = "${file("./keys/ribose.pub")}"
}

resource "random_string" "gitlab_root_password" {
  length  = 16
  upper   = true
  lower   = true
  number  = true
  keepers = {
    rds_id = "${aws_db_instance.main.id}"
  }
}

resource "random_string" "gitlab_postgres_password" {
  length  = 16
  upper   = true
  lower   = true
  number  = true
  special = false
}

resource "random_string" "gitlab_shared_runners_registration_token" {
  length  = 16
  upper   = true
  lower   = true
  number  = true
  special = false
}

locals {
  gitlab_omnibus_config = [
    "external_url 'http://${aws_lb.gitlab.dns_name}/'",
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
    "gitlab_rails['backup_keep_time'] = ${var.gitlab_servers["backup_keep_time"]}"
  ]
}

output "Gitlab root password" {
  value = "${random_string.gitlab_root_password.result}"
}

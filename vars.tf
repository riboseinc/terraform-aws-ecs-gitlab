variable "test" { default = false }
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
    count             = 1 # no more then 1 for now
    cpu               = 2048
    memory            = 4096
    backup_keep_time  = 604800
    backup_schedule   = "daily" # backups not working for with the official gitlab-ce omnibus image
    backup_time       = "02:00"
  }
}

variable "gitlab_runners" {
  type    = "map"
  default = {
    count           = 2
    concurrent      = 10
    check_interval  = 3
    docker_image    = "centos:7"
    instance-type   = "t2.small"
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
    num_cache_nodes = 1
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
  }
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "vpc_private_subnets" {
  type = "map"
  default = {
    a  = "10.0.10.0/24"
    b  = "10.0.20.0/24"
  }
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

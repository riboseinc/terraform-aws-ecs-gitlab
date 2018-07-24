terraform {
  required_version = "~> 0.11"
  backend "s3" {
    bucket = "ribose-terraform"
    key    = "ext-tf-aws-gitlab_ecs"
    region = "us-west-2"
  }
}

provider "aws" {
  version = "~> 1.28"
}

provider "local" {
  version = "~> 1.1"
}

provider "random" {
  version = "~> 1.1"
}

provider "template" {
  version = "~> 1.0"
}

provider "tls" {
  version = "~> 1.0"
}

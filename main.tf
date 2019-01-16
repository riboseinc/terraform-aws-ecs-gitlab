terraform {
  required_version = "~> 0.11"
}

provider "aws" {
  version = "~> 1.56"
}

provider "local" {
  version = "~> 1.1"
}

provider "random" {
  version = "~> 2.0"
}

provider "template" {
  version = "~> 2.0"
}

provider "tls" {
  version = "~> 1.2"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

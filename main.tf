terraform {
  required_version = ">= 0.12"
  required_providers {
    aws      = "~> 2.16"
    local    = "~> 1.2"
    random   = "~> 2.1"
    template = "~> 2.1"
    tls      = "~> 2.0"
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

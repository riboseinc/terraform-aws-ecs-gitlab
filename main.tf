terraform {
  required_version = "~> 0.11.3"
}

provider "aws" {
  version = "~> 1.9"
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

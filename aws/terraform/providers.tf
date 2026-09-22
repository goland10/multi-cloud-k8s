terraform {
  required_version = ">= 1.13, < 2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      owner       = var.owner
      environment = local.env_name #local.cluster_name
    }
  }
}

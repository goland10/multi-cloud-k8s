terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
  }

  required_version = ">= 1.4.2"
}

provider "aws" {
  default_tags {
    tags = local.tags
  }
}

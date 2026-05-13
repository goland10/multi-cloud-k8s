terraform {
  backend "s3" {
    bucket = "github-k8s-terraform-state"
    region = "eu-west-1"
    #key    = "dev/01/terraform.tfstate"
  }
}

#t init -backend-config key=$endpoint_access/$env_type/$env_number/terraform.tfstate

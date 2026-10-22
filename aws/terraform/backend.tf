terraform {
  backend "s3" {
    bucket         = "github-k8s-terraform-state"
    #dynamodb_table = "github-k8s-terraform-state-lock"
    #encrypt        = true
    #region = "eu-west-1"
    #key    = "public/dev/01/terraform.tfstate"
  }
}

#t init -backend-config key=$endpoint_access/$env_type/$env_number/terraform.tfstate

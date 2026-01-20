variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "env_name" {
  description = "Environment name (e.g. dev-01, staging-01, prod-01)"
  type        = string
}

variable "node_identity" {
  description = "Service account ID for GKE nodes (account_id)"
  type        = string
}

variable "node_identity_roles" {
  description = "List of IAM roles to attach to the GKE node service account"
  type        = list(string)

  validation {
    condition     = length(var.node_identity_roles) > 0
    error_message = "node_identity_roles must contain at least one role."
  }
}

variable "runner_service_account" {
  description = "Service account used by GitHub Actions runner"
  type        = string
}


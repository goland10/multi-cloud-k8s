## Terraform GKE Destroy Workflow

This GitHub Actions workflow **destroys an existing GKE environment** that was previously created using Terraform.  
It is designed to safely tear down all infrastructure associated with a specific environment while reusing the same Terraform state and authentication model as the deploy workflow.

---

## What this workflow does

### 1. Manual trigger with environment selection
The workflow is triggered manually and requires the user to select:
- The environment type (`dev`, `staging`, or `prod`)
- The environment number (for example `01`)

Together, these identify the target cluster:

<env_type>-<env_number>

makefile
Copy code

Example:
staging-02

yaml
Copy code

---

### 2. Secure authentication to Google Cloud
The workflow authenticates to Google Cloud using **Workload Identity Federation (WIF)**.

GitHub Actions:
- Requests an OIDC token
- Exchanges it for a Google access token
- Impersonates the configured runner service account

No long-lived service account keys are used.

---

### 3. Terraform backend initialization
Terraform is initialized using the same remote backend configuration as the deploy workflow.

The backend prefix is set to:

<env_type>/<env_number>

yaml
Copy code

This ensures Terraform loads the **correct remote state** for the environment being destroyed.

---

### 4. Terraform destroy execution
Terraform runs `terraform destroy` with the same variables used during creation.

This:
- Reads the existing state
- Identifies all managed resources
- Deletes them in the correct dependency order

Typical resources destroyed include:
- GKE cluster
- Node pools
- IAM bindings created by Terraform
- Networking components managed in the module

The operation runs with `-auto-approve`, so no interactive confirmation is required.

---

## Required inputs

| Input | Description |
|------|------------|
| `env_type` | Environment type (`dev`, `staging`, `prod`) |
| `env_number` | Environment number used in the cluster name |

---

## Required GitHub repository variables

| Variable | Description |
|--------|-------------|
| `PROJECT_ID` | Google Cloud project ID |
| `PROJECT_NUMBER` | Google Cloud project number (required for WIF) |
| `REGION` | Default GCP region |
| `runner_service_account` | Service account impersonated by GitHub Actions |

---

## Important notes

- **Deletion protection must be disabled** before running this workflow.  
  If `deletion_protection = true` is set on the GKE cluster, Terraform will fail to destroy it.
- The workflow assumes the Terraform state already exists in the remote backend.
- This workflow permanently deletes infrastructure. Use with care, especially for `prod`.

---
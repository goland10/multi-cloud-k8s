## Disable GKE Deletion Protection Workflow

This GitHub Actions workflow **disables deletion protection on an existing GKE cluster** using Terraform.  
It is intended to be run **before destroying a cluster**, especially for protected environments such as `prod`.

---

## What this workflow does

### 1. Manual trigger with environment selection
The workflow is triggered manually and requires:
- `env_type`: the environment type (`dev`, `staging`, or `prod`)
- `env_number`: the environment number (for example `01`)

Together, these identify the target cluster:

<env_type>-<env_number>

yaml
Copy code

---

### 2. Secure authentication to Google Cloud
Authentication is performed using **Workload Identity Federation (WIF)**.

GitHub Actions:
- Requests an OIDC token
- Exchanges it for a short-lived Google credential
- Impersonates the configured runner service account

No service account keys are stored in GitHub.

---

### 3. Terraform backend initialization
Terraform is initialized with the same remote backend prefix used during creation:

<env_type>/<env_number>

yaml
Copy code

This guarantees Terraform loads the **correct remote state** for the target cluster.

---

### 4. Disable deletion protection
Terraform runs `terraform apply` with:

deletion_protection = false

yaml
Copy code

This updates only the GKE cluster setting and:
- Keeps all other resources unchanged
- Allows the cluster to be deleted in a subsequent destroy workflow

The change is applied automatically without interactive approval.

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

## When to use this workflow

- Before running **Terraform Destroy**, When `deletion_protection = true` is enabled on a GKE cluster
- Especially recommended for `staging` and `prod` environments

---

## Safety note

This workflow removes a protection mechanism.  
After running it, the cluster **can be permanently deleted** by Terraform. Use with caution.
## Terraform GKE Deployment via GitHub Actions

This GitHub Actions workflow provisions and manages a Google Kubernetes Engine (GKE) cluster using Terraform, authenticated through GitHub Actions → Google Cloud Workload Identity Federation (WIF).

The workflow is triggered manually and is designed to be **environment-aware**, idempotent, and safe to re-run.

**Bootstrap a complete environment with minimum settings and zero effort.**

## Who this automation is intended for?
This automation is intended to be used by developers/operators.
## How to run this automation?
- Download a sample configuration file [dev-01.tfvars](./dev-01.tfvars).
- Make your customazition.
- Save it using name format of *env_type-env_number* (e.g. dev-01.tfvars, dev-02.tfvars).
- Push it to the envs directory and run the automation from the Actions tab.
## What this automation does?

When triggered, the workflow performs the following steps:

### 1. Cluster name validation
The cluster name is constructed as:

<env_type>-<env_number>


Example:     dev-01


The workflow validates the name to ensure it:
- Uses only lowercase letters, numbers, and hyphens
- Starts with a letter
- Does not end with a hyphen
- Is between 1 and 40 characters

If validation fails, the workflow stops before any infrastructure changes occur.

---

### 2. Authentication using Workload Identity Federation
Authentication to Google Cloud is performed using **Workload Identity Federation**, without storing service account keys.

GitHub Actions:
- Requests an OIDC token
- Exchanges it for a Google access token
- Impersonates the configured GCP service account

This provides short-lived, secure credentials.

---

### 3. Terraform backend initialization
Terraform is initialized with a **remote Google Cloud Storage backend**.

Each environment has an isolated state path:



gs://<terraform-state-bucket>/<env_type>/<env_number>/


This prevents state collisions between environments.

---

### 4. Terraform plan and apply
Terraform:
- Validates the configuration
- Generates an execution plan
- Applies the plan to create or update infrastructure

Resources managed include:
- GKE cluster
- Node pools
- Networking (subnets and IP ranges)
- Node service account and IAM bindings
- Cluster settings (release channel, logging, monitoring)

---

### 5. kubectl configuration and verification
After deployment:
- Cluster credentials are fetched using `gcloud`
- `kubectl` is configured automatically
- Node connectivity is verified by listing cluster nodes

---

## Workflow inputs (manual trigger)

| Input name | Type | Example | Description |
|----------|------|---------|-------------|
| `cloud` | choice | `GCP` | Target cloud provider (currently only GCP is supported) |
| `env_type` | choice | `dev` | Environment type used for naming and state isolation |
| `env_number` | string | `01` | Environment number used to build the cluster name |

---

## Required GitHub repository variables

These variables must be configured in **GitHub → Settings → Variables**.

| Variable name | Example | Description |
|--------------|---------|-------------|
| `PROJECT_ID` | `github-terraform-k8s` | GCP project ID |
| `PROJECT_NUMBER` | `566224477722` | GCP project number (required for WIF) |
| `REGION` | `europe-west1` | Default GCP region |
| `runner_service_account` | `github-terraform-k8s` | Service account impersonated by GitHub Actions |

---

## Environment-specific Terraform variables

Each environment uses a dedicated tfvars file:



terraform/gcp/envs/<env_type>-<env_number>.tfvars


Example:


terraform/gcp/envs/dev-01.tfvars


### Commonly configured variables

| Variable | Example | Description |
|--------|--------|-------------|
| `region` | `europe-west1` | GCP region |
| `nodes_cidr` | `10.10.0.0/16` | Node IP CIDR range |
| `node_instance_type` | `e2-medium` | GKE node machine type |
| `node_disk_size_gb` | `20` | Node disk size |
| `node_min` | `1` | Autoscaler minimum |
| `node_max` | `2` | Autoscaler maximum |
| `node_count` | `1` | Initial node count |
| `location` | `europe-west1-b` | Zonal or regional control plane location |
| `node_locations` | `["europe-west1-c"]` | Worker node zones |
| `release_channel` | `RAPID` | GKE release channel |
| `deletion_protection` | `false` | Prevents accidental cluster deletion |

---

## Naming convention

All GKE clusters follow the same naming convention:



<env_type>-<env_number>


Examples:
- `dev-01`
- `staging-02`
- `prod-01`

Invalid names are rejected before Terraform execution begins.
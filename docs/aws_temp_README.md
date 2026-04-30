# AWS EKS Infrastructure — Terraform

Terraform configuration for provisioning production-grade Amazon EKS clusters on AWS, with full VPC networking, managed node groups, and support for both public and fully private cluster topologies.

---

## Architecture Overview

Each environment deploys a self-contained stack consisting of:

- **VPC** — dedicated per environment, with public/private subnet pairs across multiple AZs
- **EKS Cluster** — managed control plane with configurable Kubernetes version
- **Managed Node Group** — auto-scaling EC2 worker nodes
- **EKS Add-ons** — VPC-CNI (with Prefix Delegation), kube-proxy, CoreDNS, Metrics Server
- **VPC Endpoints** — S3, ECR (API + DKR), STS, EC2, EKS, CloudWatch Logs (enabled for private clusters)
- **NAT Gateway** — single NAT for outbound internet access (public clusters only)

### Public vs. Private Cluster

The `private_cluster` flag controls the entire topology:

| Feature | Public (`false`) | Private (`true`) |
|---|---|---|
| EKS API endpoint | Public + Private | Private only |
| NAT Gateway | Yes | No |
| Internet Gateway | Yes | No |
| VPC Endpoints | Disabled | Enabled |
| Public subnets | Created | None |

---

## Repository Structure

```
.
├── infra.tf          # All resources, variables, locals, and outputs
├── dev-01.tfvars     # Variable values for the dev-01 environment
└── prod-01.tfvars    # Variable values for the prod-01 environment
```

---

## Prerequisites

| Tool | Minimum Version |
|---|---|
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | >= 1.4.2 |
| [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) | v2 |
| [eksctl](https://eksctl.io/) | latest (for kubeconfig generation) |
| AWS credentials | configured with sufficient IAM permissions |

---

## Usage

### 1. Initialize the backend

State is stored in S3. Pass the environment-specific key at init time:

```bash
terraform init \
  -backend-config="key=dev/01/terraform.tfstate"
```

For prod:

```bash
terraform init \
  -backend-config="key=prod/01/terraform.tfstate"
```

> **S3 bucket:** `github-k8s-terraform-state` (eu-west-1)

### 2. Plan

```bash
terraform plan -var-file="dev-01.tfvars"
```

### 3. Apply

```bash
terraform apply -var-file="dev-01.tfvars"
```

For prod:

```bash
terraform apply -var-file="prod-01.tfvars"
```

### 4. Connect to the cluster

After a successful apply, Terraform outputs the exact command to configure `kubectl`:

```bash
eksctl utils write-kubeconfig --cluster dev-01 --region eu-west-1
```

### 5. Destroy

```bash
terraform destroy -var-file="dev-01.tfvars"
```

---

## Environments

### `dev-01`

| Parameter | Value |
|---|---|
| Region | eu-west-1 |
| VPC CIDR | 10.10.0.0/16 |
| Kubernetes version | 1.35 |
| Cluster visibility | Public |
| AZs (control plane) | eu-west-1a, eu-west-1b |
| AZs (workers) | eu-west-1a, eu-west-1b, eu-west-1c |
| Instance type | t3.small |
| Node count | 2 – 6 (desired: 2) |

### `prod-01`

| Parameter | Value |
|---|---|
| Region | eu-west-1 |
| VPC CIDR | 10.11.0.0/16 |
| Kubernetes version | 1.35 |
| Cluster visibility | **Private** |
| AZs (control plane) | eu-west-1a, eu-west-1b |
| AZs (workers) | eu-west-1a, eu-west-1b, eu-west-1c |
| Instance type | t3.small |
| Node count | 2 – 6 (desired: 2) |

---

## Variables Reference

### Environment Identity

| Variable | Type | Description |
|---|---|---|
| `env_type` | string | Environment type: `dev`, `staging`, or `prod` |
| `env_number` | number | Numeric environment index (e.g. `1` → `dev-01`) |
| `owner` | string | Resource owner tag for cost allocation |

### Networking

| Variable | Type | Default | Description |
|---|---|---|---|
| `region` | string | — | AWS region |
| `vpc_cidr` | string | — | Base CIDR block for the VPC |
| `azs_masters` | list(string) | — | AZs for the EKS control plane (min 2) |
| `azs_workers` | list(string) | — | AZs for worker nodes (min 1) |
| `private_cluster` | bool | `false` | Enables fully private cluster topology |

### Node Group

| Variable | Type | Default | Description |
|---|---|---|---|
| `instance_types` | list(string) | `["t3.small"]` | EC2 instance types for the node group |
| `min_size` | number | `2` | Minimum node count |
| `max_size` | number | `6` | Maximum node count |
| `desired_size` | number | `2` | Desired node count |

### Cluster

| Variable | Type | Description |
|---|---|---|
| `kubernetes_version` | string | EKS Kubernetes version (e.g. `"1.35"`) |

---

## Outputs

| Output | Description |
|---|---|
| `public_eks_endpoint` | EKS API server endpoint URL |
| `public_subnets` | CIDR blocks of public subnets (null for private clusters) |
| `private_subnets` | CIDR blocks of private subnets |
| `connection_command` | Ready-to-run `eksctl` command to configure kubeconfig |

---

## Design Decisions

**VPC-CNI with Prefix Delegation** — enabled to push pod density per node up to 110 pods, and to speed up pod IP assignment by pre-allocating CIDR prefixes per node rather than individual IPs.

**Staged add-on deployment** — CoreDNS and Metrics Server are deployed after a 60-second `time_sleep` that waits for VPC-CNI to become fully active. This prevents race conditions where DNS resolution fails during node bootstrapping.

**Environment naming convention** — cluster names are derived automatically from `env_type` and `env_number` (e.g. `dev-01`, `prod-01`), keeping naming consistent and preventing drift between the state key and the actual resource name.

**Private subnet placement for workers** — all worker nodes are placed in private subnets regardless of the `private_cluster` setting. The distinction only affects whether a public endpoint and internet egress path exist.

---

## Adding a New Environment

1. Copy an existing `.tfvars` file and adjust the values.
2. Initialize with the new state key:
   ```bash
   terraform init -backend-config="key=<env_type>/<env_number>/terraform.tfstate"
   ```
3. Apply with the new var file:
   ```bash
   terraform apply -var-file="<env>-<number>.tfvars"
   ```

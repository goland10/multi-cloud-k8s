# Multi-cloud kubernetes deployment

This project demonstrates a production-style deployment of Kubernetes on AWS/GCP, built using Github Actions, Terraform and SRE best practices.
The automation is intended to be used by dev/staging/prod teams to deploy k8s clusters with a single click.

## Prerequisits:
* [GCP prerequisits](docs/prerequisites.md#gcp)
* [AWS prerequisits](docs/prerequisites.md#aws)

## Github Actions workflows
1. Terraform K8S Deploy -- K8S cluster creation using Terrarorm [more details](./docs/k8s_create.md)
2. Terraform K8S Destroy -- K8S cluster destruction using Terrarorm [more details](./docs/k8s_destroy.md)
3. Disable deletion protection (prod) [more details](./docs/disable_deletion_protection.md)


### GKE cluster creation using Terrarorm
- Authenticate to GCP using Workload Identity Federation without storing service account keys (Security best practice).
- Use Cloud Storage to store Terraform state (remote backends for consistency)
- Create dedicated VPC and subnet with 2 secondary ranges (pods, services)
- Create dedicated SA for GKE nodes (Security best practice).
- Create GKE regional cluster with node autoscaling (HA/cost efficiency).
- Create separately managed node pool (Terraform best practice)
- Label resources for efficient management and cost savings
### GKE cluster destruction using Terrarorm
- Connect to GCS to retreive the state file and destroy the whole environment. 




## Further phases will introduce:
- GitOps
- Observability
- SLOs & incident simulations
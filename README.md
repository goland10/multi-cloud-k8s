# Multi-cloud kubernetes deployment

This project demonstrates a production-style deployment of Kubernetes on AWS/GCP, built using Github Actions, Terraform and SRE best practices.
The automation is intended to be used by dev/staging/prod teams to deploy k8s clusters with a single click.

## Prerequisits:
* [GCP prerequisits](docs/prerequisites.md#gcp)
* [AWS prerequisits](docs/prerequisites.md#aws)

## Phase 1 - Create 2 Github Actions workflows
1. GKE cluster creation using Terrarorm
2. GKE cluster destruction using Terrarorm


### GKE cluster creation using Terrarorm
- Use Cloud Storage to store Terraform state (remote backend for consistency) 
- Create dedicated VPC and subnet with 2 secondary ranges (pods, services)
- Create SA for GKE nodes
- Create GKE regional cluster with node autoscaling.
- Create separately managed node pool (best practice)
### GKE cluster destruction using Terrarorm
- Connect to GCS to retreive the state file and destroy the whole environment. 




## Further phases will introduce:
- GitOps
- Observability
- SLOs & incident simulations
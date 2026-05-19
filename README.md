# Multi-cloud kubernetes deployment

This project demonstrates a production-style deployment of Kubernetes on AWS/GCP, built using Github Actions, Terraform and security best practices.
The automation is intended to be used by dev/staging/prod teams to deploy k8s clusters with a single click.

## AWS/EKS cluster project

[AWS/EKS readme](./aws/README.md)

## GCP/GKE cluster project

### Prerequisits

[prerequisites](./gcp/docs/prerequisites.md)

### Github Actions workflows
1. Multi-cluster K8S Deploy [more details](./gcp/docs/k8s_create.md)
2. Multi-cluster K8S Destroy [more details](./gcp/docs/k8s_destroy.md)
3. Disable deletion protection (prod) [more details](./gcp/docs/disable_deletion_protection.md)

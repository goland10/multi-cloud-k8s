# GKE-Github_Actions

This project demonstrates a production-style Kubernetes platform on GCP, built using Github Actions, Terraform and SRE best practices.

## Prerequisits:

1. GCP project exists.
2. `github-terraform` service accounts exists and owns the roles:
    1. Infrastructure Administrator
    2. Service Account Admin
    3. Kubernetes Engine Admin
    ```bash
    gcloud projects add-iam-policy-binding chatgpt1-goland1 \
    --member="serviceAccount:github-terraform@chatgpt1-goland1.iam.gserviceaccount.com" \
    --role="roles/container.admin"

    ```
3. Workload Identity Pool `GitHub Actions Pool` exists and `GitHub Provider` is defined. 

```bash
gcloud iam workload-identity-pools create github-pool \
  --project=chatgpt1-goland1 \
  --location=global \
  --display-name="GitHub Actions Pool"

gcloud iam workload-identity-pools providers create-oidc github-provider   --project=chatgpt1-goland1   --location=global   \
--workload-identity-pool=github-pool   --display-name="GitHub Provider"  \
--issuer-uri="https://token.actions.githubusercontent.com/"   \
--attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
--attribute-condition="assertion.repository.startsWith('goland10/')"
```

4. Federated user has access to SA `github-terraform` with the roles:
    1. Workload Identity User
    2. Service Account Token Creator
```bash
PROJECT_NUMBER=GCP_project_number

Allow the external identity (Federated user) to impersonate the SA:
gcloud iam service-accounts add-iam-policy-binding github-terraform@chatgpt1-goland1.iam.gserviceaccount.com \
--role=roles/iam.workloadIdentityUser \
--member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/goland10/
GKE-Github_Actions"

Allow the external identity to create token (to use Cloud Storage for example)
gcloud iam service-accounts add-iam-policy-binding  github-terraform@chatgpt1-goland1.iam.gserviceaccount.com \
--role=roles/iam.serviceAccountTokenCreator \
--member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/goland10/
GKE-Github_Actions"

```

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
# GKE-Github_Actions

This project demonstrates a production-style deployment of Kubernetes on AWS/GCP, built using Github Actions, Terraform and SRE best practices.
The automation is intended to be used by dev/staging/prod teams to deploy k8s clusters with a single click.

## Prerequisits:
#  GCP 
1.  GCP project exists.
    ```bash
    PROJECT_ID=github-actions-terraform-k8s
    gcloud projects create $PROJECT_ID \              
    --name="GitHub Actions Terraform K8s"
    ```
2.  Link the project to a billing account.
    ```bash
    gcloud beta billing accounts list
    BILLING_ACCOUNT_ID=XXXXXXXXXXX
    gcloud beta billing projects link $PROJECT_ID \
    --billing-account=$BILLING_ACCOUNT_ID
    ```
3.  gcloud config set project $PROJECT_ID
4.  Required services are enabled.
    ```bash
    gcloud services enable \
    compute.googleapis.com \
    container.googleapis.com \
    iam.googleapis.com \
    iamcredentials.googleapis.com \
    cloudresourcemanager.googleapis.com \
    sts.googleapis.com \
    --project=$PROJECT_ID
    ```
5.  WIF service account exists and owns the roles:
    1. Infrastructure Administrator
    2. Kubernetes Engine Admin
    3. Service Account Admin
    ```bash
    WIF_SA_NAME=github-terraform-k8s
    WIF_SA_EMAIL=${WIF_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com

    gcloud iam service-accounts create ${WIF_SA_NAME} \
    --project=${PROJECT_ID} \
    --display-name="service account for GitHub Actions Terraform GKE"

    gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:${WIF_SA_EMAIL}  \
    --role=roles/iam.infrastructureAdmin

    gcloud projects add-iam-policy-binding $PROJECT_ID  \
    --member=serviceAccount:${WIF_SA_EMAIL}  \
    --role="roles/container.admin"

    gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:${WIF_SA_EMAIL}  \
    --role=roles/iam.serviceAccountAdmin    
    ```
6.  Create Workload Identity Pool `GitHub Actions Pool` OIDC provider `GitHub Provider`. 

    ```bash
    POOL_ID=github-pool
    PROVIDER_ID=github-provider
    REPO_PATH=goland10/multi-cloud-k8s

    gcloud iam workload-identity-pools create $POOL_ID \
      --project=$PROJECT_ID \
      --location=global \
      --display-name="GitHub Actions Pool"

    gcloud iam workload-identity-pools providers create-oidc $PROVIDER_ID   \
    --project=$PROJECT_ID \
    --location=global   \
    --workload-identity-pool=$POOL_ID   \
    --display-name="GitHub Provider"  \
    --issuer-uri="https://token.actions.githubusercontent.com/"   \
    --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
    --attribute-condition="assertion.repository == '${REPO_PATH}'" 
    ```

7.  Allow the federated (external) identity to impersonate the service account.
    Federated user has access to SA `github-terraform` with the roles:
    1. Workload Identity User
    2. Service Account Token Creator (for bucket usage)
    ```bash
    PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
    
    Allow the external identity (Federated user) to impersonate the SA:
    gcloud iam service-accounts add-iam-policy-binding $WIF_SA_EMAIL \
    --role=roles/iam.workloadIdentityUser \
    --member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL_ID/attribute.repository/${REPO_PATH}"
    
    Allow the external identity to create token (to use Cloud Storage for example)
    gcloud iam service-accounts add-iam-policy-binding  $WIF_SA_EMAIL \
    --role=roles/iam.serviceAccountTokenCreator \
    --member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL_ID/attribute.repository/${REPO_PATH}"
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
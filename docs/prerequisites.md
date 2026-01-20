# GCP
To run this automation on GCP successfully, make sure you have completed all the steps below:

1.  Create a GCP project.
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
4.  Enable the required services.
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
5.  Create a WIF service account (runner) and grant it with the roles:
    1. Infrastructure Administrator
    2. Kubernetes Engine Admin
    3. Service Account Admin
    4. resourcemanager.projectIamAdmin: The runner SA is allowed to attach roles to other SA (node SA)
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

    gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:${WIF_SA_EMAIL}  \
    --role=roles/resourcemanager.projectIamAdmin 
    ```
6.  Create Workload Identity Pool `GitHub Actions Pool` and OIDC provider `GitHub Provider`. 

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
    Federated user should has access to SA `github-terraform` with the roles:
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
8.  Create bucket to store the state files.
    ```bash
    BUCKET_NAME=github-k8s-terraform-state
    gcloud storage buckets create gs://BUCKET_NAME \
    --location=europe-west1 \
    --default-storage-class=STANDARD \
    --uniform-bucket-level-access \
    ```
# AWS
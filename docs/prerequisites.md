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

1. Set variables:
    ```bash
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    GITHUB_ORG="goland10"
    GITHUB_REPO="multi-cloud-k8s"
    ROLE_NAME="github-actions-eks-role"
    REGION="eu-west-1"
    BUCKET_NAME="github-k8s-terraform-state"    
    ```
2. Create OIDC Provider:
    ```bash
    aws iam create-open-id-connect-provider \
      --url https://token.actions.githubusercontent.com \
      --client-id-list sts.amazonaws.com 
    ```
3. Create the trust policy file
    ```bash
    cat << EOF > ./trust-policy.json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
                },
                "Action": "sts:AssumeRoleWithWebIdentity",
                "Condition": {
                    "StringEquals": {
                        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                    },
                    "StringLike": {
                        "token.actions.githubusercontent.com:sub": [
                            "repo:${GITHUB_ORG}/${GITHUB_REPO}:*"
                        ]
                    }
                }
            }
        ]
    }
    EOF
    ```     
4. Create IAM Role        
    ```bash
    aws iam create-role \
      --role-name $ROLE_NAME \
      --assume-role-policy-document file://./trust-policy.json \
      --description "GitHub Actions role for EKS Terraform deployments"
    ```
5. Create policies
    ```bash
    aws iam create-policy \
      --policy-name k8sDeploy-CloudWatchLogs \
      --description "Allows GitHub Actions to create and manage CloudWatch Log Groups for EKS" \
      --policy-document file://CloudWatchLogs.json

    aws iam create-policy \
      --policy-name k8sDeploy-EC2VPC \
      --description "Allows GitHub Actions to create and manage EC2 & VPC" \
      --policy-document file://EC2VPC.json

    aws iam create-policy \
      --policy-name k8sDeploy-EKS \           
      --description "Allows GitHub Actions to create and manage EKS clusters" \                                                      
      --policy-document file://EKS.json

    aws iam create-policy \
      --policy-name k8sDeploy-IAM \
      --description "Allows GitHub Actions to create and manage IAM" \
      --policy-document file://IAM.json

    aws iam create-policy \
      --policy-name k8sDeploy-KMS \
      --description "Allows GitHub Actions to create and manage KMS" \
      --policy-document file://KMS.json

    aws iam create-policy   \
      --policy-name k8sDeploy-S3   \
      --description "Allows GitHub Actions to create and manage state on S3" \
      --policy-document file://S3.json
    ```

5. Attach all policies to the role
    ```bash
    for POLICY in EKS EC2VPC IAM S3 KMS CloudWatchLogs; 
    do
    aws iam attach-role-policy --role-name ${ROLE_NAME} --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/k8sDeploy-${POLICY}; 
    done
    ```  
6. Set GitHub repo variables
    ```
    AWS_REGION=$REGION
    AWS_ROLE_ARN=$(aws iam get-role --role-name $ROLE_NAME --query Role.Arn --output text)
    AWS_TF_STATE_BUCKET=$BUCKET_NAME
    ```
7. Create bucket to store the state files.
    ```bash
    aws s3 mb --region $REGION s3://$BUCKET_NAME
    ```
## For AWS private setup

1. Create bucket for the tools (kubectl, helm)
   ```bash
   aws s3 mb --region $REGION s3://tools-goland10
   ```
2. Upload the tools files
    ```bash
    aws s3 cp kubectl.xz s3://tools-goland10
    ```

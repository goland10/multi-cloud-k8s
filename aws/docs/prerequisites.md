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
      --policy-name k8sDeploy-LeastPriviliges \
      --description "Merge of private and public tested policies. Created by using iamlive + Access Analyzer + manual tests." \
      --policy-document file://./LeastPriviliges.json
    ```

5. Attach k8sDeploy-LeastPriviliges policy to the role
    ```bash
    aws iam attach-role-policy --role-name ${ROLE_NAME} --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/k8sDeploy-LeastPriviliges; 
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

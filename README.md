#AWS Lambda CI/CD with Terraform - Complete File Structure

Project Directory Structure

aws-lambda-cicd/
├── .github/
│   └── workflows/
│       └── deploy.yml                 # GitHub Actions CI/CD workflow
├── terraform/
│   ├── main.tf                        # Main Terraform configuration
│   ├── variables.tf                   # Input variables
│   ├── outputs.tf                     # Output values
│   ├── providers.tf                   # Provider configurations
│   ├── iam.tf                        # IAM roles and policies
│   ├── s3.tf                         # S3 bucket for Lambda packages
│   ├── lambda.tf                     # Lambda function configuration  
│   ├── api-gateway.tf                # API Gateway (optional)
│   ├── cloudwatch.tf                 # CloudWatch logs and monitoring
│   └── terraform.tfvars              # Variable values (gitignored)
├── src/
│   ├── lambda_function.py            # Lambda function source code
│   ├── requirements.txt              # Python dependencies
│   └── tests/
│       └── test_lambda.py           # Unit tests
├── scripts/
│   └── package.sh                   # Lambda packaging script
├── .gitignore                       # Git ignore file
├── README.md                        # Project documentation
└── buildspec.yml                    # AWS CodeBuild spec (alternative)


## Architecture

The project creates:
- AWS Lambda function with Python runtime
- IAM roles and policies
- S3 bucket for deployment packages
- CloudWatch logs and monitoring
- Optional API Gateway integration

## Prerequisites

- AWS Account (Free Tier eligible)
- GitHub Account
- Terraform >= 1.0
- Python >= 3.11

## Setup Instructions

1. **Clone the repository**
```bash
   git clone <repository-url>
   cd aws-lambda-cicd

Configure AWS credentials in GitHub Secrets

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY


Customize configuration

Edit terraform/terraform.tfvars with your values
Modify src/lambda_function.py as needed


Deploy

Push to develop branch for dev environment
Push to main branch for production environment



Local Development
bash# Run tests
pytest src/tests/

# Test Terraform configuration
cd terraform
terraform init
terraform plan

## Summary of Files to Deploy

**Essential Terraform Files (9 files):**
1. `terraform/providers.tf` - Provider and backend configuration
2. `terraform/variables.tf` - Input variables
3. `terraform/main.tf` - Main configuration and local values
4. `terraform/iam.tf` - IAM roles and policies
5. `terraform/s3.tf` - S3 bucket for Lambda packages
6. `terraform/lambda.tf` - Lambda function and alias
7. `terraform/cloudwatch.tf` - CloudWatch logs and monitoring
8. `terraform/api-gateway.tf` - API Gateway integration (optional)
9. `terraform/outputs.tf` - Output values

**Supporting Files (7 files):**
10. `src/lambda_function.py` - Lambda function source code
11. `src/requirements.txt` - Python dependencies
12. `src/tests/test_lambda.py` - Unit tests
13. `.github/workflows/deploy.yml` - GitHub Actions CI/CD pipeline
14. `terraform.tfvars` - Variable values (create and add to .gitignore)
15. `.gitignore` - Git ignore configuration
16. `README.md` - Project documentation


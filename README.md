AWS Lambda CI/CD with Terraform

A complete Infrastructure as Code (IaC) solution for deploying AWS Lambda functions with automated CI/CD pipelines using Terraform and GitHub Actions. This project demonstrates best practices for serverless development, including automated testing, multi-environment deployments, and monitoring.

🏗️ Project Structure

aws-lambda-cicd/
├── scripts/
│   └── package.sh                    # Lambda deployment package script
├── terraform/
│   ├── main.tf                       # Main Terraform configuration
│   ├── variables.tf                  # Input variables definitions
│   ├── outputs.tf                    # Output values
│   ├── providers.tf                  # AWS provider and backend config
│   ├── iam.tf                        # IAM roles and policies
│   ├── s3.tf                         # S3 bucket for deployment packages
│   ├── lambda.tf                     # Lambda function configuration
│   ├── api-gateway.tf                # API Gateway integration (optional)
│   ├── cloudwatch.tf                 # CloudWatch logs and monitoring
│   └── terraform.tfvars              # Variable values (not in git)
├── src/
│   ├── lambda_function.py            # Lambda function source code
│   ├── requirements.txt              # Python dependencies
│   └── tests/
│       └── test_lambda.py            # Unit tests for Lambda function
├── .github/
│   └── workflows/
│       └── deploy.yml                # GitHub Actions CI/CD pipeline
├── builds/                           # Generated deployment packages
│   └── *.zip
├── .gitignore                        # Git ignore configuration
└── README.md                         # This documentation

🏛️ Architecture Overview

This project creates a complete serverless architecture with the following AWS resources:
Core Components

AWS Lambda Function: Python-based serverless compute with configurable runtime
IAM Roles & Policies: Least-privilege access controls for Lambda execution
S3 Bucket: Secure storage for Lambda deployment packages
CloudWatch Logs: Centralized logging with configurable retention policies

Optional Components

API Gateway: RESTful API endpoints to trigger Lambda functions
CloudWatch Monitoring: Custom metrics and alarms for function performance

Multi-Environment Support

Development Environment: Triggered by pushes to develop branch
Production Environment: Triggered by pushes to main branch
Environment Isolation: Separate resources and configurations per environment

🚀 Features

✅ Infrastructure as Code: Complete AWS infrastructure defined in Terraform
✅ Automated CI/CD: GitHub Actions pipeline with automated testing and deployment
✅ Multi-Environment: Separate dev and production environments
✅ Security Best Practices: IAM roles with minimal required permissions
✅ Monitoring Ready: CloudWatch logs and optional custom metrics
✅ Cost Optimized: Uses AWS Free Tier eligible resources
✅ Testing: Automated unit tests with pytest
✅ Versioning: Lambda function versioning and aliases

📋 Prerequisites
Before you begin, ensure you have:

AWS Account: Create free AWS account
GitHub Account: For repository hosting and CI/CD
Local Development Tools:

Terraform >= 1.0 (Install Guide)
Python >= 3.11 (Download Python)
AWS CLI (optional, for local testing)

⚡ Quick Start
1. Repository Setup
bash# Clone the repository
git clone <repository-url>
cd aws-lambda-cicd

# Create your terraform.tfvars file
cp terraform/terraform.tfvars.example terraform/terraform.tfvars

2. Configure AWS Credentials
Add the following secrets to your GitHub repository:

Go to Settings → Secrets and variables → Actions
Add these repository secrets:

AWS_ACCESS_KEY_ID: Your AWS access key
AWS_SECRET_ACCESS_KEY: Your AWS secret key

3. Customize Configuration
Edit terraform/terraform.tfvars:
hcl# Required variables
function_name          = "my-awesome-lambda"
aws_region            = "us-east-1"
environment           = "dev"

# Optional API Gateway
enable_api_gateway     = true
api_gateway_stage_name = "v1"

# Monitoring settings
log_retention_days     = 14

# Resource tagging
tags = {
  Environment = "development"
  Project     = "aws-lambda-cicd"
  ManagedBy   = "terraform"
  Owner       = "your-team"
}

4. Deploy Your Function
bash# For development deployment
git checkout develop
git add .
git commit -m "Initial deployment"
git push origin develop

# For production deployment
git checkout main
git merge develop
git push origin main
🛠️ Local Development
Setting Up Development Environment
bash# Create Python virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r src/requirements.txt
pip install pytest boto3  # Testing dependencies
Running Tests Locally
bash# Run unit tests
pytest src/tests/ -v

# Run tests with coverage
pytest src/tests/ --cov=src --cov-report=html
Testing Terraform Configuration
bashcd terraform

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment (dry run)
terraform plan

# Apply changes (if needed for testing)
terraform apply
Local Lambda Testing
bash# Test Lambda function locally
python -c "
from src.lambda_function import lambda_handler
result = lambda_handler({'test': 'data'}, None)
print(result)
"
🔄 CI/CD Pipeline
The GitHub Actions workflow automatically:

Code Quality Checks:

Validates Python syntax
Runs unit tests with pytest
Checks code formatting


Infrastructure Validation:

Validates Terraform configuration
Plans infrastructure changes
Security scans (optional)


Deployment Process:

Packages Lambda function with dependencies
Uploads deployment package to S3
Applies Terraform changes
Updates Lambda function code


Post-Deployment:

Runs integration tests
Updates function aliases
Sends deployment notifications


Pipeline Triggers

Development: Push to develop branch → Deploy to dev environment
Production: Push to main branch → Deploy to production environment
Pull Requests: Run tests and validation only

📊 Monitoring and Logging
CloudWatch Logs

Function execution logs: /aws/lambda/{function_name}
Configurable retention period (default: 14 days)
Structured logging support

Metrics and Alarms
Monitor your Lambda function with built-in metrics:

Duration: Function execution time
Error Rate: Failed invocations percentage
Throttles: Concurrent execution limits hit
Dead Letter Queue: Failed message handling

API Gateway Monitoring (if enabled)

Request/response logging
API usage metrics
Custom domain support

🔧 Configuration Options
Environment Variables
Configure your Lambda function through Terraform variables:
hcllambda_environment_variables = {
  LOG_LEVEL    = "INFO"
  STAGE        = "production"
  API_ENDPOINT = "https://api.example.com"
}
Function Settings
hcllambda_timeout     = 30          # Seconds (max 900)
lambda_memory_size = 256         # MB (128-10240)
lambda_runtime     = "python3.11"
API Gateway Configuration
hclenable_api_gateway     = true
api_gateway_stage_name = "v1"
enable_api_key        = false  # For API key authentication
🔒 Security Best Practices
This project implements several security measures:

IAM Least Privilege: Lambda execution role has minimal required permissions
Resource Isolation: Environment-specific resources and access
Secure Storage: S3 bucket with versioning and access controls
No Hard-coded Secrets: All sensitive data via environment variables
VPC Support: Optional VPC deployment for network isolation

💰 Cost Optimization
Estimated monthly costs (AWS Free Tier eligible):

Lambda: First 1M requests free, then $0.20 per 1M requests
CloudWatch Logs: First 5GB free, then $0.50 per GB
S3 Storage: First 5GB free, then $0.023 per GB
API Gateway: First 1M API calls free, then $3.50 per million

Tips for cost reduction:

Optimize Lambda memory allocation
Set appropriate log retention periods
Use reserved capacity for predictable workloads
Monitor and set up billing alerts

🚨 Troubleshooting
Common Issues
Terraform Validation Errors:
bash# Check for missing resources
terraform validate

# Common fix: ensure all required variables are defined
terraform plan
Lambda Deployment Failures:

Check IAM permissions
Verify S3 bucket access
Review CloudWatch logs for errors

API Gateway Issues:

Verify Lambda permissions for API Gateway
Check deployment stage configuration
Review integration settings

CI/CD Pipeline Failures:

Validate GitHub secrets are set correctly
Check Terraform state conflicts
Review action logs for specific errors

Getting Help

Check AWS Lambda documentation
Review Terraform AWS provider docs
Open an issue in this repository

🤝 Contributing

Fork the repository
Create a feature branch (git checkout -b feature/amazing-feature)
Make your changes and test thoroughly
Commit your changes (git commit -m 'Add amazing feature')
Push to the branch (git push origin feature/amazing-feature)
Open a Pull Request

📝 License
This project is licensed under the MIT License - see the LICENSE file for details.
🎯 Next Steps
After successful deployment, consider these enhancements:

Add custom CloudWatch dashboards
Implement blue/green deployments
Add integration tests
Set up monitoring alerts
Configure custom domains for API Gateway
Add database connections (RDS, DynamoDB)
Implement caching strategies


Ready to deploy? Start with the Quick Start section above! 🚀

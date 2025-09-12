# Terraform for AWS Lambda CI/CD Lab

## Pre-requirements
- Terraform 1.0+
- AWS CLI configured (`aws configure`)
- Create `lambda.zip` before running `terraform apply`: from repo root run `bash scripts/package.sh`
- Provide values for variables: `aws_account_id`, `github_owner`, `github_repo`. Example:
  terraform apply -var="aws_account_id=123456789012" -var="github_owner=alexvoniroks" -var="github_repo=repo-name"

## Notes
- The GitHub OIDC trust is scoped to the repo and to the `main` branch.
- The Lambda resource reads the code from `../lambda.zip`, so package your lambda before applying.
- S3 bucket lifecycle removes artifacts after 7 days.

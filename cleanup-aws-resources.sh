#!/bin/bash
# Cleanup AWS resources for lambda-cicd project

set -e

REGION="us-east-1"  # Change to your region
FUNCTION_NAME="lambda-cicd-dev-hello-world-function"
BUCKET_NAME="hello-world-function"
LOG_GROUP="/aws/lambda/lambda-cicd-dev-hello-world-function"

echo "🗑️ Starting AWS resource cleanup..."

# 1. Delete Lambda function
echo "Deleting Lambda function: $FUNCTION_NAME"
aws lambda delete-function --function-name "$FUNCTION_NAME" --region "$REGION" || echo "Lambda function not found or already deleted"

# 2. Empty and delete S3 bucket
echo "Emptying S3 bucket: $BUCKET_NAME"
aws s3 rm "s3://$BUCKET_NAME" --recursive || echo "S3 bucket not found or already empty"
echo "Deleting S3 bucket: $BUCKET_NAME"
aws s3api delete-bucket --bucket "$BUCKET_NAME" --region "$REGION" || echo "S3 bucket not found or already deleted"

# 3. Delete CloudWatch log group
echo "Deleting CloudWatch log group: $LOG_GROUP"
aws logs delete-log-group --log-group-name "$LOG_GROUP" --region "$REGION" || echo "Log group not found or already deleted"

# 4. Delete IAM role (find by pattern)
echo "Finding and deleting IAM roles..."
ROLES=$(aws iam list-roles --query "Roles[?contains(RoleName, 'lambda-cicd') || contains(RoleName, 'hello-world')].RoleName" --output text)
for role in $ROLES; do
    echo "Processing IAM role: $role"
    
    # Detach policies first
    ATTACHED_POLICIES=$(aws iam list-attached-role-policies --role-name "$role" --query "AttachedPolicies[].PolicyArn" --output text)
    for policy in $ATTACHED_POLICIES; do
        echo "Detaching policy: $policy from role: $role"
        aws iam detach-role-policy --role-name "$role" --policy-arn "$policy"
    done
    
    # Delete inline policies
    INLINE_POLICIES=$(aws iam list-role-policies --role-name "$role" --query "PolicyNames[]" --output text)
    for policy in $INLINE_POLICIES; do
        echo "Deleting inline policy: $policy from role: $role"
        aws iam delete-role-policy --role-name "$role" --policy-name "$policy"
    done
    
    # Delete role
    echo "Deleting IAM role: $role"
    aws iam delete-role --role-name "$role"
done

echo "✅ AWS resource cleanup completed!"

# Verification
echo "🔍 Verification - checking remaining resources..."
echo "Lambda functions:"
aws lambda list-functions --query "Functions[?contains(FunctionName, 'lambda-cicd') || contains(FunctionName, 'hello-world')].FunctionName" --output table || echo "No Lambda functions found"

echo "S3 buckets:"
aws s3api list-buckets --query "Buckets[?contains(Name, 'hello-world') || contains(Name, 'lambda-cicd')].Name" --output table || echo "No S3 buckets found"

echo "CloudWatch log groups:"
aws logs describe-log-groups --query "logGroups[?contains(logGroupName, 'lambda-cicd') || contains(logGroupName, 'hello-world')].logGroupName" --output table || echo "No log groups found"

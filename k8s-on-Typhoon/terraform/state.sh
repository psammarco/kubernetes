#!/bin/bash

# Generate a random pet name (simplified random string for demonstration) - using macOS compatible LC_CTYPE
RANDOM_PET_NAME="terraform-state-bucket"

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Combine random pet name and account ID to create the bucket name
BUCKET_NAME="${RANDOM_PET_NAME}-${ACCOUNT_ID}"

# Create the S3 bucket
aws s3api create-bucket --bucket "${BUCKET_NAME}" --region eu-west-2 --create-bucket-configuration LocationConstraint=eu-west-2

# Enable versioning on the bucket
aws s3api put-bucket-versioning --bucket "${BUCKET_NAME}" --versioning-configuration Status=Enabled

# Enable server-side encryption
aws s3api put-bucket-encryption --bucket "${BUCKET_NAME}" --server-side-encryption-configuration '{
  "Rules": [
    {
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }
  ]
}'

# Define the DynamoDB table name
DYNAMODB_TABLE_NAME="terraform-lock-${ACCOUNT_ID}"

# Create DynamoDB table for state locking
aws dynamodb create-table \
    --table-name "${DYNAMODB_TABLE_NAME}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST

# Output the names of the created resources
echo "S3 Bucket Name: ${BUCKET_NAME}"
echo "DynamoDB Table Name: ${DYNAMODB_TABLE_NAME}"

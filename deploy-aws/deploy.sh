#!/bin/bash
# Manual deployment script for Planka AWS

# Exit on any error
set -e

# Default environment is staging
ENVIRONMENT=${1:-staging}
STACK_NAME="planka-${ENVIRONMENT}"

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(production|staging|development)$ ]]; then
  echo "Error: Environment must be 'production', 'staging', or 'development'"
  echo "Usage: $0 [environment]"
  exit 1
fi

echo "Deploying Planka to AWS (${ENVIRONMENT} environment)"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
  echo "Error: AWS CLI is not installed"
  exit 1
fi

# Check if stack exists
if aws cloudformation describe-stacks --stack-name $STACK_NAME &> /dev/null; then
  echo "Stack exists, updating..."
  
  # Update the stack
  aws cloudformation update-stack \
    --stack-name $STACK_NAME \
    --template-body file://template.yaml \
    --parameters file://parameters-${ENVIRONMENT}.json \
    --capabilities CAPABILITY_NAMED_IAM
    
  # Wait for the update to complete
  echo "Waiting for stack update to complete..."
  aws cloudformation wait stack-update-complete --stack-name $STACK_NAME
  
else
  echo "Stack does not exist, creating..."
  
  # Create the stack
  aws cloudformation create-stack \
    --stack-name $STACK_NAME \
    --template-body file://template.yaml \
    --parameters file://parameters-${ENVIRONMENT}.json \
    --capabilities CAPABILITY_NAMED_IAM
    
  # Wait for the creation to complete
  echo "Waiting for stack creation to complete..."
  aws cloudformation wait stack-create-complete --stack-name $STACK_NAME
fi

# Get outputs from the stack
echo "Deployment completed. Stack outputs:"
aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --query "Stacks[0].Outputs" \
  --output table

echo ""
echo "Planka has been deployed to AWS ${ENVIRONMENT} environment."
echo "Visit the URL shown above to access your Planka instance."
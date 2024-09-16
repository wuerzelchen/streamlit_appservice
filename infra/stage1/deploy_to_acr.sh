#!/bin/bash

# Retrieve the acr_login_server from Terraform output
acr_login_server=$(terraform output -raw acr_login_server)

# Check if the acr_login_server was retrieved successfully
if [ -z "$acr_login_server" ]; then
  echo "Failed to retrieve acr_login_server from Terraform output."
  exit 1
fi

# Function to build the Docker image
build_image() {
    echo "Building Docker image..."
    # Add your Docker build command here
    docker build -t slentra ../../.
}

# Function to tag and push the Docker image to ACR
push_to_acr() {
    echo "Tagging Docker image..."
    # Add your Docker tag command here
    docker tag slentra $acr_login_server/slentra

    echo "Pushing Docker image to ACR..."
    # Add your Docker push command here
    docker push $acr_login_server/slentra
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -b|--build)
            build_image
            shift
            ;;
        *)
            echo "Unknown option: $key"
            exit 1
            ;;
    esac
    shift
done

# Log in to Azure Container Registry
echo "Logging in to Azure Container Registry..."
az acr login -n $acr_login_server

# Push the Docker image to ACR
push_to_acr

echo "Deployment to Azure Container Registry completed."
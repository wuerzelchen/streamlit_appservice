#!/bin/bash

# Navigate to the stage1 directory to get the outputs
cd ../stage1

# Get the outputs from stage1
acr_login_server=$(terraform output -raw acr_login_server)
resource_group_name=$(terraform output -raw resource_group_name)

# Extract the first part of the acr_login_server before the dot
container_registry_name=$(echo $acr_login_server | cut -d '.' -f 1)

# Navigate back to the stage2 directory
cd ../stage2

# Run terraform plan with the variables from stage1
terraform destroy -var "container_registry_name=${container_registry_name}" -var "resource_group_name=${resource_group_name}" -auto-approve

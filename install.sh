#!/bin/bash

# Function to prompt for yes/no input
prompt_yes_no() {
    local question=$1
    local default=$2
    local answer

    # Set default value if provided
    if [[ $default == "yes" ]]; then
        question+=" [Y/n]: "
    elif [[ $default == "no" ]]; then
        question+=" [y/N]: "
    else
        question+=" [y/n]: "
    fi

    # Prompt for input
    read -p "$question" answer

    # Set default value if input is empty
    if [[ -z $answer ]]; then
        answer=$default
    fi

    # Convert input to lowercase using 'tr'
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

    # Check if answer is valid
    if [[ $answer == "y" || $answer == "yes" ]]; then
        echo "yes"
    else
        echo "no"
    fi
}

# Function to prompt for sensitive input
prompt_sensitive() {
    local question=$1
    local answer

    # Prompt for input (hide input)
    read -sp "$question" answer
    echo "$answer"
}

# Function to replace variables in files using sed
replace_variables() {
    local file=$1
    local replacements=$2

    # Perform the replacements using sed
    for key in "${!replacements[@]}"; do
        sed -i'' -e "s|$key|${replacements[$key]}|g" "$file"
    done
}

# Function to build the git_url
build_git_url() {
    local base_url="https://github.com/aws-samples/eks-cluster-upgrades-workshop"
    local username=$1

    local git_url="${base_url/aws-samples/$username}"
    echo "$git_url"
}

# Prompt for fork creation
fork_created=$(prompt_yes_no "Have you already created your fork?" "no")

# Prompt for personal access token
token_created=$(prompt_yes_no "Have you already created your personal access token?" "no")

# Check if both answers are "yes"
if [[ $fork_created == "yes" && $token_created == "yes" ]]; then
    # Prompt for git username
    read -p "Enter your git username: " git_username
    read -p "Enter your git branch: " git_branch

    # create an if to validate the branch and set main as default if not provided by user 
    if [[ -z $git_branch ]]; then
        git_branch="main"
        echo "Branch set to main."
    fi


    # Prompt for GitHub personal access token (same as git password)
    git_password=$(prompt_sensitive "Enter your GitHub personal access token: ")

    # Prompt for AWS region
    read -p "Enter your AWS region: " aws_region

    # Build the git_url
    git_url=$(build_git_url "$git_username")

    # Output the collected inputs
    echo -e "\nFork created: $fork_created"
    echo "Token created: $token_created"
    echo "Git username: $git_username"
    echo "AWS region: $aws_region"
    echo "Git URL: $git_url"

    # Proceed with further actions
    echo "Proceeding with further actions..."
    git clone "$git_url" -b $git_branch

    read -p "Enter the tf_state path (leave blank to generate infrastructure from scratch): " tf_state_path

    if [[ -n $tf_state_path ]]; then
        # Copy tf_state file to current directory
        cp "$tf_state_path" eks-cluster-upgrades-workshop/terraform/clusters/terraform.tfstate
        echo "Terraform state file copied to current directory."
    fi
    
    cd eks-cluster-upgrades-workshop/terraform/clusters

    terraform init

    terraform plan -var="git_password=$git_password" -var="git_username=$git_username" -var="git_url=$git_url" -var="git_branch=$git_branch" -var="aws_region=$aws_region"

    # TODO: add aws_region on terraform apply command
    terraform apply -var="git_password=$git_password" -var="git_username=$git_username" -var="git_url=$git_url" -var="git_branch=$git_branch" -var="aws_region=$aws_region" --auto-approve

    sleep 5
    # TODO: add aws_region on terraform apply command 
    terraform apply -var="git_password=$git_password" -var="git_username=$git_username" -var="git_url=$git_url" -var="git_branch=$git_branch" -var="aws_region=$aws_region" --auto-approve

    aws eks --region $aws_region update-kubeconfig --name eks-upgrades-workshop

    echo "Change needed variables on template"

    # Retrieve Terraform outputs and set them as environment variables
    declare -A replacements=(
        ["ARGO_WORKFLOWS_BUCKET_ARN"]=$(terraform output -raw argo_workflows_bucket_arn)
        ["ARGO_WORKFLOWS_BUCKET_NAME"]=$(terraform output -raw argo_workflows_bucket_name)
        ["ARGO_WORKFLOWS_IRSA"]=$(terraform output -raw argo_workflows_irsa)
        ["AWS_REGION"]=$(terraform output -raw aws_region)
        ["AWS_VPC_ID"]=$(terraform output -raw aws_vpc_id)
        ["CLUSTER_ENDPOINT"]=$(terraform output -raw cluster_endpoint)
        ["CLUSTER_IAM_ROLE_NAME"]=$(terraform output -raw cluster_iam_role_name)
        ["CLUSTER_SECURITY_GROUP_ID"]=$(terraform output -raw cluster_primary_security_group_id)
        ["KARPENTER_INSTANCE_PROFILE"]=$(terraform output -raw karpenter_instance_profile)
        ["KARPENTER_IRSA"]=$(terraform output -raw karpenter_irsa)
    )

    # Define the file paths
    karpenter_file="../../gitops/add-ons/02-karpenter.yaml"
    argo_workflows_file="../../gitops/add-ons/03-argo-workflows.yaml"
    upgrades_workflow_file="../../upgrades-workflows/upgrade-validate-workflow.yaml"

    # Perform variable replacements in files
    replace_variables "$karpenter_file" "$replacements"
    replace_variables "$argo_workflows_file" "$replacements"
    replace_variables "$upgrades_workflow_file" "$replacements"

    # Applying deprecated manifests
    kubectl apply -f ../../gitops/applications/deprecated-manifests
    echo

    echo "Now proceed to flux module"
else
    echo "You need to create your fork and personal access token before proceeding."
fi

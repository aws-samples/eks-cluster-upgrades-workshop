#!/bin/bash

echo "Executing Terraform"

terraform init

terraform plan -var="git_password=$1" -var="git_username=$2" -var="git_url=$3" -var="git_branch=$4" -var="aws_region=$5"

# TODO: add aws_region on terraform apply command
terraform apply --auto-approve -var="git_password=$1" -var="git_username=$2" -var="git_url=$3" -var="git_branch=$4" -var="aws_region=$5" --auto-approve

sleep 20
# TODO: add aws_region on terraform apply command 
terraform apply --auto-approve -var="git_password=$1" -var="git_username=$2" -var="git_url=$3" -var="git_branch=$4" -var="aws_region=$5" --auto-approve

aws eks --region $5 update-kubeconfig --name eks-upgrades-workshop

echo "Change needed variables on template"

# Retrieve Terraform outputs and set them as environment variables
argo_workflows_bucket_arn=$(terraform output -raw argo_workflows_bucket_arn)
argo_workflows_bucket_name=$(terraform output -raw argo_workflows_bucket_name)
argo_workflows_irsa=$(terraform output -raw argo_workflows_irsa)
aws_region=$(terraform output -raw aws_region)
aws_vpc_id=$(terraform output -raw aws_vpc_id)
cluster_endpoint=$(terraform output -raw cluster_endpoint)
cluster_iam_role_name=$(terraform output -raw cluster_iam_role_name)
cluster_primary_security_group_id=$(terraform output -raw cluster_primary_security_group_id)
karpenter_instance_profile=$(terraform output -raw karpenter_instance_profile)
karpenter_irsa=$(terraform output -raw karpenter_irsa)

# Define the file paths
karpenter_file="../../gitops/add-ons/02-karpenter.yaml"
argo_workflows_file="../../gitops/add-ons/03-argo-workflows.yaml"
upgrades_workflow_file="../../upgrades-workflows/upgrade-validate-workflow.yaml"

deprecated_manifest_path="../../gitops/applications/deprecated-manifests"

# Perform the replacements using sed (macOS)
sed -i'' -e "s|ARGO_WORKFLOWS_BUCKET_ARN|$argo_workflows_bucket_arn|g" "$karpenter_file"
sed -i'' -e "s|ARGO_WORKFLOWS_BUCKET_NAME|$argo_workflows_bucket_name|g" "$karpenter_file"
sed -i'' -e "s|ARGO_WORKFLOWS_IRSA|$argo_workflows_irsa|g" "$karpenter_file"
sed -i'' -e "s|CLUSTER_ENDPOINT|$cluster_endpoint|g" "$karpenter_file"
sed -i'' -e "s|KARPENTER_INSTANCE_PROFILE|$karpenter_instance_profile|g" "$karpenter_file"
sed -i'' -e "s|KARPENTER_IRSA|$karpenter_irsa|g" "$karpenter_file"
sed -i'' -e "s|AWS_REGION|$aws_region|g" "$karpenter_file"

sed -i'' -e "s|ARGO_WORKFLOWS_BUCKET_ARN|$argo_workflows_bucket_arn|g" "$argo_workflows_file"
sed -i'' -e "s|ARGO_WORKFLOWS_BUCKET_NAME|$argo_workflows_bucket_name|g" "$argo_workflows_file"
sed -i'' -e "s|ARGO_WORKFLOWS_IRSA|$argo_workflows_irsa|g" "$argo_workflows_file"
sed -i'' -e "s|CLUSTER_ENDPOINT|$cluster_endpoint|g" "$argo_workflows_file"
sed -i'' -e "s|KARPENTER_INSTANCE_PROFILE|$karpenter_instance_profile|g" "$argo_workflows_file"
sed -i'' -e "s|KARPENTER_IRSA|$karpenter_irsa|g" "$argo_workflows_file"
sed -i'' -e "s|AWS_REGION|$aws_region|g" "$argo_workflows_file"

sed -i'' -e "s|AWS_VPC_ID|$aws_vpc_id|g" "$upgrades_workflow_file"
sed -i'' -e "s|REGION_AWS|$aws_region|g" "$upgrades_workflow_file"
sed -i'' -e "s|AWS_CLUSTER_IAM_ROLE_NAME|$cluster_iam_role_name|g" "$upgrades_workflow_file"
sed -i'' -e "s|CLUSTER_SECURITY_GROUP_ID|$cluster_primary_security_group_id|g" "$upgrades_workflow_file"

# Applying deprecated manifests
kubectl apply -f $deprecated_manifest_path

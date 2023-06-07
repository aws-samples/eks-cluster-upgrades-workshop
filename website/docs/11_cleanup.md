---
id: cleanup
sidebar_label: 'Cleanup'
sidebar_position: 11
---

# Cleanup


Congratulations on completing the EKS Upgrades Workshop! To avoid incurring unnecessary costs and to keep your AWS environment, it is important to clean up the resources created during the workshop.

## Terraform destroy

```bash
cd /home/ec2-user/environment/eks-cluster-upgrades-workshop/terraform/clusters

terraform state rm 'module.flux_v2'

terraform destroy -var="git_password=$GITHUB_TOKEN" -var="git_username=$GITHUB_USER" -var="git_url=https://github.com/$GITHUB_USER/eks-cluster-upgrades-workshop.git" -var="git_branch=$GIT_BRANCH" -var="aws_region=$AWS_REGION" -var="cluster_version=1.25" --auto-approve
```

## Remove Cloudformation Stacks (Only if executing this workshop outside of an AWS event)

To do this, you can run the following Bash command with a for loop that lists the AWS CloudFormation stacks, selects the stacks with the names karpenter-eks-upgrade-demo, aws-cloud9-eks-upgrades-workshop, and eks-workshop, and then deletes them in that order:

```bash
for stack in $(aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --query "StackSummaries[?contains(StackName, 'Karpenter-eks-upgrade-demo') || contains(StackName, 'aws-cloud9-eks-upgrades-workshop') || contains(StackName, 'cloudformation')].StackName" --output text); do
  if [ $stack == "aws-cloud9-eks-upgrades-workshop"* ]; then
    aws cloudformation delete-stack --stack-name $stack
  fi
  if [ $stack == "eks-upgrades-workshop" ]; then
    aws cloudformation delete-stack --stack-name $stack
  fi
  if [ $stack == "cloudformation" ]; then
    aws cloudformation delete-stack --stack-name $stack
  fi
done
```

This command will delete the AWS resources created during the workshop in the order specified to ensure a clean removal. Be sure to have the AWS CLI installed and configured with your AWS credentials for the command to work.


Also, remember to delete any extra resource you may have added to the account during the workshop!

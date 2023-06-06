---
id: cleanup
sidebar_label: 'Cleanup'
sidebar_position: 11
---

# Cleanup


Congratulations on completing the EKS Upgrades Workshop! To avoid incurring unnecessary costs and to keep your AWS environment tidy, it is important to clean up the resources created during the workshop.

## Uninstall Fluxv2

```bash
flux uninstall
```

## Delete PDBs

We are going to delete all pod Disruption Budgets, to make sure that our cluster will not be stuck in deleting state.

```bash
kubectl delete poddisruptionbudget.policy/nginx-pdb -ndefault
kubectl delete poddisruptionbudget.policy/karpenter -nkarpenter

kubectl get poddisruptionbudget -A
```

## Remove the EKS cluster created for the workshop.

```bash
eksctl delete cluster -f /home/ec2-user/environment/eks-cluster-upgrades-workshop/helpers/cluster.yaml
```

## Remove Cloudformation Stacks

To do this, you can run the following Bash command with a for loop that lists the AWS CloudFormation stacks, selects the stacks with the names karpenter-eks-upgrade-demo, aws-cloud9-eks-upgrades-workshop, and eks-workshop, and then deletes them in that order:

```bash
for stack in $(aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --query "StackSummaries[?contains(StackName, 'Karpenter-eks-upgrade-demo') || contains(StackName, 'aws-cloud9-eks-upgrades-workshop') || contains(StackName, 'cloudformation')].StackName" --output text); do
  if [ $stack == "Karpenter-eks-upgrade-demo" ]; then
    aws cloudformation delete-stack --stack-name $stack
  fi
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

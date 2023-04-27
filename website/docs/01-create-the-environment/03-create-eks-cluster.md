---
id: create-cluster
sidebar_label: 'Create your EKS cluster'
sidebar_position: 3
---

# Create your EKS Cluster

After cloning the repo, we will need to change `cluster-template.yaml` file to update personal variables.

```bash
envsubst < /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/helpers/cluster-template.yaml > /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/helpers/cluster.yaml
```

And then create your cluster:

```bash
eksctl create cluster -f /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/helpers/cluster.yaml
```

> This can take few minutes

## Export your Cluster Endpoint.

```bash
export CLUSTER_ENDPOINT="$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.endpoint" --output text)"
echo "export CLUSTER_ENDPOINT=${CLUSTER_ENDPOINT}" >> /home/ec2-user/.bashrc
```

---
id: managed-nodes-upgrade
sidebar_label: 'Performing managed node groups upgrade'
sidebar_position: 1
---

# EKS Managed Node Groups upgrade

After upgrading the EKS Control Plane, we need to upgrade the data plane nodes in the cluster. This can be done using the `eksctl`, `console` or by using an automated tool such as `AWS CloudFormation` or `Terraform`.

In this module we will be focusing on how to upgrade the `managed node groups` in out EKS cluster.

:::info
A node’s kubelet can’t be newer than kube-apiserver (For people managing your own AMIs)

**Upgrading the data plane after the control plane** ensures that the worker nodes are compatible with the updated control plane components and that the network and storage configurations are updated to work with the new versions.
:::

## Verifying the managed node groups environment

For this workshop you are utilizing EKS managed nodegroups in AWS, the update process **can be handled by AWS**, but it is your responsibility to **initiate it**.

Let's get only the nodes from managed node groups, remember we are using managed node groups only for add-ons, not for the applications.

```bash
kubectl get nodes -l alpha.eksctl.io/nodegroup-name=managed-node-add-ons
```

You should see the following output:

```
NAME                              STATUS   ROLES    AGE   VERSION
ip-192-168-120-160.ec2.internal   Ready    <none>   20h   v1.23.xx-eks-a59e1f0
ip-192-168-84-169.ec2.internal    Ready    <none>   20h   v1.23.xx-eks-a59e1f0
```

As you can see the version in `v1.23`, we need to trigger the upgrade.

## Starting the upgrade

Let's start the upgrade using `eksctl`:

```bash
eksctl upgrade nodegroup \
  --name=managed-node-add-ons \
  --cluster=eks-upgrade-demo \
  --region=$AWS_REGION \
  --kubernetes-version=$K8S_TARGET_VERSION
```

:::note
Hey, might be a good time for a break!
:::

When you initiate a managed node group update, Amazon EKS automatically updates your nodes for you, completing the steps listed in [Managed node update behavior](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-update-behavior.html).

:::tip
You should check the link above later!
:::

You can monitor the update by open a **new terminal in Cloud9**, and execute the following command:

```bash
kubectl get nodes -l alpha.eksctl.io/nodegroup-name=managed-node-add-ons -w
```

:::note
You will see that EKS will launch new nodes with the newest version, and then `cordon` and `drain` the old nodes.
:::

After it finishes, you should see the following message:

```bash
2023-04-25 15:56:58 [ℹ]  nodegroup successfully upgraded
```

Verifying the new nodes:

```bash
kubectl get nodes -l alpha.eksctl.io/nodegroup-name=managed-node-add-ons
```

You should see the output similar to the following

```
NAME                             STATUS   ROLES    AGE   VERSION
ip-192-168-75-116.ec2.internal   Ready    <none>   11m   v1.24.xx-eks-a59e1f0
ip-192-168-98-1.ec2.internal     Ready    <none>   11m   v1.24.xx-eks-a59e1f0
```

## Conclusion

In conclusion, upgrading the EKS Managed Node Groups is an essential step to ensure compatibility between the worker nodes and updated control plane components. You have always upgrade your data plane after the control plane this guarantees that network and storage configurations are updated to work with the new versions. We can use tools like `eksctl`, `AWS console`, `AWS CloudFormation`, or `Terraform` to upgrade the Managed Node Groups. With proper upgrading of the Managed Node Groups, we can ensure our EKS cluster is running smoothly and efficiently.

:::info
There are other objects that can also prevent pod eviction, like PDBs.
:::
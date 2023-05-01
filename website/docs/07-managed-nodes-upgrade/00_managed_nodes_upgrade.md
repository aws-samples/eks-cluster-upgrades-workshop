---
id: managed-nodes-upgrade2
sidebar_label: 'Introduction'
sidebar_position: 0
---

# EKS Managed Node Groups upgrade

After upgrading the EKS Control Plane, we need to upgrade the data plane nodes in the cluster. This can be done using the `eksctl`, `console` or by using an automated tool such as `AWS CloudFormation` or `Terraform`.

In this module we will be focusing on how to upgrade the `managed node groups` in out EKS cluster.

**Upgrading the data plane after the control plane** ensures that the worker nodes are compatible with the updated control plane components and that the network and storage configurations are updated to work with the new versions.

:::info
A node’s kubelet can’t be newer than kube-apiserver (For people managing your own AMIs)
:::

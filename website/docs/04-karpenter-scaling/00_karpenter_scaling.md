---
id: karpenter-scaling0
sidebar_label: 'Introduction'
sidebar_position: 0
---

# How Karpenter can help during the upgrades process?

Karpenter is a Kubernetes node scaling that has the goal of automatically launches just the right compute resources to handle your cluster's applications. Many people position Karpenter just as a way to save money making Spot instance usage easier, but Karpenter can also help customer in reduce their operational overhead. Karpenter by default will use Amazon EKS optimized AMIs, whenever Karpenter launches a new node, it will match the Control Plane version of that node. It means that after an upgrade process you don't need to upgrade all your Nodes at once, you can let Karpenter little by little replace nodes with old kubelet version, to new ones that matches EKS Control Plane version.
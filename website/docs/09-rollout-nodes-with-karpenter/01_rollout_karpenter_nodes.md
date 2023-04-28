---
id: rollout-nodes
sidebar_label: 'Introduction'
sidebar_position: 1
---

# Rollout nodes with Karpenter

Karpenter by default will use Amazon EKS optimized AMIs, whenever Karpenter launches a new node, it will match the Control Plane version of that node. It means that after an upgrade process you don't need to upgrade all your Nodes at once, you can let Karpenter little by little replace nodes with old kubelet version, to new ones that matches EKS Control Plane version.

In this module we are gonna forcefully rollout karpenter nodes, without changing any configuration in karpenter provisioner.





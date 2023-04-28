---
id: Conclusion
sidebar_label: 'Conclusion'
sidebar_position: 10
---


In this workshop, we have explored the use of Karpenter for managing node provisioning in Amazon EKS clusters. We have seen how Karpenter uses Amazon EKS optimized AMIs and matches the Control Plane version of the nodes it launches.

During the node rollout process, it is crucial to protect pods from unexpected disruptions. This is where Pod Disruption Budgets (PDBs) come in handy. A PDB specifies the minimum number of pods that must be available during a disruption. However, an aggressive PDB setting can lead to PodEvictionFailure, which can directly impact the upgrade process. Too many unavailable pods can make it challenging for Kubernetes to schedule new pods and result in prolonged downtime. Therefore, it is essential to strike the right balance between pod protection and successful node rollouts.
# EKS Cluster Upgrades Workshop

:bangbang: THIS WORKSHOP IS PERFORMING UPGRADES FROM VERSION `1.23`

> All the best practices still apply for older and newer Kubernetes versions, this workshop will be updated based on Amazon EKS release launch

The goal of this workshop is to present to customer a reference architecture that can make the Amazon EKS Cluster upgrade process less painful and smoothly by using a `GitOps` strategy with Fluxv2 for components reconciliation and `Karpenter` for Node Scaling. Using a GitOps mono repository approach for deploying both add-ons and applications makes it easier during upgrade process since we have just once place to look at api deprecated/removed versions and guarantee add-on backwards compatibility.

![EKS Architecture](../../static/img/eks-upgrades-architecture.png)





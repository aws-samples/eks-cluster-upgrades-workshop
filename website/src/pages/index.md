# EKS Cluster Upgrades Workshop

:::tip
THIS WORKSHOP IS PERFORMING UPGRADES FROM VERSION `1.23`
:::

:::note
This workshop covers best practices that are applicable for both older and newer versions of Kubernetes. We are committed to keeping our content up-to-date with the latest Amazon EKS releases, Let's get started!
:::

## Introduction

The Amazon cluster upgrades workshop is built to provide you with a reference architecture that can help make your Amazon EKS Cluster upgrades less painful and more seamless. To achieve this, we will be using a GitOps strategy with Fluxv2 for components reconciliation and Karpenter for Node Scaling.

### Why this architecture?

One of the key benefits of using GitOps is that it enables us to use a mono repository approach for deploying both add-ons and applications. This approach makes the upgrade process much smoother because we have a single location to look at for deprecated API versions and ensure that add-ons are backwards compatible.

![EKS Architecture](../../static/img/eks-upgrades-architecture.png)

By the end of this workshop, you will have a solid understanding of how to use GitOps with Fluxv2 and Karpenter to simplify the EKS Cluster upgrade process. We hope that this will help you to streamline your workflow and ensure that your infrastructure is always up-to-date and functioning smoothly. So, let's dive in and get started!





---
id: intro
sidebar_label: 'Introduction'
sidebar_position: 0
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

# Introduction

One of the key considerations for people who have chosen Amazon Elastic Kubernetes Service (EKS) as their container management platform is to plan for cluster upgrades. The Kubernetes project is constantly updating with new features, design updates, and bug fixes, and new minor versions are released on average every three months and are supported for about twelve months after their release.

## Kubernetes project release process

The Kubernetes project usually launches new minor versions on average every three months, and every version is supported for about twelve months after their release.


![Kubernetes version release](../static/img/kubernetes-release-diagram.png)

:::warning
Before adopting Kubernetes, be sure that you will have the commitment to stay up to date with the new platform versions.
:::

## Amazon EKS release process

Amazon EKS is typically some weeks behind the latest Kubernetes version, this is because before a new version of Kubernetes is made available on EKS, **it is thoroughly tested to ensure stability and compatibility with other AWS services and tools.**

<!-- ![Kubernetes version release](../static/img/EKS-Upgrades-EKS-Release.png) -->


### EKS and Kubernetes support duration:

<Tabs>
  <TabItem value="eks" label="Amazon EKS" default>
    <b>14+ months</b> (EKS Support duration can be extended based on the amount of breaking changes introduced in a certain version )
  </TabItem>
  <TabItem value="kubernetes" label="Kubernetes">
    <b>12 months</b>
  </TabItem>
</Tabs>


:::note
Amazon EKS is committed to supporting at least four production-ready versions of Kubernetes. Whereas the Kubernetes project only supports the latest 3 versions.
:::

## Workshop architecture

The base architecture composed by `Amazon EKS Cluster`, `EKS Managed Add-ons`, and `Flux` is deployed with Terraform.

`Flux` enables us to use a `mono repository` approach for deploying both `Self-Managed Add-Ons` and `Apps`. 
This approach makes the upgrade process much smoother because we have a single location to look at for deprecated API versions and ensure that add-ons are backwards compatible.

![EKS Architecture](../static/img/eks-upgrades-architecture.png)

During the next steps of this workshop, you learn how to setup those components and gain a solid understanding of how to use `GitOps with Fluxv2`, `Karpenter`, and `Argo Workflows` to simplify the EKS Cluster upgrade process. We hope that this will help you streamline your workflow and ensure that your infrastructure is always up-to-date and functioning smoothly. So, let's dive in and get started!


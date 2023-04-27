---
id: managed-addons-upgrade
sidebar_label: 'Upgrade Managed Add-ons'
sidebar_position: 1
---

# Upgrade Managed Add-ons

Kubernetes add-ons are additional components that enhance the functionality of a Kubernetes cluster. They can include services such as network plugins, load balancers, and monitoring solutions. Just like any other piece of software that is deployed in Kubernetes, add-ons need to be updated in order to maintain stability, security and compatibility. The Kubernetes project and the various add-ons that are used with it are continually evolving, with new features being added and bugs being fixed. It is important to keep the add-ons up-to-date in order to take advantage of these improvements and to avoid potential problems with compatibility or security. Just as with any other software, it is important to stay current with add-ons updates in order to ensure the best possible experience when using a Kubernetes cluster.

Using managed add-ons in Amazon EKS can simplify the upgrade process. However, `Amazon EKS does not automatically update add-ons` when new versions are released or after you update your cluster to a new Kubernetes minor version. The add-ons can be upgraded through the `AWS Management Console`, `AWS CLI` or IaC tools like `Terraform`, `CloudFormation`, `CDK`, and `eksctl`, making the upgrade process more efficient and automated.


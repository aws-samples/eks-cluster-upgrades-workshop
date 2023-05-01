# EKS Cluster Upgrades ImmersionDay Module

![Tests](https://github.com/aws-samples/eks-cluster-upgrades-workshop/actions/workflows/production.yaml/badge.svg?branch=main)

:bangbang: THIS WORKSHOP IS PERFORMING UPGRADES FROM VERSION `1.23` :bangbang:

This workshop covers best practices that are applicable for both older and newer versions of Kubernetes. We are committed to keeping our content up-to-date with the latest Amazon EKS releases, Let's get started!

## Introduction

The Amazon cluster upgrades workshop is built to provide you with a reference architecture that can help make your Amazon EKS Cluster upgrades less painful and more seamless. To achieve this, we will be using a GitOps strategy with Fluxv2 for components reconciliation and Karpenter for Node Scaling.

### Why this architecture?

One of the key benefits of using GitOps is that it enables us to use a mono repository approach for deploying both add-ons and applications. This approach makes the upgrade process much smoother because we have a single location to look at for deprecated API versions and ensure that add-ons are backwards compatible.

![EKS Architecture](docs/static/eks-upgrades-architecture.png)

By the end of this workshop, you will have a solid understanding of how to use GitOps with Fluxv2 and Karpenter to simplify the EKS Cluster upgrade process. We hope that this will help you to streamline your workflow and ensure that your infrastructure is always up-to-date and functioning smoothly. So, let's dive in and get started!


## Navigating the repository

The top level repository can be split is to several areas.

### Site content

The workshop content itself is a `docusaurus` site. All workshop content is written using Markdown and can be found in `website`.

### Learner environment

To spin -up your learn environment, go to [`website`](./website/README.md#local-development) page and follow the instructions to run your docussaurus website.

<!-- In this section you can find all the necessary files for the workshop module reference. Feel free to explore and use these files as a reference for your other modules.

- [Creating the environment](./modules/)
- [Exploring the environment](./modules/01_gitops_files.md)
- [How GitOps reconciliation works](./modules/02_flux_sync.md)
- [How Karpenter matches Control Plane API Version](./modules/03_karpenter_scaling.md)
- [Validating current state, apps/add-ons](./modules/04_validating_state.md)
  - [Checking for Deprecated APIs in applications](./modules/04_validating_state.md#checking-for-deprecated-apis-in-applications)
  - [Checking for deprecated APIs within Helm charts](./modules/04_validating_state.md#checking-for-deprecated-apis-within-helm-charts)
  - [Check if any installed EKS managed add-ons needs to be upgraded for the target version](./modules/04_validating_state.md#check-if-any-installed-eks-managed-add-ons-needs-to-be-upgraded-for-the-target-version)
  - [Converting manifests](./modules/04_validating_state.md#converting-manifests-with-kubectl-convert)
- [Upgrade EKS Control Plane](./modules/05_eks_upgrade.md)
- [Upgrade Managed NodeGroups](./modules/06_managed_nodes_upgrade.md)
- [Upgrade Managed Add-ons](./modules/07_upgrade_managed_addons.md)
- [Rollout nodes with Karpenter](./modules/08_rollout_karpenter_nodes.md)
  - [PDB in action](./modules/08_rollout_karpenter_nodes.md#pdb-in-action)
- TBD [Wrap-up upgrade]() -->


## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This project is licensed under the Apache-2.0 License.





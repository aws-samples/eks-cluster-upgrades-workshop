# EKS Cluster Upgrades ImmersionDay Module

:bangbang: THIS WORKSHOP IS PERFORMING UPGRADES FROM VERSION `1.23` :bangbang:

> All the best practices still apply for older and newer Kubernetes versions, this workshop will be updated based on Amazon EKS release launch

<p align="center">
<img src="./docs/static/eks-upgrades-architecture.png">
</p>

# Description

The goal of this workshop is to present to customer a reference architecture that can make the Amazon EKS Cluster upgrade process less painful and smoothly by using a GitOps strategy with Fluxv2 for components reconciliation and Karpenter for Node Scaling. Using a GitOps mono repository approach for deploying both add-ons and applications makes it easier during upgrade process since we have just once place to look at api deprecated/removed versions and guarantee add-on backwards compatibility.

# Modules

In this section you can find all the necessary files for the workshop module reference. Feel free to explore and use these files as a reference for your other modules.

> Check the `modules` folder with docs for each module for the workshop.

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
- TBD [Wrap-up upgrade]()

---
# Collaboration Guide

Follow these steps to collaborate on this repository:

1. **Clone the repository to your local machine:**

```bash
git clone https://github.com/lusoal/eks-cluster-upgrades-reference-arch.git
```

2. **Create a new branch with a descriptive name, where new-feature-branch is the name of your new branch:**

```bash
git checkout -b new-feature-branch
```

3. **Commit the changes with a descriptive message:**

```bash
git commit -m "Add a description of your changes"
```

4. **Open a pull request**

- Go to the repository on GitHub.

- Click on the "Pull Requests" tab.

- Click on the "New Pull Request" button.

- Choose your new-feature-branch as the "compare" branch and the main branch (usually main or master) as the "base" branch.

- Add a descriptive title and a detailed description of your changes in the provided fields.

- Click on "Create Pull Request" to submit your changes for review.

Once your pull request has been reviewed and approved by the repository maintainer, they will merge your changes into the main branch. If they request any changes, you can make additional commits to your branch and push them; they will automatically be added to the existing pull request.

Remember to keep your fork and local repository up-to-date with the upstream repository by periodically fetching and merging changes.

**Happy collaborating!**





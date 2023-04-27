---
id: validating-state3
sidebar_label: 'Check managed add-on upgrade'
sidebar_position: 3
---

# Check if any installed EKS managed add-ons needs to be upgraded for the target version.

Using managed add-ons in Amazon EKS can simplify the upgrade process. However, Amazon EKS does not automatically update add-ons when new versions are released or after you update your cluster to a new Kubernetes minor version.

So in oder to verify if we need to upgrade or not before moving to the target version, let's execute the following command.

```bash
/home/ec2-user/environment/eks-cluster-upgrades-reference-arch/helpers/add-on-validate.sh --validate-support-target-version
```

Output should look like this.

```output
2023-04-24 19:53:53 [ℹ]  Kubernetes version "1.23" in use by cluster "eks-upgrade-demo"
2023-04-24 19:53:53 [ℹ]  getting all addons
2023-04-24 19:53:55 [ℹ]  to see issues for an addon run `eksctl get addon --name <addon-name> --cluster <cluster-name>`
Validating if add-ons are supported in the target version
=========================== RESULTS ===========================
Add-on upgrade not needed, all add-ons are supported in the target version
```
As you can see, there is no upgraded needed now, all add-ons are supported in the target version.

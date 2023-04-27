---
id: managed-addons-upgrade2
sidebar_label: 'Validating add-ons'
sidebar_position: 2
---

# Validating add-ons

Before starting the upgrade, let's set two environment variables, `$K8S_CURRENT_VERSION` and `$K8S_TARGET_VERSION`.

```bash
export K8S_CURRENT_VERSION=1.24 && echo "export K8S_CURRENT_VERSION=$K8S_CURRENT_VERSION" >> /home/ec2-user/.bashrc
export K8S_TARGET_VERSION=1.25 && echo "export K8S_CURRENT_VERSION=$K8S_TARGET_VERSION" >> /home/ec2-user/.bashrc
```

Let's verify if we need to upgrade our managed add-ons, we are using `core-dns`, `kube-proxy` and `vpc-cni`, run the follow command to verify if needs to be upgraded.

```bash
eksctl get addons -f /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/helpers/cluster.yaml
```

> You will be able to see in the output under `UPDATE AVAILABLE`


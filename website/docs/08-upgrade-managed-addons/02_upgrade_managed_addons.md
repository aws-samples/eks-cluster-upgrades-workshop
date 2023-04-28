---
id: managed-addons-upgrade2
sidebar_label: 'Validating add-ons'
sidebar_position: 2
---

## Validating add-ons

Let's verify if we need to upgrade our managed add-ons, we are using `core-dns`, `kube-proxy` and `vpc-cni`, run the follow command to verify if needs to be upgraded.

```bash
eksctl get addons -f /home/ec2-user/environment/eks-cluster-upgrades-workshop/helpers/cluster.yaml
```
:::note
You will be able to see in the output under `UPDATE AVAILABLE`
:::


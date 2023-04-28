---
id: managed-addons-upgrade3
sidebar_label: 'Perfoming add-on upgrade'
sidebar_position: 3
---

# Starting the upgrade

```bash
eksctl update addon -f /home/ec2-user/environment/eks-cluster-upgrades-workshop/helpers/cluster.yaml
```

The output should be similar to this:

```bash
023-04-25 16:30:19 [!]  SSM is now enabled by default; `ssh.enableSSM` is deprecated and will be removed in a future release
2023-04-25 16:30:19 [ℹ]  Kubernetes version "1.24" in use by cluster "eks-upgrade-demo"
2023-04-25 16:30:20 [ℹ]  creating role using provided policies ARNs
2023-04-25 16:30:20 [ℹ]  updating policies
2023-04-25 16:30:20 [ℹ]  waiting for CloudFormation changeset "updating-policy-7e5ddb83-b143-4b26-b383-943259c89fe1" for stack "eksctl-eks-upgrade-demo-addon-vpc-cni"
2023-04-25 16:30:20 [ℹ]  nothing to update
2023-04-25 16:30:20 [ℹ]  updating addon
2023-04-25 16:30:31 [ℹ]  addon "vpc-cni" active
2023-04-25 16:30:32 [ℹ]  new version provided v1.9.3-eksbuild.2
2023-04-25 16:30:32 [ℹ]  updating addon
2023-04-25 16:31:30 [ℹ]  addon "coredns" active
2023-04-25 16:31:30 [ℹ]  new version provided v1.24.10-eksbuild.2
2023-04-25 16:31:30 [ℹ]  updating addon
2023-04-25 16:32:10 [ℹ]  addon "kube-proxy" active
```

Once its done, we can run the `get addons` command again to validate:

```bash
eksctl get addons -f /home/ec2-user/environment/eks-cluster-upgrades-workshop/helpers/cluster.yaml
```

> You will be able to see empty fields under `UPDATE AVAILABLE`

## Conclusion

In conclusion, customers should consider using EKS Managed Add-ons as they provide a seamless and integrated experience for managing common Kubernetes workloads. Furthermore, upgrading EKS Managed Add-ons can be made easier with the use of eksctl, which provides a streamlined and automated approach to upgrading the add-ons. With eksctl, customers can easily upgrade their add-ons with minimal manual intervention, reducing the risk of downtime and configuration errors.


---
id: eks-upgrade2
sidebar_label: 'Performing EKS control plane upgrade'
sidebar_position: 2
---

# Updating the cluster.yaml File

In order to properly apply the EKS upgrade change we will use `eksctl` that was used to deploy the cluster.

To update the EKS version in the `cluster.yaml` file located in the helpers folder, follow these steps:

```bash
echo "Upgrading from version $K8S_CURRENT_VERSION to $K8S_TARGET_VERSION"
sed "s/$K8S_CURRENT_VERSION/$K8S_TARGET_VERSION/g"  /home/ec2-user/environment/eks-cluster-upgrades-workshop/helpers/cluster.yaml
```

Output should be similar to this

```yaml
metadata:
  name: eks-upgrade-demo
  region: $AWS_REGION
  version: "1.24"
```

Now let's apply the sed command

```bash
sed -i "s/$K8S_CURRENT_VERSION/$K8S_TARGET_VERSION/g"  /home/ec2-user/environment/eks-cluster-upgrades-workshop/helpers/cluster.yaml
```

The cluster.yaml file should now reflect the EKS target version version and you can apply it.

# Apply eksclt

Now that the eksctl configurations are ready to be applied we can move forward and apply the change.

```bash
eksctl upgrade cluster -f /home/ec2-user/environment/eks-cluster-upgrades-workshop/helpers/cluster.yaml
```

This will plan your upgrade with `eksctl`, validating configurations, you should see a similar output:

```bash
2023-04-24 20:09:34 [!]  SSM is now enabled by default; `ssh.enableSSM` is deprecated and will be removed in a future release
2023-04-24 20:09:34 [!]  NOTE: cluster VPC (subnets, routing & NAT Gateway) configuration changes are not yet implemented
2023-04-24 20:09:35 [ℹ]  (plan) would upgrade cluster "eks-upgrade-demo" control plane from current version "1.23" to "1.24"
2023-04-24 20:09:35 [ℹ]  re-building cluster stack "eksctl-eks-upgrade-demo-cluster"
2023-04-24 20:09:35 [✔]  all resources in cluster stack "eksctl-eks-upgrade-demo-cluster" are up-to-date
2023-04-24 20:09:36 [ℹ]  checking security group configuration for all nodegroups
2023-04-24 20:09:36 [ℹ]  all nodegroups have up-to-date cloudformation templates
2023-04-24 20:09:36 [!]  no changes were applied, run again with '--approve' to apply the changes
```

Now to confirm the upgrade, let's add `--approve` flag into the command:

```bash
eksctl upgrade cluster -f /home/ec2-user/environment/eks-cluster-upgrades-workshop/helpers/cluster.yaml --approve
```

You should see an output similar to this:

```bash
2023-04-24 20:12:17 [ℹ]  will upgrade cluster "eks-upgrade-demo" control plane from current version "1.23" to "1.24"
```

After the changes were applied, the control plane will already be running on v1.24 and you should see:

```bash
2023-04-24 20:21:21 [✔]  cluster "eks-upgrade-demo" control plane has been upgraded to version "1.24"
2023-04-24 20:21:21 [ℹ]  you will need to follow the upgrade procedure for all of nodegroups and add-ons
```

Also confirm it via the cluster API.

```bash
kubectl version | grep -i server
```

Output should be similar to this:

```yaml
Server Version: version.Info{Major:"1", Minor:"24+", GitVersion:"v1.24.12-eks-ec5523e", GitCommit:"3939bb9475d7f05c8b7b058eadbe679e6c9b5e2e", GitTreeState:"clean", BuildDate:"2023-03-20T21:30:46Z", GoVersion:"go1.19.7", Compiler:"gc", Platform:"linux/amd64"}
```

## Conclusion

:::note
See is that simple!
:::

In conclusion, the EKS upgrade process focuses primarily on updating the control plane while ensuring **minimal disruption to your workloads**. Automated tests are run to confirm the compatibility of your applications with the upgraded control plane. However, it is important to note that the worker nodes will still be running on the older Kubernetes version after the control plane upgrade. To fully complete the upgrade process, you'll need to update your worker nodes separately, following the recommended upgrade procedures to maintain consistency and stability across your entire cluster.




---
id: eks-upgrade
sidebar_label: 'How AWS Manages EKS Upgrades'
sidebar_position: 1
---

# EKS Upgrade

In this guide, we'll go through the process of upgrading your Amazon Elastic Kubernetes Service (EKS) cluster, which is essential for maintaining optimal performance, security, and availability.

We also will cover the importance of updates, how AWS manages EKS upgrades, and what happens when an upgrade fails. Finally, we will provide instructions on how to update the eksctl.yaml file in the helpers folder and apply the changes using the eksctl command.


# How AWS Manages EKS Upgrades

The EKS upgrade process is managed by AWS to ensure a seamless and safe transition between Kubernetes versions. Here is a detailed breakdown of the steps AWS takes to upgrade the EKS control plane:

![BLUE GREEN](../../static/img/eks-blue-green-upgrades.png)


1. **Pre-upgrade checks**: AWS first performs pre-upgrade checks, including assessing the current cluster state and evaluating the compatibility of the new version with your workloads. If any issues are detected, the upgrade process will not proceed.

2. **Backup and snapshot**: Before initiating the upgrade, AWS takes a backup of your existing control plane and creates a snapshot of your etcd data store. This is done to ensure data consistency and to enable rollback in case of an upgrade failure.

> For additional data protection, consider using [Velero](https://velero.io/), an open-source tool that simplifies the backup and recovery process for Kubernetes cluster resources and persistent volumes. Velero allows you to schedule and manage backups, as well as restore processes, providing an extra layer of safety for your data.

3. **Creating a new control plane**: AWS creates a new control plane with the desired Kubernetes version. This new control plane runs in parallel with your existing control plane, ensuring minimal disruption to your workloads.

4. **Testing compatibility**: The new control plane is tested for compatibility with your workloads, including running automated tests to verify that your applications continue to function as expected.

> The goal is to minimize potential disruptions during the upgrade process and maintain the stability of your services. It's important to mention that this only looks for your application health and not for API's that may be removed or deprecated

5. **Switching control plane endpoints**: Once compatibility is confirmed, AWS switches the control plane endpoints (API server) to the new control plane. This switch happens atomically, resulting in minimal downtime during the upgrade process.

6. **Terminating the old control plane**: The old control plane is terminated once the upgrade is complete, and all resources associated with it are cleaned up.

## EKS Rollback on Upgrade Failure

![BLUE GREEN](../../static/img/eks-rollback.png)

In case an EKS upgrade fails, AWS has measures in place to minimize disruption and revert the control plane to its previous version:

1. **Detecting the failure:** AWS constantly monitors the upgrade process to detect any issues. If a problem arises during the upgrade, the process is immediately halted.

2. **Restoring from backup:** AWS uses the backup and snapshot created before the upgrade to restore the control plane and etcd data store to their previous state.

3. **Switching control plane endpoints:** AWS atomically switches the control plane endpoints back to the previous control plane, ensuring minimal downtime.

4. **Terminating the new control plane:** Once the rollback is complete, AWS terminates the new control plane and cleans up any associated resources.

5. **Post-rollback assessment:** After the rollback, AWS will assess the reasons behind the upgrade failure and provide guidance on how to address the issues. You will need to troubleshoot and resolve the problems before attempting the upgrade again.


# Updating the cluster.yaml File

In order to properly apply the EKS upgrade change we will use `eksctl` that was used to deploy the cluster.

To update the EKS version in the `cluster.yaml` file located in the helpers folder, follow these steps:

```bash
echo "Upgrading from version $K8S_CURRENT_VERSION to $K8S_TARGET_VERSION"
sed "s/$K8S_CURRENT_VERSION/$K8S_TARGET_VERSION/g"  /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/helpers/cluster.yaml
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
sed -i "s/$K8S_CURRENT_VERSION/$K8S_TARGET_VERSION/g"  /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/helpers/cluster.yaml
```

The cluster.yaml file should now reflect the EKS target version version and you can apply it.

# Apply eksclt

Now that the eksctl configurations are ready to be applied we can move forward and apply the change.

```bash
eksctl upgrade cluster -f /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/helpers/cluster.yaml
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
eksctl upgrade cluster -f /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/helpers/cluster.yaml --approve
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

In conclusion, the EKS upgrade process focuses primarily on updating the control plane while ensuring **minimal disruption to your workloads**. Automated tests are run to confirm the compatibility of your applications with the upgraded control plane. However, it is important to note that the worker nodes will still be running on the older Kubernetes version after the control plane upgrade. To fully complete the upgrade process, you'll need to update your worker nodes separately, following the recommended upgrade procedures to maintain consistency and stability across your entire cluster.




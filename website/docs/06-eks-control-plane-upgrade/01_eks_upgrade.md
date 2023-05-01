---
id: eks-upgrade
sidebar_label: 'Introduction'
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




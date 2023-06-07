---
id: env
sidebar_label: 'Environment'
sidebar_position: 1
---

# Selecting your environment

This workshop can run in two different ways:

- `AWS Event`: All the resources are already deployed as part of the event, including the `Amazon EKS Cluster` along with all networking resources and permissions, you can proceed to [**Accessing Cloud9 IDE**](./02-accessing-ide.md).
- `Self`: You will need to deploy the Cloudformation template in order to deploy the environment.

## Creating the environment, self event

:::caution
Only proceed with this step if executing it by your own
:::

In order to start the environment, you will need to deploy the following Cloudformation template. This can be done, either via console or terminal:

[EKS Upgrades Workshop CF](https://raw.githubusercontent.com/aws-samples/eks-cluster-upgrades-workshop/feat/workshop_v2/helpers/cloudformation-new-stack.yaml)

Give the name, `eks-upgrades-workshop` to you stack

The above Cloudformation script will provision a `Cloud9` with all the required tools in order to execute the workshop along with `AWS VPC`, `Amazon EKS Cluster`, `IAM roles and permissions`, `Install Flux V2`.

:::tip
Wait at least `20 minutes` before moving on, this will give time to Cloudformation and SSM finishes its deploy. Might be a good time for a break.

Only proceed after the SSM Run Command has finished. [Check here!](https://console.aws.amazon.com/systems-manager/run-command/executing-commands)
:::
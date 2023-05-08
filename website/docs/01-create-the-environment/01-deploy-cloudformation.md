---
id: deploy-cloudformation
sidebar_label: 'At your own AWS account'
sidebar_position: 3
---

# Creating the environment

In order to properly start the environment you will need to deploy the following Cloudformation template, this can be done, either via console or terminal:

[EKS Upgrades Workshop CF](../../static/scripts/cloudformation.yaml)

Give the name, `eks-upgrades-workshop` to you stack

The above Cloudformation script will provision a `Cloud9` instance to use during the workshop, with all the required tools in order to execute the workshop.

:::tip
Wai at least `20 minutes` before move on, this will give time to Cloudformation and SSM finishes its deploy. Might be a good time for a break.
:::

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
After Cloudformation finishes, wait at **least 10 more minutes** so the SSM script can execute in the Cloud9 instance installing all the needed resources.
:::

---
id: deploy-cloudformation
sidebar_label: 'Deploy Cloudformation'
sidebar_position: 1
---

# Creating the environment

In order to properly start the environment you will need to deploy the following Cloudformation template, this can be done, either via console or terminal:

[EKS Upgrades Workshop CF](../../static/scripts/cloudformation.yaml)

The above Cloudformation script will provision a `Cloud9` instance to use during the workshop, with all the required tools in order to execute the workshop.

:bangbang: After the Cloudformation finished, wait at **least 10 more minutes** so the SSM script can execute in the Cloud9 instance installing all the needed components.

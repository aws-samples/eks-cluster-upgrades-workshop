---
id: why-gitops
sidebar_label: 'GitOps'
sidebar_position: 1
---

# Why GitOps?

One of the main customer challenges regarding EKS Cluster Upgrades is make sure that your applications and add-ons don’t break compatibility with the newer EKS version. To help on this goal we are going to use a GitOps strategy. GitOps works based on a SCM repository, where it becomes the only source of truth, and our GitOps controller, in this case FluxV2 will just mirror what we have declared into the repository.

### How a mono repo structure can benefit during EKS cluster upgrades?

As mentioned earlier, one of the main challenges that customers face during cluster upgrades is compatibility, we need to validate our application’s manifests, making sure that we are not using anything removed from the API Server. So, using a mono repo strategy can help us on doing those validations easier. We can use tools such as kube-no-trouble and pluto to seek for those deprecated/removed apiVersions into a single place along with kubectl convertplugin that can help us on changing those apiVersions in an automated way. Also this repo structure help us on identifying our self-managed add-ons versions since all the add-ons that we are using are in a single place.
---
id: validating-state
sidebar_label: 'Validating State'
sidebar_position: 5
---

# Validating State

Checking for deprecated APIs and updating your manifests to use the latest API versions before upgrading your Kubernetes cluster is crucial for preventing compatibility issues, avoiding downtime, maintaining a secure and stable environment, easing maintenance, staying informed about Kubernetes changes, and ensuring compliance with best practices. Using tools like Pluto, kube no trouble and kubectl convert streamlines the process of identifying and updating deprecated APIs, making it easier to maintain a healthy Kubernetes environment.

## Argo workflows validate pipeline

For this workshop we have automated all the validation steps in an `argo-workflows` pipeline, so let's run our workflow to verify what are the things that we need to change.

```bash
cd /home/ec2-user/environment/eks-cluster-upgrades-workshop/upgrades-workflows && kubectl apply -f upgrade-validate-workflow.yaml
```

Getting Argo workflows UI url:

```bash
echo $(kubectl get svc -nargo-workflows | awk '{print $4}' | grep -vi external):2746/workflows/undefined?limit=50
```

Open URL in your favourite browser, you are going to be able to the workflow applied earlier in running state.

![GitOps toolkit](../static/img/argo-workflows-00.png)

Now click in the workflow and you are gonna be able to see all the validation stetps that this workflow is executing:

![GitOps toolkit](../static/img/argo-workflows-01.png)

The workflow will validate the following things:

- **AWS Basics** (Verify that you AWS account have all the resources needed to perfom cluster upgrade).
- **Validate deprecated APIs** (Using kubent we will looking for deprecate or removed APIs that we still using and we need to replace before upgrading).
- **Validate Self Managed Add-ons** (Using Pluto it will looking for deprecated APIs in Helm charts, since we have all the self-managed add-ons deployed using charts).
- **Validate Managed Add-ons** (Validate if we need to upgrade your AWS EKS managed add-ons).
- **Get Kubernetes/EKS documentation** (It will generate for you the links that you should look at before moving on with the clyster upgrade).


---
id: validating-state4
sidebar_label: 'Kubectl convert'
sidebar_position: 4
---

# Converting Manifests with kubectl convert and updating file

After identifying the deprecated APIs, you can use kubectl convert to update your manifests. This command converts a manifest file to a specified Kubernetes version using the corresponding API version.

For each deprecated API, run the following command:

1. Converting Cronjob:

```bash
kubectl convert -f /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications/02-cronjob.yaml > /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications/02-cronjob.bak && mv /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications/02-cronjob.bak /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications/02-cronjob.yaml
```

2. Converting HPA:

```bash
kubectl convert -f /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications/01-hpa-sample-app.yaml > /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications/01-hpa-sample-app.bak && mv /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications/01-hpa-sample-app.bak /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications/01-hpa-sample-app.yaml
```

1. Validate the `02-cronjob.yaml` file, you will see that the `apiVersion` changed from `batch/v1beta1` to `batch/v1`

```bash
cat /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications/02-cronjob.yaml
```

```yaml output
apiVersion: batch/v1
kind: CronJob
metadata:
  creationTimestamp: null
  name: hello
spec:
```

4. Validate the `01-hpa-sample-app.yaml` file, you will see that the `apiVersion` changed from `autoscaling/v2beta1` to `autoscaling/v1`

```bash
cat /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications/01-hpa-sample-app.yaml
```
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
  namespace: default
spec:
```

## Validate with Pluto your changes

After all the changes were made you can rerun Pluto to validate nothing is missing.

```bash
pluto detect-files -d /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications
```

This time you should have output without needed changes:

```output
There were no resources found with known deprecated apiVersions.


Want more? Automate Pluto for free with Fairwinds Insights!
 🚀 https://fairwinds.com/insights-signup/pluto 🚀 
```

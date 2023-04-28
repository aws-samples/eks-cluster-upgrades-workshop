---
id: validating-state2
sidebar_label: 'Checking for Deprecated APIs with Pluto'
sidebar_position: 2
---

# Checking for Deprecated APIs in applications

Pluto is a versatile tool designed to help identify deprecated Kubernetes API versions in your deployment. Beyond scanning manifest files, Pluto offers additional capabilities, including validating Helm charts and inspecting cluster APIs directly. Here are some examples:

Addressing these deprecations is generally straightforward, but locating all instances where a deprecated version is used can be challenging.

Directly querying the API server may seem like a solution, but it can be misleading. To accurately identify deprecated API versions in your deployment, you can use Pluto. This tool helps detect deprecated versions in various locations and streamlines the process of ensuring compatibility during upgrades.

First, let's uncomment the lines of our `kustomization.yaml`, in the `applications` directory to make sure Pluto will run it's validation throught them.

```bash
sed -i "6s/^#//g" /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications/kustomization.yaml
```

Now we can run Pluto in the `applications` directory.

```bash
pluto detect-files -d /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications
```

The output will display any deprecated APIs found in your manifests, the API removal version, and the replacement API version.

```output
NAME       KIND                     VERSION               REPLACEMENT     REMOVED   DEPRECATED   REPL AVAIL
hello      CronJob                  batch/v1beta1         batch/v1         false     true         true
nginx-hpa  HorizontalPodAutoscaler  autoscaling/v2beta1   autoscaling/v2   false     true         false

```

## Checking for deprecated APIs within Helm charts

For this demonstration all the **self-managed add-ons are installed using Helm (karpenter and metric-server)**. Pluto can also check for deprecated APIs within Helm charts before deploying them to your cluster. This ensures that your Helm-based installations, such as Metrics Server and Karpenter, are using up-to-date API versions. To check a Helm chart for deprecated APIs, run:

```bash
pluto detect-helm -o wide
```

> **Note:** If you are using a Helm chart to deploy your application, consider using pluto to validate that chart as well.

The output will display any deprecated apiVersion within the charts.

```output
There were no resources found with known deprecated apiVersions.
```

>**Note:** In this case there is nothing to update on the charts related to **apiVersion depreciation or removal**, but you should check each individual add-on to see if there is any new release.

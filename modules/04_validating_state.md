# Validating and Updating Deprecated APIs Before Upgrading

Checking for deprecated APIs and updating your manifests to use the latest API versions before upgrading your Kubernetes cluster is crucial for preventing compatibility issues, avoiding downtime, maintaining a secure and stable environment, easing maintenance, staying informed about Kubernetes changes, and ensuring compliance with best practices. Using tools like Pluto and kubectl convert streamlines the process of identifying and updating deprecated APIs, making it easier to maintain a healthy Kubernetes environment.

In this guide, we'll use Pluto and kubectl convert to identify and update deprecated APIs before upgrading.


## Checking for Deprecated APIs in applications

Pluto is a versatile tool designed to help identify deprecated Kubernetes API versions in your deployment. Beyond scanning manifest files, Pluto offers additional capabilities, including validating Helm charts and inspecting cluster APIs directly. Here are some examples:

Addressing these deprecations is generally straightforward, but locating all instances where a deprecated version is used can be challenging.

Directly querying the API server may seem like a solution, but it can be misleading. To accurately identify deprecated API versions in your deployment, you can use Pluto. This tool helps detect deprecated versions in various locations and streamlines the process of ensuring compatibility during upgrades.

First, let's uncomment the lines of our `kustomization.yaml`, in the `applications` directory to make sure Pluto will run it's validation throught them.

```bash
sed -i "6s/^#//g" /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/applications/kustomization.yaml
```

Now we can run Pluto in the `applications` directory.

```bash
pluto detect-files -d /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/applications
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

## Check if any installed EKS managed add-ons needs to be upgraded for the target version.

Using managed add-ons in Amazon EKS can simplify the upgrade process. However, Amazon EKS does not automatically update add-ons when new versions are released or after you update your cluster to a new Kubernetes minor version.

So in oder to verify if we need to upgrade or not before moving to the target version, let's execute the following command.

```bash
/home/ec2-user/environment/eks-cluster-upgrades-reference-arch/helpers/add-on-validate.sh --validate-support-target-version
```

Output should look like this.

```output
2023-04-24 19:53:53 [ℹ]  Kubernetes version "1.23" in use by cluster "eks-upgrade-demo"
2023-04-24 19:53:53 [ℹ]  getting all addons
2023-04-24 19:53:55 [ℹ]  to see issues for an addon run `eksctl get addon --name <addon-name> --cluster <cluster-name>`
Validating if add-ons are supported in the target version
=========================== RESULTS ===========================
Add-on upgrade not needed, all add-ons are supported in the target version
```
As you can see, there is no upgraded needed now, all add-ons are supported in the target version.

# Converting Manifests with kubectl convert and updating file

After identifying the deprecated APIs, you can use kubectl convert to update your manifests. This command converts a manifest file to a specified Kubernetes version using the corresponding API version.

For each deprecated API, run the following command:

1. Converting Cronjob:

```bash
kubectl convert -f /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/applications/02-cronjob.yaml > /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/applications/02-cronjob.bak && mv /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/applications/02-cronjob.bak /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/applications/02-cronjob.yaml
```

2. Converting HPA:

```bash
kubectl convert -f /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/applications/01-hpa-sample-app.yaml > /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/applications/01-hpa-sample-app.bak && mv /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/applications/01-hpa-sample-app.bak /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/applications/01-hpa-sample-app.yaml
```

1. Validate the `02-cronjob.yaml` file, you will see that the `apiVersion` changed from `batch/v1beta1` to `batch/v1`

```bash
cat /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/applications/02-cronjob.yaml
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
cat /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/applications/01-hpa-sample-app.yaml`
```
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
  namespace: default
spec:
```

# Validate with Pluto your changes

After all the changes were made you can rerun Pluto to validate nothing is missing.

```bash
pluto detect-files -d /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/applications
```

This time you should have output without needed changes:

```output
There were no resources found with known deprecated apiVersions.


Want more? Automate Pluto for free with Fairwinds Insights!
 🚀 https://fairwinds.com/insights-signup/pluto 🚀 
```

## Applying changes

Before apply the changes let's verify which `apiVersion` Flux has in its inventory

```bash
kubectl -n flux-system describe kustomization/apps | grep -i inventory -A7
```

Output should be similar to this:

```yaml output
Inventory:
  Entries:
    Id:                   default_nginx_apps_Deployment
    V:                    v1
    Id:                   default_hello_batch_CronJob
    V:                    v1beta1
    Id:                   default_nginx-hpa_autoscaling_HorizontalPodAutoscaler
    V:                    v2beta1
```
As you can see we are still using deprecated `apiVersions` for `HPA` and `Cronjob`

Now that you've validated the updated manifests, add-ons, helm charts and applications commit the changes to your repository:

```bash
git add .
git commit -m "Updated deprecated APIs"
git push origin main
```

Finally, let's verify Flux inventory again, it can take few minutes to update:

```bash
kubectl -n flux-system describe kustomization/apps | grep -i inventory -A7
```

Output should look like this, as you can see the `apiVersions` have changed

```yaml output
Inventory:
  Entries:
    Id:                   default_nginx_apps_Deployment
    V:                    v1
    Id:                   default_hello_batch_CronJob
    V:                    v1
    Id:                   default_nginx-hpa_autoscaling_HorizontalPodAutoscaler
    V:                    v2
```

## Conclusion

By validating the state of your Kubernetes resources before an upgrade and use Pluto and kubectl convert to update deprecated APIs, you can avoid compatibility issues and ensure a successful upgrade. Regularly checking for deprecated APIs and keeping your manifests up to date will help maintain a healthy and stable Kubernetes environment.

## GitOps Reconciliation flow

In this step-by-step guide, we will walk through the process of GitOps reconciliation using Flux in a Kubernetes cluster. We'll modify the `gitops/applications/01-sample-app.yaml` file from your forked repository and observe Flux detecting and applying the changes.

## Flux Reconciliation

Flux reconciliation is the process by which Flux continuously monitors a Git repository for changes to Kubernetes manifests and automatically applies them to a connected cluster. When a change is detected in the repository, Flux compares the updated manifest with the current state of the cluster. If there's a discrepancy, Flux updates the cluster to match the desired state defined in the Git repository. This GitOps-based approach ensures consistency, version control, and automation in managing Kubernetes deployments, streamlining CI/CD pipelines, and reducing human error.

<p align="center">
<img src="../docs/static/gitops-toolkit.png">
</p>

## Requirements

- Have Flux up and running in your cluster
- Have Flux connected to the GitHub repository containing the application manifests

## Flux changes

Let's create a HPA manifest, responsible for application scaling for our sample-app.

```bash
cat <<'EOF' >> /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications/01-hpa-sample-app.yaml
---
apiVersion: autoscaling/v2beta1
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  minReplicas: 3
  maxReplicas: 10
EOF
```

Adding this new manifest in the resource list of the `kustomization.yaml` will enable Flux to watch this manifest. 

Run the command below to uncoment the line `5` of the `kustomization.yaml` file, respective to the `01-hpa-sample-app.yaml` that we just created. 

```bash
sed -i "5s/^#//g" /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications/kustomization.yaml
```

Your Kustomization manifest should look like this:

```bash
cat /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications/kustomization.yaml 
```
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - 01-sample-app.yaml
  - 01-hpa-sample-app.yaml
  - 02-cronjob.yaml
```

Now Flux will watch the newly HPA created file.

Pull latest changes in the repository, made by Flux.

```bash
cd /home/ec2-user/environment/eks-cluster-upgrades-workshop/
git pull origin main
```

Now, commit the changes we've made and push them to the repository:

```bash
git add .
git commit -m "Added HPA manifest"
git push origin main
```

Flux will now detect the changes and start the reconciliation process. It does this by periodically polling the GitHub repository for changes. You can monitor the Flux logs to observe the reconciliation process:

```bash
kubectl -n flux-system get pod -o name | grep -i source | while read POD; do kubectl -n flux-system logs -f $POD --since=1m; done
```

You should see logs indicating that the new changes have been detected and applied to the cluster:

```json
{"level":"info","ts":"2023-04-24T19:39:57.439Z","msg":"stored artifact for commit 'Added HPA manifest'","controller":"gitrepository","controllerGroup":"source.toolkit.Fluxcd.io","controllerKind":"GitRepository","GitRepository":{"name":"flux-system","namespace":"flux-system"},"namespace":"flux-system","name":"flux-system","reconcileID":"0d5eee90-54df-4941-a786-3d090ccccfd2"}
```

Verify that the updated manifest has been applied to the cluster using kubectl:

```bash
kubectl -n default get hpa/nginx-hpa 
```

1. The output should display the newly created HPA manifest.

```output
NAME        REFERENCE          TARGETS         MINPODS   MAXPODS   REPLICAS
nginx-hpa   Deployment/nginx   <unknown>/80%   1         10        3       
```

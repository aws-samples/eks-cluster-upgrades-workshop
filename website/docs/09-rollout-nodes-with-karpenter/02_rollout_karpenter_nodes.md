---
id: rollout-nodes2
sidebar_label: 'PDB in action'
sidebar_position: 2
---

# PDB in action

First, we are gonna to create a [PDB (Pod Disruption Budget)](https://kubernetes.io/docs/tasks/run-application/configure-pdb/), disruption budgets are used for protect pods from unexpected disruptions. During the rollout of your Nodes when you upgrade your cluster, if you have a too `Agressive` `PDB` it can leds to `PodEvictionFailure` and directly impact the upgrade process, so let's simulate it.

Creating a `PDB` for our sample app:

```bash
cat <<'EOF' >> /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/applications/01-pdb-sample-app.yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: nginx-pdb
  namespace: default
spec:
  minAvailable: 3
  selector:
    matchLabels:
      app: nginx
EOF
```

> The above PDB is consider too AGRESSIVE, because we have 3 replicas running, and we are saying that we want 3 as minimum available.

Adding this new manifest into `kustomization.yaml` file, so flux will know that needs to watch this manifest, open `/home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/applications/kustomization.yaml` and add the file name to it below `02-cronjob.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - 01-sample-app.yaml
  - 01-hpa-sample-app.yaml
  - 02-cronjob.yaml
  - 01-pdb-sample-app.yaml
```

> Now flux will watch the newly PDB created file.

Commit and push the changes to the repository:

```bash
cd /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/
git add .
git commit -m "Added PDB manifest"
git push origin main
```

Flux will now detect the changes and start the reconciliation process. It does this by periodically polling the GitHub repository for changes. You can monitor the Flux logs to observe the reconciliation process:

```bash
kubectl get po -nflux-system | grep -i source | awk '{print $1}' | while read line; do kubectl -n flux-system logs -f $line --since=1m; done
```

You should see logs indicating that the new changes have been detected and applied to the cluster:

```json
{"level":"info","ts":"2023-04-25T17:18:27.895Z","msg":"stored artifact for commit 'Added PDB manifest'","controller":"gitrepository","controllerGroup":"source.toolkit.fluxcd.io","controllerKind":"GitRepository","GitRepository":{"name":"flux-system","namespace":"flux-system"},"namespace":"flux-system","name":"flux-system","reconcileID":"fea3c381-7412-452d-9008-f99ae19f06b9"}
```

Verify if PDB was created:

```bash
kubectl get pdb/nginx-pdb -ndefault
```

The output should look like this:

```
NAME        MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
nginx-pdb   3               N/A               0                     105s
```





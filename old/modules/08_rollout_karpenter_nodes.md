# Rollout nodes with Karpenter

Karpenter by default will use Amazon EKS optimized AMIs, whenever Karpenter launches a new node, it will match the Control Plane version of that node. It means that after an upgrade process you don't need to upgrade all your Nodes at once, you can let Karpenter little by little replace nodes with old kubelet version, to new ones that matches EKS Control Plane version.

In this module we are gonna forcefully rollout karpenter nodes, without changing any configuration in karpenter provisioner.

## PDB in action

First, we are gonna to create a [PDB (Pod Disruption Budget)](https://kubernetes.io/docs/tasks/run-application/configure-pdb/), disruption budgets are used for protect pods from unexpected disruptions. During the rollout of your Nodes when you upgrade your cluster, if you have a too `Agressive` `PDB` it can leds to `PodEvictionFailure` and directly impact the upgrade process, so let's simulate it.

Creating a `PDB` for our sample app:

```bash
cat <<'EOF' >> /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications/01-pdb-sample-app.yaml
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

Add this new line to the `kustomization.yaml` manifest file, so Flux will know that needs to watch it.

```bash
echo -e '  - 01-pdb-sample-app.yaml' >> /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications/kustomization.yaml
```
Your `kustomization.yaml` should look like this.


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
  - 01-pdb-sample-app.yaml
```

> Now Flux will watch the newly PDB created file.

Commit and push the changes to the repository:

```bash
cd /home/ec2-user/environment/eks-cluster-upgrades-workshop/
git add .
git commit -m "Added PDB manifest"
git push origin main
```

Flux will now detect the changes and start the reconciliation process. It does this by periodically polling the GitHub repository for changes. You can monitor the Flux logs to observe the reconciliation process:

```bash
kubectl -n flux-system get pod -o name | grep -i source | while read POD; do kubectl -n flux-system logs -f $POD --since=1m; done
```

You should see logs indicating that the new changes have been detected and applied to the cluster:

```json
{"level":"info","ts":"2023-04-25T17:18:27.895Z","msg":"stored artifact for commit 'Added PDB manifest'","controller":"gitrepository","controllerGroup":"source.toolkit.fluxcd.io","controllerKind":"GitRepository","GitRepository":{"name":"flux-system","namespace":"flux-system"},"namespace":"flux-system","name":"flux-system","reconcileID":"fea3c381-7412-452d-9008-f99ae19f06b9"}
```

Verify if PDB was created:

```bash
kubectl -n default get pdb/nginx-pdb
```

The output should look like this:

```
NAME        MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
nginx-pdb   3               N/A               0                     105s
```

## Rollout Nodes with agressive PDB configured

Now let's see what happens if we start the rollout of Karpenter nodes that are handling all the 3 replicas of the nginx pod.

Getting the Node name that we will perform the drain:

```bash
kubectl get nodes -l node-type=applications
```

Output should look like this:

```
NAME                          STATUS   ROLES    AGE   VERSION
ip-192-168-6-9.ec2.internal   Ready    <none>   21h   v1.23.xx-eks-a59e1f0
```

Validate if all of our applications pods are running in the same Node

```bash
kubectl -n default get pods -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName
```

Output should look like this:

```
NAME                     STATUS    NODE
nginx-6b855ddcb7-6zsc6   Running   ip-192-168-6-9.ec2.internal
nginx-6b855ddcb7-d6xpr   Running   ip-192-168-6-9.ec2.internal
nginx-6b855ddcb7-pmtrt   Running   ip-192-168-6-9.ec2.internal
```

As you can see, all the 3 nginx replicas are running in the same node, let's start by using `kubectl cordon` to mark your old nodes as `unschedulable`:

```bash
kubectl cordon $(kubectl get nodes -l node-type=applications -oname)

kubectl get nodes -l node-type=applications
```

You should see an output similar to this:

```
NAME                          STATUS                     ROLES    AGE   VERSION
ip-192-168-6-9.ec2.internal   Ready,SchedulingDisabled   <none>   21h   v1.23.xx-eks-a59e1f0
```

`STATUS` will be SchedulingDisabled, because `kubectl cordon` command have applied a taint into this node to make sure new pods are not schedule in it.

Let's drain our Node, using `kubectl drain` to safely evict all of your pods from your old nodes to the new ones.

```bash
kubectl drain $(kubectl get nodes -l node-type=applications -oname) --ignore-daemonsets
```

The output should be similar to this.

```bash
node/ip-192-168-6-9.ec2.internal already cordoned
Warning: ignoring DaemonSet-managed Pods: kube-system/aws-node-m8xvz, kube-system/kube-proxy-m48gt
evicting pod default/nginx-6b855ddcb7-6zsc6
evicting pod default/nginx-6b855ddcb7-pmtrt
evicting pod default/nginx-6b855ddcb7-d6xpr
error when evicting pods/"nginx-6b855ddcb7-6zsc6" -n "default" (will retry after 5s): Cannot evict pod as it would violate the pod's disruption budget.
error when evicting pods/"nginx-6b855ddcb7-pmtrt" -n "default" (will retry after 5s): Cannot evict pod as it would violate the pod's disruption budget.
error when evicting pods/"nginx-6b855ddcb7-d6xpr" -n "default" (will retry after 5s): Cannot evict pod as it would violate the pod's disruption budget.
```

As you can see in the above log we got an error when evicting pods due to too agressive PDB, let's fix it:

## Adjusting PDB

```bash
cat <<'EOF' > /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications/01-pdb-sample-app.yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: nginx-pdb
  namespace: default
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: nginx
EOF
```

> We have changed the `minAvailable` from `3` to `1`, this will give us space to drain.

Commit and push the changes to the repository:

```bash
cd /home/ec2-user/environment/eks-cluster-upgrades-workshop/
git add .
git commit -m "Changed PDB manifest from 3 to 1"
git push origin main
```

Wait few seconds, and validate that Flux has applied the new PDB:

```bash
kubectl -n default get pdb/nginx-pdb
```

Now, open a new terminal and check the Nodes:

```bash
kubectl get nodes -l node-type=applications
```

You should see the following output:

```
NAME                            STATUS                     ROLES    AGE   VERSION
ip-192-168-6-9.ec2.internal     Ready,SchedulingDisabled   <none>   22h   v1.23.xx-eks-a59e1f0
ip-192-168-82-14.ec2.internal   Ready                      <none>   53s   v1.24.xx-eks-a59e1f0
```

As you can see, we have two nodes managed by Karpenter, one that is being drained with version `1.23` and a new one with version `1.24`, Karpenter notice those pods that were evicted before and create a new node to handle those pods, let's verify again:

```bash
kubectl get nodes -l node-type=applications
kubectl -n default get pods -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName
```

You should now be able to see only a single Node managed by Karpenter, and all pods running in this new Node.

## Conclusion

In this workshop, we have explored the use of Karpenter for managing node provisioning in Amazon EKS clusters. We have seen how Karpenter uses Amazon EKS optimized AMIs and matches the Control Plane version of the nodes it launches.

During the node rollout process, it is crucial to protect pods from unexpected disruptions. This is where Pod Disruption Budgets (PDBs) come in handy. A PDB specifies the minimum number of pods that must be available during a disruption. However, an aggressive PDB setting can lead to PodEvictionFailure, which can directly impact the upgrade process. Too many unavailable pods can make it challenging for Kubernetes to schedule new pods and result in prolonged downtime. Therefore, it is essential to strike the right balance between pod protection and successful node rollouts.





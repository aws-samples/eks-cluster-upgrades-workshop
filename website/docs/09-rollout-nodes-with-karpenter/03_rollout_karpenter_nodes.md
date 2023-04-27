---
id: rollout-nodes3
sidebar_label: 'Rollout nodes agressive PDB'
sidebar_position: 3
---

# Rollout Nodes with agressive PDB configured

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

Validate if all of our applications pods are running in the same Node"

```bash
kubectl get pods -o=custom-columns=NAME:.metadata.name,NODE:.spec.nodeName
```

Output should look like this:

```
NAME                     NODE
nginx-6b855ddcb7-6zsc6   ip-192-168-6-9.ec2.internal
nginx-6b855ddcb7-d6xpr   ip-192-168-6-9.ec2.internal
nginx-6b855ddcb7-pmtrt   ip-192-168-6-9.ec2.internal
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

`STATUS` will be SchedulingDisabled, because `kubectl cordon` command have applied a taint into this node to make sure no new pods are schedule in it.

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
rm -rf /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/applications/01-pdb-sample-app.yaml

cat <<'EOF' >> /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/applications/01-pdb-sample-app.yaml
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
cd /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/
git add .
git commit -m "Changed PDB manifest from 3 to 1"
git push origin main
```

Wait few seconds, and validate that flux has applied the new PDB:

```bash
kubectl get pdb/nginx-pdb -ndefault
```

You should see the output similar to this:

```
NAME        MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
nginx-pdb   1               N/A               2                     36m
```

Now let's drain our Node again, using `kubectl drain` to safely evict all of your pods from your old nodes to the new ones.

```bash
kubectl drain $(kubectl get nodes -l node-type=applications -oname) --ignore-daemonsets
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
kubectl get pods -o=custom-columns=NAME:.metadata.name,NODE:.spec.nodeName
```

You should now be able to see only a single Node managed by Karpenter, and all pods running in this new Node.

## Conclusion

In this workshop, we have explored the use of Karpenter for managing node provisioning in Amazon EKS clusters. We have seen how Karpenter uses Amazon EKS optimized AMIs and matches the Control Plane version of the nodes it launches.

During the node rollout process, it is crucial to protect pods from unexpected disruptions. This is where Pod Disruption Budgets (PDBs) come in handy. A PDB specifies the minimum number of pods that must be available during a disruption. However, an aggressive PDB setting can lead to PodEvictionFailure, which can directly impact the upgrade process. Too many unavailable pods can make it challenging for Kubernetes to schedule new pods and result in prolonged downtime. Therefore, it is essential to strike the right balance between pod protection and successful node rollouts.





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

As you can see in the above log we got an error when evicting pods due to too agressive PDB, let's fix it.





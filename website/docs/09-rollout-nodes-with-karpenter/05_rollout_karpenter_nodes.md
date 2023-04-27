---
id: rollout-nodes5
sidebar_label: 'Rollout nodes with right PDB'
sidebar_position: 5
---

# Rollout nodes fixed PDB 

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





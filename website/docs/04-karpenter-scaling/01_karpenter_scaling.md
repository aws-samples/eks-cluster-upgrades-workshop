---
id: karpenter-scaling
sidebar_label: 'Karpenter Node Upgrade'
sidebar_position: 2
---

# Exploring our workload

In the previous module we applied the `HPA` manifest for our sample application, let's see how does this pods look like:

```bash
kubectl -n default get pod
```

The output should look like this:
```
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6b855ddcb7-457ls   0/1     Pending   0          7s
nginx-6b855ddcb7-bbck2   0/1     Pending   0          5s
nginx-6b855ddcb7-kphps   0/1     Pending   0          4s
```

You will see that those 3 replicas are in pending state, this is because there is no Nodes that satisfy the defined constraints.

```bash
cat /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications/01-sample-app.yaml | grep nodeSelector -A5
```

The output should look like this:
```yaml output
nodeSelector: # Force scale on Karpenter nodes
  node-type: applications
tolerations: # Force scale on Karpenter nodes
  - key: "applications"
    operator: "Exists"
    effect: "NoSchedule"
```

We are defining a `nodeSelector`, this will make sure that our pods will be placed only in the Nodes with that label applied, let's make sure that we don't have any Node that satisfy this constraint:

```bash
kubectl get nodes -l node-type=applications
```

The output should look like this:

```output
No resources found
```
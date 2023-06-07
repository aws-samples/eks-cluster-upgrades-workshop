---
id: karpenter
sidebar_label: 'Karpenter'
sidebar_position: 5
---

# Karpenter during the upgrade process

Karpenter is a Kubernetes node scaling that has the goal of automatically launches just the right compute resources to handle your cluster’s applications. Many people position Karpenter just to save money, making Spot instance usage easier, but Karpenter can also help a customer reduce their operational overhead. Karpenter, by default, will use Amazon EKS optimized AMIs. Whenever Karpenter launches a new node, it will match the Control Plane version of that node. It means that after an upgrade process you don’t need to upgrade all your Nodes at once, you can let Karpenter little by little replace nodes with old kubelet version, to new ones that matches EKS Control Plane version.

## Exploring the workload

In the previous module we have enabled `karpenter` in flux `kustomization` file. In [Karpenter provisioner](https://karpenter.sh/preview/concepts/provisioners/) we have defined specific labels and a taint, see manifest below:

```yaml
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  providerRef:
    name: default
  taints:
    - key: applications
      effect: NoSchedule
  labels:
    node-type: applications
  # Provisioner file continues
```

This will make sure that only applications that we define both `NodeSelector` and a `Toleration` to karpenter taint will be scheduled into Karpenter nodes. Let's verify our `sample-app` manifest:

```bash
cat /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications/01-sample-app.yaml | grep nodeSelector -A5
```

The output should look like this:

```yaml
nodeSelector: # Force scale on Karpenter nodes
  node-type: applications
tolerations: # Force scale on Karpenter nodes
  - key: "applications"
    operator: "Exists"
    effect: "NoSchedule"
```

## Verify Node provisioning

Karpenter will provision Nodes based on Pods in Pending state, since we already had our sample-app Pods in that state let's check if Karpenter already provisioned a Node to handle that workload, first let's validate that our sample-app Pods are up and running:

```bash
kubectl -n default get pod
```

The output should look like this:

```
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6b855ddcb7-457ls   1/1     Running   0          58m
nginx-6b855ddcb7-bbck2   1/1     Running   0          58m
nginx-6b855ddcb7-kphps   1/1     Running   0          58m
```

Now let's verify the new Node by passing `node-type=applications` label:

```
kubectl get nodes -l node-type=applications
```

Your output should me similar to this:

```
NAME                             STATUS   ROLES    AGE   VERSION
ip-192-168-60-113.ec2.internal   Ready    <none>   21m   v1.24.xx-eks-a59e1f0
```

:::tip
In the above command you will see that Karpenter by default will match the kubelet Node version with the EKS Control Plane version.
:::

To make sure that those Pods are running in this new Node created by Karpenter, let's execute the following command:

```bash
kubectl -n default get pods -o wide --field-selector spec.nodeName=$(kubectl get nodes -l node-type=applications | awk '/ip/ {print $1}')
```

The output should look like this:

```
NAME                    READY   STATUS    RESTARTS   AGE   IP             NODE                                        NOMINATED NODE   READINESS GATES
nginx-c5bfd7b85-9snbt   1/1     Running   0          48m   10.35.33.113   ip-10-35-46-50.us-east-2.compute.internal   <none>           <none>
nginx-c5bfd7b85-g67lb   1/1     Running   0          48m   10.35.33.115   ip-10-35-46-50.us-east-2.compute.internal   <none>           <none>
nginx-c5bfd7b85-swmvj   1/1     Running   0          48m   10.35.33.112   ip-10-35-46-50.us-east-2.compute.internal   <none>           <none>
```

In this module, we used Karpenter for Node scaling, making sure that just what we apply both `toleration` and `NodeSelector` will be scheduled in Karpenter Nodes.
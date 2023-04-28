---
id: karpenter-scaling
sidebar_label: 'Karpenter during upgrades'
sidebar_position: 1
---

# How Karpenter can help customers during the upgrades process?

Karpenter is a Kubernetes node scaling that has the goal of automatically launches just the right compute resources to handle your cluster's applications. Many people position Karpenter just as a way to save money making Spot instance usage easier, but Karpenter can also help customer in reduce their operational overhead. Karpenter by default will use Amazon EKS optimized AMIs, whenever Karpenter launches a new node, it will match the Control Plane version of that node. It means that after an upgrade process you don't need to upgrade all your Nodes at once, you can let Karpenter little by little replace nodes with old kubelet version, to new ones that matches EKS Control Plane version.

## Exploring our workload

In the previous module we applied the `HPA` manifest for our sample application, let's see how does this pods look like:

```bash
kubectl get po -ndefault
```

The output should look like this:

```bash
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6b855ddcb7-457ls   0/1     Pending   0          7s
nginx-6b855ddcb7-bbck2   0/1     Pending   0          5s
nginx-6b855ddcb7-kphps   0/1     Pending   0          4s
```

You will see that those 3 replicas are in pending state, this is because there is no Nodes that satisfy the constraints defined in the `/home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/applications/01-sample-app.yaml`:

```yaml
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

## Enabling Karpenter in our GitOps environment

Giving access to Karpenter's role in `aws-auth` configmap using eksctl.

```bash
eksctl create iamidentitymapping \
  --username system:node:{{EC2PrivateDNSName}} \
  --cluster "${CLUSTER_NAME}" \
  --arn "arn:aws:iam::${AWS_ACCOUNT_ID}:role/KarpenterNodeRole-${CLUSTER_NAME}" \
  --group system:bootstrappers \
  --group system:nodes
```

Creating Service Account for Karpenter pod to use.

```bash
eksctl create iamserviceaccount \
  --cluster "${CLUSTER_NAME}" --name karpenter --namespace karpenter \
  --role-name "${CLUSTER_NAME}-karpenter" \
  --attach-policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/KarpenterControllerPolicy-${CLUSTER_NAME}" \
  --role-only \
  --approve
```

You can confirm the entry is now in the `aws-auth` configMap and the IRSA has been created correctlu by running the following commands.

```bash
kubectl describe configmap -n kube-system aws-auth
eksctl get iamserviceaccount --cluster $CLUSTER_NAME --namespace karpenter    
```

Now, we need to enable Karpenter in our cluster, to do that we will need to change `02-karpenter-template.yaml` manifest, replacing the environment variables that we have exported previously.

```bash
envsubst < /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/add-ons/02-karpenter-template.yaml > /home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/add-ons/02-karpenter.yaml
```

The command above will replace all environment variables from our karpenter template yaml file and forward the output to `/home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/add-ons/02-karpenter.yaml`

## Adding newly created Karpenter manifest into Kustomization

Open `/home/ec2-user/environment/eks-cluster-upgrades-workshop/gitops/add-ons/kustomization.yaml` file, and uncomment `line 5`, your Kustomization manifest should look like this:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - 01-metric-server.yaml
  - 02-karpenter.yaml
```

## Applying changes

In order to activate Karpenter we will need to commit, so `Flux` controller will sync the manifests from SMC repo to our cluster.

```bash
cd /home/ec2-user/environment/eks-cluster-upgrades-workshop/
git add .
git commit -m "Added Karpenter manifest file"
git push origin main
```

## Veryfing if Karpenter was deployed

Let's see if flux deployed karpenter `helmrelase` by executing the follow command:

```bash
kubectl get helmrelease -nflux-system
```

Your output should look like this:

```bash
NAME             AGE     READY   STATUS
karpenter        58s     True    Release reconciliation succeeded
metrics-server   3d22h   True    Release reconciliation succeeded
```

Make sure the `STATUS` is `Release reconciliation succeeded`

## Verify Node provisioning

Karpenter will provision Nodes based on Pods in Pending state, since we already had our `sample-app` Pods in that state let's check if Karpenter already provisioned a Node to handle that workload, first let's validate that our `sample-app` Pods are up and running:

```bash
kubectl get po -ndefault
```

The output should look like this:

```bash
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6b855ddcb7-457ls   1/1     Running   0          58m
nginx-6b855ddcb7-bbck2   1/1     Running   0          58m
nginx-6b855ddcb7-kphps   1/1     Running   0          58m
```

Now let's verify the new Node by passing `node-type=applications` label:

```bash
kubectl get nodes -l node-type=applications
```

Your output should me similar to this:

```
NAME                             STATUS   ROLES    AGE   VERSION
ip-192-168-60-113.ec2.internal   Ready    <none>   21m   v1.23.xx-eks-a59e1f0
```

> In the above command you will see that Karpenter by default will matches the `kubelet` Node version with the EKS Control Plane version.

To make sure that those Pods are running in this new Node created by Karpenter, let's execute the follow command:

```bash
kubectl get pods -ndefault -owide --field-selector spec.nodeName=$(kubectl get nodes -l node-type=applications | grep -i ip | awk '{print $1}')
```

```output
NAME                     READY   STATUS    RESTARTS   AGE   IP               NODE                             NOMINATED NODE   READINESS GATES
nginx-6b855ddcb7-457ls   1/1     Running   0          63m   192.168.51.201   ip-192-168-60-113.ec2.internal   <none>           <none>
nginx-6b855ddcb7-bbck2   1/1     Running   0          63m   192.168.37.171   ip-192-168-60-113.ec2.internal   <none>           <none>
nginx-6b855ddcb7-kphps   1/1     Running   0          63m   192.168.61.66    ip-192-168-60-113.ec2.internal   <none>           <none>
```
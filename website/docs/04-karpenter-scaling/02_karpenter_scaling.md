---
id: karpenter-scaling2
sidebar_label: 'Enabling Karpenter'
sidebar_position: 2
---

# Enabling Karpenter in our GitOps environment

Giving access to Karpenter's role in `aws-auth` configmap using eksctl.

> All the required roles and policies were created using `Cloudformation`

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
envsubst < /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/add-ons/02-karpenter-template.yaml > /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/add-ons/02-karpenter.yaml
```

The command above will replace all environment variables from our karpenter template yaml file and forward the output to `/home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/add-ons/02-karpenter.yaml`

## Adding newly created Karpenter manifest into Kustomization

Open `/home/ec2-user/environment/eks-cluster-upgrades-reference-arch/gitops/add-ons/kustomization.yaml` file, and uncomment `line 5`, your Kustomization manifest should look like this:

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
cd /home/ec2-user/environment/eks-cluster-upgrades-reference-arch/
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
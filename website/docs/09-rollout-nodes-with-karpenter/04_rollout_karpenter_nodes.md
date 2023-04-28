---
id: rollout-nodes4
sidebar_label: 'Adjusting PDB'
sidebar_position: 4
---

# Adjusting PDB

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

:::tip
We have changed the `minAvailable` from `3` to `1`, this will give us space to drain.
:::


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

You should see the output similar to this:

```
NAME        MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
nginx-pdb   1               N/A               2                     36m
```






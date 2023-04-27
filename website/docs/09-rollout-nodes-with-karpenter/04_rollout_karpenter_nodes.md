---
id: rollout-nodes4
sidebar_label: 'Adjusting PDB'
sidebar_position: 4
---

# Adjusting PDB

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






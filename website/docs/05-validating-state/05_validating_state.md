---
id: validating-state5
sidebar_label: 'Applying your changes'
sidebar_position: 5
---

## Applying changes

Before apply the changes let's verify which `apiVersion` Flux has in its inventory

```bash
kubectl -n flux-system describe kustomization/apps | grep -i inventory -A7
```

Output should be similar to this:

```yaml output
Inventory:
  Entries:
    Id:                   default_nginx_apps_Deployment
    V:                    v1
    Id:                   default_hello_batch_CronJob
    V:                    v1beta1
    Id:                   default_nginx-hpa_autoscaling_HorizontalPodAutoscaler
    V:                    v2beta1
```
As you can see we are still using deprecated `apiVersions` for `HPA` and `Cronjob`

Now that you've validated the updated manifests, add-ons, helm charts and applications commit the changes to your repository:

```bash
git add .
git commit -m "Updated deprecated APIs"
git push origin main
```

Finally, let's verify Flux inventory again, it can take few minutes to update:

```bash
kubectl -n flux-system describe kustomization/apps | grep -i inventory -A7
```

Output should look like this, as you can see the `apiVersions` have changed

```yaml output
Inventory:
  Entries:
    Id:                   default_nginx_apps_Deployment
    V:                    v1
    Id:                   default_hello_batch_CronJob
    V:                    v1
    Id:                   default_nginx-hpa_autoscaling_HorizontalPodAutoscaler
    V:                    v2
```

## Conclusion

By validating the state of your Kubernetes resources before an upgrade and use Pluto and kubectl convert to update deprecated APIs, you can avoid compatibility issues and ensure a successful upgrade. Regularly checking for deprecated APIs and keeping your manifests up to date will help maintain a healthy and stable Kubernetes environment.

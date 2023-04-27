---
id: flux-folder
sidebar_label: 'Flux folder structure'
sidebar_position: 2
---

# Exploring the environment, flux folder structure:

In this topic, we will explore the Flux configurations within the GitHub repository. We will examine the contents and purpose of each file in the Applications and Add-ons folders, offering a clear understanding of the repository's structure and how it contributes to managing Kubernetes deployments through GitOps principles.

**Objective**: Gain a deeper understanding of the Flux configurations in the provided GitHub repository, specifically the Applications and Add-ons folders, to improve your ability to manage containerized applications using Flux in Kubernetes clusters.

## Kustomize
Kustomize is a Kubernetes-native configuration management tool that allows you to customize Kubernetes manifests declaratively without templating. It helps manage and deploy complex applications by generating customized resource configurations from reusable base manifests and environment-specific patches.

In the context of Flux, a Kustomization object is a custom resource defined by the Kustomization CRD. Flux uses Kustomization resources to manage Kubernetes manifests, specifying the syncing interval, pruning resources, and validating manifests before applying them.

This enables a more organized and automated approach to managing Kubernetes manifests, improving overall efficiency and reducing the risk of human error.

# Flux folder structure

![Create fork](../../static/img/flux-flow-diagram.png)

> Below we have the explanation around how this folder structure works and what it is used for.

## Clusters Folder
The folder contains Flux configuration files for a Kubernetes cluster named "cluster-demo". Each cluster has its own folder within the Clusters directory. Key files include infra.yaml for configuring Flux deployment, dependencies.yaml for defining Kustomization resources and dependencies, apps.yaml for managing Kubernetes manifest deployments, and sources.yaml for defining Kustomization resources related to sources. These files work together to manage and deploy Kubernetes resources within the connected Git repository.

1. `infra.yaml` - This file is a Kustomization resource definition for Flux, responsible for configuring how Flux deploys and manages the manifests present in the ./gitops/add-ons directory of the connected Git repository.

2. `dependencies.yaml` - This file is a Kubernetes manifest file written in YAML format that defines a Kustomization resource using the Flux CD toolkit. The Kustomization resource is used to customize and deploy Kubernetes resources, in this case for the Karpenter Provisioner application.

The **dependsOn** field in the Kustomization resource is used to specify that the Karpenter Provisioner application depends on another resource called "infrastructure", which is defined elsewhere in the configuration. By setting this dependency, the Karpenter Provisioner will not be deployed until the infrastructure resource is available and properly configured.

3. `apps.yaml` file is a Kubernetes manifest file that defines a Kustomization resource using the Flux CD toolkit. The purpose of this resource is to manage the deployment of the Kubernetes manifests present in the ./gitops/applications directory of the Git repository connected to the cluster.

4. `sources.yaml` - This is another Kubernetes manifest file written in YAML format that defines a Kustomization resource using the Flux CD toolkit. This particular Kustomization resource is named "sources" and it also belongs to the "flux-system" namespace

Verify in cluster:

```bash
kubectl get kustomization -nflux-system
```

## Sources folder

The Sources Folder contains various files for managing Kubernetes resources, such as the kustomization.yaml, which lists resources to be applied in the configuration, referencing metric-server-helm.yaml and karpenter-helm.yaml. The karpenter-helm.yaml and metric-server-helm.yaml files define Karpenter and Metrics Server HelmRepository resources, respectively, using the source.toolkit.fluxcd.io/v1beta2 API version and HelmRepository kind. Both resources belong to the flux-system namespace.

1. `kustomization.yaml` - This file is a Kustomize configuration file that lists the resources to be included when applying the files in the list. In this case, it references metric-server-helm.yaml and karpenter-helm.yaml, ensuring that the Karpenter chart and the Metric Server addon are applied as part of the configuration.

2. `karpenter-helm.yaml` - This is a YAML manifest file that defines Karpenter HelmRepository resource in Kubernetes. The HelmRepository resource is defined using the source.toolkit.fluxcd.io/v1beta2 API version and HelmRepository kind. It has the name karpenter in the metadata section and belongs to the flux-system namespace.

3. `metric-server-helm.yaml` - This is a YAML manifest file that defines Metrics Server HelmRepository resource in Kubernetes. The HelmRepository resource is defined using the source.toolkit.fluxcd.io/v1beta2 API version and HelmRepository kind. It has the name metrics-server in the metadata section and belongs to the flux-system namespace.

Verify in cluster:

```bash
kubectl get helmrepository -nflux-system
```

## Add-ons Folder

The Add-ons Folder contains files for configuring and deploying additional cluster features, such as the metrics-server.yaml file, which sets up the Metrics Server add-on for aggregating resource usage data across the cluster. This add-on is crucial for autoscaling and performance monitoring. The kustomization.yaml file serves as a Kustomize configuration file, listing the resources included in the Add-ons folder configuration, ensuring proper deployment of the Metrics Server add-on.

1. `metrics-server.yaml` - This file configures and deploys the Metrics Server add-on, a cluster-wide aggregator of resource usage data. Metrics Server is responsible for collecting and storing metrics such as CPU and memory usage from Kubernetes nodes and pods. These metrics are essential for autoscaling and monitoring the performance of your cluster. The file includes the necessary Kubernetes resources to deploy Metrics Server, such as the Deployment, Service, and ServiceAccount.

2. `02-karpenter-template.yaml` - This file configures and deploys the Karpenter add-on.

3. `kustomization.yaml` - This file is a Kustomize configuration file that lists the resources to be included when applying the Add-ons folder configuration. In this case, it references metrics-server.yaml, ensuring that the Metrics Server add-on is applied as part of the configuration.

Verify in cluster:

```bash
kubectl get helmrelease -nflux-system
```

## Karpenter provisioner folder

These two files are necessary components of the Karpenter add-on in Kubernetes. `kustomization.yaml` ensures that the Karpenter Provisioner and AWSNodeTemplate resources are included in the configuration, while `01-default-karpenter-provisioner.yaml` defines the resources themselves. However, it is important to install the Karpenter controller before applying `01-default-karpenter-provisioner.yaml` to ensure that the resources can function as intended.

1. `kustomization.yaml` - This file is a Kustomize configuration file that lists the resources to be included when applying the files in the list. In this case, it references 01-default-karpenter-provisioner.yaml, ensuring that the Karpenter Provisioner is applied as part of the configuration.

2. `01-default-karpenter-provisioner.yaml` - This YAML manifest file defines a Provisioner and an AWSNodeTemplate in Kubernetes. The Provisioner specifies constraints on provisioned nodes and enables consolidation, while the AWSNodeTemplate specifies the cluster name and security group for the AWS subnet and applies tags to AWS nodes.

Validate in cluster:

```bash
kubectl get deployment -n karpenter
```

> Note: Karpenter is not yet deployed

## Applications Folder

The Applications Folder contains files for managing Kubernetes deployments, such as the 01-sample-app1.yaml file that defines a deployment for an sample application. It specifies replica details, container images, and resource requirements. Additionally, the kustomization.yaml file streamlines resource management by listing resource files and customizations, ensuring that they are applied together as a single configuration.

1. `01-sample-app1.yaml` - This file defines a Kubernetes deployment for a sample application. It contains the specifications for the deployment, such as the desired number of replicas, labels, and the container image to be used. Additionally, it includes resource limits and requests, as well as the necessary environment variables.

2. `02-cronjob.yaml` - This file defines a Kubernetes cronJob object that will run in a certain period of time.

4. `kustomization.yaml` - This file is a Kustomize configuration file that simplifies the management of Kubernetes resources. It lists the resource files to be included and any necessary patches or customizations. In this case, it references app1.yaml, app2.yaml, and ingress.yaml, ensuring they are applied together as a single configuration.

Validate in cluster:

```bash
kubectl get deployment -ndefault

kubectl get cronjob -ndefault
```
# Creating the environment

In order to properly start the environment you will need to deploy the following Cloudformation template:

[EKS Upgrades Workshop CF](../helpers/cloudformation.yaml)

> This can be done, either via console or terminal

The above Cloudformation script will provision a `Cloud9` instance to use during the workshop, with all the required tools in order to execute the workshop.

> After the Cloudformation finished, wait at **least 10 more minutes** so the SSM script can execute in the Cloud9 instance installing all the needed components.

## Export your GitHub's personal access token and username:

:heavy_exclamation_mark: If you don't have one token yet, check the [Creating a personal access token guide](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token). :heavy_exclamation_mark:

> Remember to use the GitHub legacy tokens

```
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=<your-username>
```

```bash
echo "export GITHUB_TOKEN=${GITHUB_TOKEN}" | tee -a ~/.bash_profile
echo "export GITHUB_USER=${GITHUB_USER}" | tee -a ~/.bash_profile
```

## Create a fork of this [repo](https://github.com/lusoal/eks-cluster-upgrades-workshop.git) in your GitHub account.

<p align="center">
<img src="../docs/static/create-fork01.png">
</p>

<p align="center">
<img src="../docs/static/create-fork02.png">
</p>


## Clone your forked in your environment.

```bash
git clone https://github.com/$GITHUB_USER/eks-cluster-upgrades-workshop.git
```
> It may ask for `username` and `password`, for the password use your `$GITHUB_TOKEN` instead

After cloning the repo, we will need to change `cluster-template.yaml` file to update personal variables.

```bash
envsubst < /home/ec2-user/environment/eks-cluster-upgrades-workshop/helpers/cluster-template.yaml > /home/ec2-user/environment/eks-cluster-upgrades-workshop/helpers/cluster.yaml
```

# Create your EKS Cluster.

```bash
eksctl create cluster -f /home/ec2-user/environment/eks-cluster-upgrades-workshop/helpers/cluster.yaml
```

## Export your Cluster Endpoint.

```bash
export CLUSTER_ENDPOINT="$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.endpoint" --output text)"
echo "export CLUSTER_ENDPOINT=${CLUSTER_ENDPOINT}" >> /home/ec2-user/.bashrc
```

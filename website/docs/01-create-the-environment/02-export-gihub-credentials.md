---
id: export-github
sidebar_label: 'Fork GitHub repository'
sidebar_position: 5
---

# Export your GitHub's personal access token and username:

:::info
If you don't have one token yet, check the [Creating a personal access token guide](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).
:::

:::caution
Remember to use the GitHub legacy tokens
:::

```bash
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=<your-username>
```

```bash
echo "export GITHUB_TOKEN=${GITHUB_TOKEN}" | tee -a ~/.bash_profile
echo "export GITHUB_USER=${GITHUB_USER}" | tee -a ~/.bash_profile
```

### Create a fork of this [repo](https://github.com/aws-samples/eks-cluster-upgrades-workshop) in your GitHub account.

![Create fork](../../static/img/create-fork01.png)

![Create fork2](../../static/img/create-fork02.png)


### Clone your forked in your environment.

```bash
git clone https://github.com/$GITHUB_USER/eks-cluster-upgrades-workshop.git
```

:::tip
It may ask for `username` and `password`, for the password use your `$GITHUB_TOKEN` instead
:::

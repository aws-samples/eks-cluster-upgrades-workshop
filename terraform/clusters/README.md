# How to deploy

You will need to fork this

Execute `install.sh` script passing the following parameters:

- git_password
- git_username
- git_url
- git_branch
- aws_region

Your execution should look linke this:

```bash
./install.sh ghp_xxxxxxxxx user_name https://github.com/user_name/eks-cluster-upgrades-workshop.git your_desired_branch
```

After that you will need to uncomment lines `5` and `6` of `gitops/add-ons/kustomization.yaml` file

Then you can push the changes to your desired branch and flux will reconcile the changes
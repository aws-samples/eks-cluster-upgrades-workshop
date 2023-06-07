#!/bin/sh

# Set variables
region=$1
cluster_name=$2
current_k8s_version=1.24
target_k8s_version=1.25


# Get current add-ons installed in the cluster
current_addons=$(eksctl get addons --cluster $cluster_name --region $region --output json | jq -r '.[] | .Name + "&" + .Version')

# Get target add-ons supported for the Kubernetes version you want to upgrade to
target_addons=$(eksctl utils describe-addon-versions --kubernetes-version $target_k8s_version | grep -v 'describing all*' | jq -r '.Addons[] | .AddonName + "&" + (.AddonVersions[] | .AddonVersion)')

echo "=========================== EKS Managed add-ons ===========================" > /tmp/managed-addons.txt

if [[ $3 == "--validate-support-target-version" ]]; then
  echo "Validating if add-ons are supported in the target version"
  upgrade_need=false
  for addon in $current_addons; do
    if [[ ! $(echo "$target_addons" | grep -w "$addon") ]]; then
      addon_name=$(echo $addon | cut -d"&" -f1)
      addon_version=$(echo $addon | cut -d"&" -f2)
      echo "Add-on $addon_name version $addon_version is not supported in the target version" >> /tmp/managed-addons.txt
      upgrade_need=true
    fi
  done
  if ! $upgrade_need; then
    echo "Add-on upgrade not needed, all add-ons are supported in the target version" >> /tmp/managed-addons.txt
  fi

elif [[ $3 == "--validate-if-needs-to-upgrade" ]]; then
  echo "Validate if there is any add-on version upgrade to perform"
  for addon in $current_addons; do
    addon_name=$(echo $addon | cut -d"&" -f1)
    addon_version=$(echo $addon | cut -d"&" -f2)
    latest_version=$(echo "$target_addons" | grep $addon_name | awk -F"&" '{print $2}' | sort -rV | head -n 1)
    if [[ ! -z "$latest_version" && "$addon_version" != "$latest_version" ]]; then
      echo "Need to upgrade $addon_name from $addon_version to $latest_version" >> /tmp/managed-addons.txt
    fi
  done

else
  echo "Please provide the parameter --validate-support-target-version or --validate-if-needs-to-upgrade"
fi

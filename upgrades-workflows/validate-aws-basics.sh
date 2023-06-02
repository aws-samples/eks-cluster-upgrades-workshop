#!/bin/sh

# Input parameters
cluster_role_name=$1
vpc_id=$2
cluster_security_group_id=$3
aws_region=$4

# Validate subnets for at least 5 IPs
if aws ec2 describe-subnets --filters "Name=vpc-id,Values=${vpc_id}" --query "Subnets[?AvailableIpAddressCount > \`5\`].SubnetId" --output text --region ${aws_region} | grep . >/dev/null; then
  subnet_check="At least one subnet has more than 5 IPs available"
else
  subnet_check="No subnet has more than 5 IPs available"
fi

# Validate cluster role existence
if aws iam get-role --role-name ${cluster_role_name} --region ${aws_region} &>/dev/null; then
  role_check="Cluster role exists"
else
  role_check="Cluster role does not exist"
fi

# Validate cluster security group existence
if aws ec2 describe-security-groups --group-ids ${cluster_security_group_id} --region ${aws_region} &>/dev/null; then
  sg_check="Cluster security group exists"
else
  sg_check="Cluster security group does not exist"
fi

echo "========================== AWS BASICS VALIDATION ==========================" > /tmp/my_file.txt
# Persist the checks in the file
echo "Subnet Check: ${subnet_check}" >> /tmp/my_file.txt
echo "Role Check: ${role_check}" >> /tmp/my_file.txt
echo "Security Group Check: ${sg_check}" >> /tmp/my_file.txt
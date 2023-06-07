################################################################################
# VPC
################################################################################
output "aws_vpc_id" {
  value = module.vpc.vpc_id
}

output "aws_region" {
  value = var.aws_region
}

################################################################################
# Cluster
################################################################################
output "cluster_iam_role_name" {
  value = module.eks.cluster_iam_role_name
}

output "cluster_name" {
  description = "The Amazon Resource Name (ARN) of the cluster, use"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_primary_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}

################################################################################
# Karpenter
################################################################################
output "karpenter_irsa" {
  value = module.karpenter_irsa_role.iam_role_arn
}

output "karpenter_instance_profile" {
  value = aws_iam_instance_profile.karpenter_instance_profile.name
}

################################################################################
# Argo Workflows
################################################################################
output "argo_workflows_irsa" {
  value = module.argo_workflows_eks_role.iam_role_arn
}

output "argo_workflows_bucket_name" {
  value = aws_s3_bucket.argo-artifacts.id
}

output "argo_workflows_bucket_arn" {
  value = aws_s3_bucket.argo-artifacts.arn
}
################################################################################
# Karpenter Role to use in nodes created by Karpenter
################################################################################

resource "aws_iam_role" "karpenter_node_role" {
  name = "KarpenterNodeRole-${var.name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "container_registry_policy" {
  name       = "KarpenterAmazonEC2ContainerRegistryReadOnly"
  roles      = [aws_iam_role.karpenter_node_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_policy_attachment" "amazon_eks_worker_node_policy" {
  name       = "KarpenterAmazonEKSWorkerNodePolicy"
  roles      = [aws_iam_role.karpenter_node_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_policy_attachment" "amazon_eks_cni_policy" {
  name       = "KarpenterAmazonEKS_CNI_Policy"
  roles      = [aws_iam_role.karpenter_node_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_policy_attachment" "amazon_eks_ssm_policy" {
  name       = "KarpenterAmazonSSMManagedInstanceCore"
  roles      = [aws_iam_role.karpenter_node_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "karpenter_instance_profile" {
  name = "KarpenterNodeInstanceProfile-${var.name}"
  role = aws_iam_role.karpenter_node_role.name
}

################################################################################
# Karpenter IRSA
################################################################################

module "karpenter_irsa_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                          = "karpenter_controller"
  attach_karpenter_controller_policy = true

  karpenter_controller_cluster_name         = module.eks.cluster_name
  karpenter_controller_node_iam_role_arns = [aws_iam_role.karpenter_node_role.arn]

  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["karpenter:karpenter"]
    }
  }
}
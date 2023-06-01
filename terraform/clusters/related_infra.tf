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
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      roles
    ]
  }
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

resource "aws_iam_policy" "karpenter-policy" {
  name        = "karpenter-policy"
  path        = "/"
  description = "karpenter-policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
      }
    ]
  })
}

# TODO: Improve policy defined here, to a more specific one
resource "aws_iam_policy_attachment" "karpenter_policy_attach" {
  name       = "karpenter-admin"
  roles      = [module.karpenter_irsa_role.iam_role_name]
  policy_arn = aws_iam_policy.karpenter-policy.arn
  users = []

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      roles, users
    ]
  }
}

################################################################################
# Argo Workflows needs
################################################################################
module "argo_workflows_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "argo-workflows-irsa"

  # TODO: Change to specific policy
  role_policy_arns = {
    policy = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["argo-workflows:full-permissions-service-account", "argo-workflows:argo-workflows-server"]
    }
  }
}


resource "random_uuid" "uuid" {}

# To store argo artifacts
resource "aws_s3_bucket" "argo-artifacts" {
  bucket = "my-tf-test-bucket-${random_uuid.uuid.result}"

  tags = {
    Blueprint  = var.name
  }
}
resource "aws_iam_user" "eks" {
  name = "eks-manager"
  path = "/"

  tags = {
    Description = "EKS Account for devops engineer"
  }
}

module "eks" {
  source           = "terraform-aws-modules/eks/aws"
  version          = "~> 18.0"

  cluster_name     = var.manager_cluster_name
  cluster_version  = "1.21"
  subnet_ids       = module.vpc.private_subnets
  vpc_id           = module.vpc.vpc_id
  enable_irsa      = true

  tags = {
    Project     = "gigapress"
  }

  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "crossplane-system"
        },
        {
          namespace = "flux-system"
        }
      ]
    }
  }

  aws_auth_users = [
    {
      userarn  = aws_iam_user.eks.arn
      username = aws_iam_user.eks.name
      groups   = ["system:masters"]
    }
  ]
}


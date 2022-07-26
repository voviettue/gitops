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
  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts        = "OVERWRITE"
    }
  }

  node_security_group_additional_rules = {
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress_all = {
      description      = "Node all ingress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "ingress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    disk_size      = 10
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    main = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
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


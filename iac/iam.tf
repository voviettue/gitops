resource "aws_iam_role" "eks" {
  name = "eks-cluster-role"
  path = "/gigapress/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Description = "General eks cluster role"
  }
}

resource "aws_iam_role" "node_group" {
  name = "node-group-role"
  path = "/gigapress/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Description = "General node_group role"
  }
}

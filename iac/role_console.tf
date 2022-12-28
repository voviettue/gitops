data "aws_iam_policy_document" "console_oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.selected.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values = [
        "system:serviceaccount:default:api"
      ]
    }
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.selected.identity[0].oidc[0].issuer, "https://", "")}"
      ]
      type = "Federated"
    }
  }
}

resource "aws_iam_role" "console" {
  name        = "console"
  description = "Permissions required by console apiserver."
  path        = null

  force_detach_policies = true

  assume_role_policy = data.aws_iam_policy_document.console_oidc.json
}

# PERMISSIONS ACCESS TO
# - ledger
# - codeartifact
# - ecr
# - dynamodb
# - s3
# - coginito
data "aws_iam_policy_document" "console" {
  # QLDB
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["qldb:*"]
  }

  # Ecr
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = [
      "ecr:ListImages",
      "ecr:ListTagsForResource",
      "ecr:DescribeRegistry",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
    ]
  }

  # DynamoDB
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = [
      "dynamodb:*",
    ]
  }

  # CaF
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = [
      "codeartifact:*",
    ]
  }

  # S3
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = [
      "s3:*",
    ]
  }

  # Coginito
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "cognito-identity:*"
    ]
  }
}

resource "aws_iam_policy" "console" {
  name        = "console"
  description = "Permissions that are required to console handle its job."
  path        = null
  policy      = data.aws_iam_policy_document.console.json
}

resource "aws_iam_role_policy_attachment" "console" {
  policy_arn = aws_iam_policy.console.arn
  role       = aws_iam_role.console.name
}

data "aws_iam_policy_document" "ecr_oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.selected.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values = [
        "system:serviceaccount:flux-system:source-controller"
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

resource "aws_iam_role" "ecr" {
  name        = "ecr"
  description = "Permissions required by ecr."
  path        = null

  force_detach_policies = true

  assume_role_policy = data.aws_iam_policy_document.ecr_oidc.json
}

data "aws_iam_policy_document" "ecr" {
  # Ecr
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ecr:*"]
  }
}

resource "aws_iam_policy" "ecr" {
  name        = "ecr"
  description = "Permissions that are required to ecr handle its job."
  path        = null
  policy      = data.aws_iam_policy_document.ecr.json
}

resource "aws_iam_role_policy_attachment" "ecr" {
  policy_arn = aws_iam_policy.ecr.arn
  role       = aws_iam_role.ecr.name
}

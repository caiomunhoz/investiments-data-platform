data "aws_iam_policy_document" "github_actions_oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_provider.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:caiomunhoz*/investiments-data-platform*:ref:refs/heads/main"]
    }
  }
}

data "aws_iam_policy_document" "github_actions_ecr_push" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    resources = [aws_ecr_repository.lambda_ingest_binance_trades.arn]
  }
}

resource "aws_iam_openid_connect_provider" "github_provider" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

resource "aws_iam_role" "ecr_push" {
  name               = "investiments-data-platform-github-actions-ecr-push"
  assume_role_policy = data.aws_iam_policy_document.github_actions_oidc.json
}

resource "aws_iam_role_policy" "github_actions_ecr_push" {
  role   = aws_iam_role.ecr_push.id
  policy = data.aws_iam_policy_document.github_actions_ecr_push.json
}

resource "aws_iam_role" "terraform_ci" {
  name               = "investiments-data-platform-github-actions-terraform-ci"
  assume_role_policy = data.aws_iam_policy_document.github_actions_oidc.json
}
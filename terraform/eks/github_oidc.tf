data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "gha_assume" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity",
      "sts:TagSession",
    ]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:Sheshanadaf/Relay:*",
        "repo:Sheshanadaf@115085953/Relay@1358222498:*",
      ]
    }
  }
}

resource "aws_iam_role" "gha_ecr" {
  name               = "relay-gha-ecr"
  assume_role_policy = data.aws_iam_policy_document.gha_assume.json
}

data "aws_iam_policy_document" "gha_ecr" {
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
    resources = [
      aws_ecr_repository.api.arn,
      aws_ecr_repository.worker.arn,
      aws_ecr_repository.web.arn,
    ]
  }
}

resource "aws_iam_role_policy" "gha_ecr" {
  name   = "relay-gha-ecr"
  role   = aws_iam_role.gha_ecr.id
  policy = data.aws_iam_policy_document.gha_ecr.json
}
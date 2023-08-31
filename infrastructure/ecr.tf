resource "aws_ecr_repository" "app-repository" {
  name                 = var.ecr-repository-name
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}


data "aws_iam_policy_document" "role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [
        "build.apprunner.amazonaws.com",
        "tasks.apprunner.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ecr_role" {
  name               = "ecr-role"
  assume_role_policy = data.aws_iam_policy_document.role_policy.json
}
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

data "aws_ecr_authorization_token" "token" {
}

output "ecr-password" {
  value     = data.aws_ecr_authorization_token.token.password
  sensitive = true
}
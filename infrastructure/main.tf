terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {}

resource "aws_ecr_repository" "app-repository" {
  name                 = "app-repository"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_iam_role" "ecr-role" {
  name               = "ecr-role"
  assume_role_policy = <<EOT
{
   "Version": "2012-10-17",
   "Statement": [
     {
       "Action": "sts:AssumeRole",
       "Principal": {
         "Service": [
           "build.apprunner.amazonaws.com",
           "tasks.apprunner.amazonaws.com"
         ]
       },
       "Effect": "Allow",
       "Sid": ""
     }
   ]
 } 
 EOT
}
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.ecr-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# resource "aws_ecr_repository_policy" "ecr-user-policy" {
#   repository = aws_ecr_repository.app-repository.name
#   policy     = data.aws_iam_policy_document.ecr-user.json
# }

resource "aws_apprunner_auto_scaling_configuration_version" "hello" {
  auto_scaling_configuration_name = "hello"
  # scale between 1-5 containers
  min_size = 1
  max_size = 5
}

resource "aws_apprunner_service" "hello" {
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.hello.arn

  service_name = "hello-app-runner"

  source_configuration {
    image_repository {
      image_configuration {
        port = "8090" #The port that your application listens to in the container                             
      }

      image_identifier      = "${aws_ecr_repository.app-repository.repository_url}:latest"
      image_repository_type = "ECR"
    }
    authentication_configuration {
      access_role_arn = aws_iam_role.ecr-role.arn
    }
    auto_deployments_enabled = true
  }

  health_check_configuration {
    path = "/actuator/health"
  }
}

data "aws_ecr_authorization_token" "token" {
}

output "app-repository-name" {
  value = split("/", aws_ecr_repository.app-repository.repository_url)
}

output "app-repository-path" {
  value = aws_ecr_repository.app-repository.repository_url
}

output "ecr-password" {
  value     = data.aws_ecr_authorization_token.token.password
  sensitive = true
}

output "apprunner-url" {
  value = aws_apprunner_service.hello.service_url
}
# resource "aws_ecr_repository_policy" "ecr-user-policy" {
#   repository = aws_ecr_repository.app-repository.name
#   policy     = data.aws_iam_policy_document.ecr-user.json
# }

resource "aws_apprunner_auto_scaling_configuration_version" "scaling_config" {
  auto_scaling_configuration_name = "scaling-config"
  # scale between 1-5 containers
  min_size = 1
  max_size = 5

  max_concurrency = 200

  tags = {
    "Name" = "Scaling Config"
  }
}

resource "aws_apprunner_service" "app_runner" {
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.scaling_config.arn

  service_name = var.app-runner-name

  source_configuration {
    image_repository {
      image_configuration {
        port = "8090" #The port that your application listens to in the container

        runtime_environment_secrets = {
          "DB_CONNECTION_STRING" = local.address
          "DB_USERNAME" = local.username
          "DB_PASSWORD" = local.password
        }
      }

      image_identifier      = "${aws_ecr_repository.app-repository.repository_url}:latest"
      image_repository_type = "ECR"
    }
    authentication_configuration {
      access_role_arn = aws_iam_role.ecr_role.arn
    }
    auto_deployments_enabled = true
  }

  health_check_configuration {
    path = "/actuator/health"
  }

  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.connector.arn
    }
  }
}

resource "aws_apprunner_vpc_connector" "connector" {
  vpc_connector_name = "app-vpc"
  subnets            = [aws_subnet.private.id]
  security_groups    = [aws_security_group.endpoint_group.id]

  tags = {
    "Name" = "App Runner VPC Connector"
  }
}

output "app-repository-name" {
  value = split("/", aws_ecr_repository.app-repository.repository_url)
}

output "app-repository-path" {
  value = aws_ecr_repository.app-repository.repository_url
}

output "apprunner-url" {
  value = aws_apprunner_service.app_runner.service_url
}


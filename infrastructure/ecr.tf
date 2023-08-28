resource "aws_ecr_repository" "app-repository" {
  name                 = var.ecr-repository-name
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

data "aws_ecr_authorization_token" "token" {
}

output "ecr-password" {
  value     = data.aws_ecr_authorization_token.token.password
  sensitive = true
}
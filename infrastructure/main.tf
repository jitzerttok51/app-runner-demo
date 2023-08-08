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
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_ecr_authorization_token" "token" {
  registry_id = aws_ecr_repository.app-repository.registry_id
}

output "app-repository-name" {
  value = split("/", aws_ecr_repository.app-repository.repository_url)[0]
}

output "app-repository-path" {
  value = aws_ecr_repository.app-repository.repository_url
}

output "ecr-token" {
  value     = data.aws_ecr_authorization_token.token.authorization_token
  sensitive = true
}

// aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 184338486821.dkr.ecr.eu-central-1.amazonaws.com

// gradle bootBuildImage -Pecr.image.name=184338486821.dkr.ecr.eu-central-1.amazonaws.com/app-repository/web-app 
// -Pecr.token=eyJwYXlsb2FkIjoiZFpMZEZhdE9WdUJPaERYVHJBQlRLMVRzUjVtY3lybDdDSlplb3Y2NHFYbllMRWRDWml6SXRUeEpFRmVuRHU0akx6TUtNdVdNRWU2ZERGT2orbnA0aUhUaFg2K1dvNEJQSlVDUVptTWMvMVZWVjduZ2NjTzkrdUp4SXBYZ0tjMzdOQ3B5Rnhia015NkN1enhvRHJHQlAwZzZuSWtLYmZ3L1ROQjBucDh5NXpWVS9TdXVSNGNyck4wd1VZQUZxZlZEbGtpdHVuVythYWFRaVVXdEljU1JzSXVFK0E1c1RTMDlWZW0wbGFyTE1nUUJOemFKQzN0eTZsR3J3ai9QR1V0Rk9pazhVMlJzanMza0pLTnFvWXNyTmQ2TjBtcmcwTXpUWGpGMXAzUmkzR2dtS2NhWmVwRmdJNmxkM09mYTFDRmtLN2ZVWG9JQ09LRzF6dkZaTFlmWGhYOFRrYU5pV0NpMlNSSW1SZzVBQVNVd3dOQWh2bzd5d1RBVWtVbHBUbGR4eWtBUFBiV0ZwOERnN1FOanJDVjgwWGVKSVhrNlkzN2E4a2NXblduWk9OcEw3blZqbE1SWkhnVEJhMVZDTHVFeUVnN0dSSzBNQlkzWTY1RzdSamEyYU9Wa1JBZlJaZUMrZnpKdlhrcXl6ekRaaDNESWhUaEhHLzhjelZNZWJsVWZYcHZaTFp5dGJzQkRDYUJjM0NVU2hpVWt4WjRoUlpqdDFSR2tVV2xFWDVaR2luZ2Y1VE11NENic1ZUa3IwVGcyN0t2ZHlYVmZnYmZmY0ZzY1NWdlV1enhuUG9hbzJybnMrcWl3dTRVZlo0Y2VjK2dySnF6VHdKMDZ6NTFkeE1WOGp2VHRxaUtyZXA5Qlh5QlVSUVNQRE9xdlI2NUpZZDBCcjR0TzFGeTZLaWhwQitnTjZTOGFKUlpMSDV3OXA2eVpNUGI0NjUwdkFOdVU2VjViNFFNNTFNclZ4TXN4V2ZuZmdOdkY0NFdUakZKMWZtWnBPaHhMM1puc1ZsWTl1UGRwTDVWZ0JoNUpwTHRsU2ZNOTFjbnRiRUk0RktkbUpYTUVMUGZSczIxWFdQbnAwVGJWWVNUUnZtQ3JRL1MwdWgyOXhWd2Q2bS9TQmtVUkFQdjdFd2hkTmUvRCtXdDBpUGhSenJoNWk4cVcwaEltUG1vOTF6MkFFYmNveEQ5VjIrZEF2c3E5d092L1dvdXdyclA4U0Jpd2ZYZDJxNEtTUVZEVnd5SHJPMjArQVlaVGYvQUVkd0tkQUE4SzkrNjRqTlJnb2dpM2hMQkZMYzVJOFV6b3Q2NWZNSTdCOVowREFJS2FqVjY1ZUlLc2pHc0w2THVTTG85RkFCT1E1OEFUSWdFMHZMNi92UTA9IiwiZGF0YWtleSI6IkFRRUJBSGgzellPZHRwQkJTVncvWTJhbjhCWElENGt3TFFmbm9UajV6d1p0R0pab1pRQUFBSDR3ZkFZSktvWklodmNOQVFjR29HOHdiUUlCQURCb0Jna3Foa2lHOXcwQkJ3RXdIZ1lKWUlaSUFXVURCQUV1TUJFRURDTjRDdlJtVXNFZ3A5eEZld0lCRUlBN3FKRlk3YS9MaEZ0dVU2OUFZbG5KRkcvd1U4RlZ2YUM5aFBjRUh5RHRIR25oQTdVcmgxLzZ6eTVWLzdGZVFxM0J0S0lIU0ZzNGZXNkRRek09IiwidmVyc2lvbiI6IjIiLCJ0eXBlIjoiREFUQV9LRVkiLCJleHBpcmF0aW9uIjoxNjkxNTQxNDEwfQ==

// terraform apply  -target=output.ecr-token -auto-approve
// terraform output -raw ecr-token
// terraform output -raw app-repository-path
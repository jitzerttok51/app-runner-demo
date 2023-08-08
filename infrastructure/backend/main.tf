terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {}

resource "random_integer" "ri" {
  min = 100
  max = 999
}

resource "aws_s3_bucket" "tf-backend" {
  bucket = "tf-backend-${random_integer.ri.result}"

  tags = {
    Name        = "Terraform Backend State"
    # cdEnvironment = "Dev"
  }
}

output "bucket-name" {
  value = aws_s3_bucket.tf-backend.bucket
}
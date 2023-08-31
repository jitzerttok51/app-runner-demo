terraform {
  backend "s3" {
    bucket = "tf-backend-281"
    key    = "state/terraform.tfstate"
    region = "eu-central-1"
  }
}

# 3t6dKpiz97QrnlqaDAlE
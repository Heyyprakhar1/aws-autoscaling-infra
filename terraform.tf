terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.41.0"
    }
  }
  backend "s3" {
    bucket = "aws-autoscaling-infra-bucket"
    dynamodb_table = "aws-autoscaling-infra-lock-table"
    key = "terraform.tfstate"
    region = "ap-south-1"
    }
}

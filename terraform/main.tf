terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider (keys and region are been passed as env variable in the env.list file)
provider "aws" {}

resource "aws_s3_bucket" "tf-bucket" {
  bucket = "my-tf-test-bucket-123082137"

  tags = {
    Name = "tf-bucket"
    Environment = "Dev"
  }
}
provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "zantac-terraform-state"
    key    = "lift-and-shift/terraform.tfstate"
    region = "us-east-1"
  }
}
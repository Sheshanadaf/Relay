terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "relay-lab-tfstate-583966366465"
    key            = "eks/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "relay-lab-tfstate-lock"
  }
}

provider "aws" {
  region = "ap-south-1"
}
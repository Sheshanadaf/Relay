terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

variable "region" {
  type    = string
  default = "ap-south-1"
}

provider "aws" {
  region = var.region
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "relay_lab" {
  bucket        = "relay-lab-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "relay_lab" {
  bucket = aws_s3_bucket.relay_lab.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "bucket_name" {
  value = aws_s3_bucket.relay_lab.bucket
}
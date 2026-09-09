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

resource "aws_vpc" "relay" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "relay-lab"
  }
}

resource "aws_internet_gateway" "relay" {
  vpc_id = aws_vpc.relay.id

  tags = {
    Name = "relay-lab"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.relay.id
  cidr_block              = "10.42.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "relay-lab-public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.relay.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.relay.id
  }

  tags = {
    Name = "relay-lab-public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

output "vpc_id" {
  value = aws_vpc.relay.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}
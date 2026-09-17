variable "vpc_id" {
  default = "vpc-09050eda51ecbcdd3"
}

variable "subnet_public_a" {
  default = "subnet-08a9aed1e751ba718"
}

variable "eks_api_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
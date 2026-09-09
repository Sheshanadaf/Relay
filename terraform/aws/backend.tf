terraform {
  backend "s3" {
    bucket         = "relay-lab-tfstate-583966366465"
    key            = "relay/aws/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "relay-lab-tfstate-lock"
    encrypt        = true
  }
}
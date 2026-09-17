resource "aws_ecr_repository" "api" {
  name                 = "relay-api"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_repository" "worker" {
  name                 = "relay-worker"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_repository" "web" {
  name                 = "relay-web"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}
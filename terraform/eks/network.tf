data "aws_vpc" "lab" {
  id = var.vpc_id
}

data "aws_internet_gateway" "lab" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_route_table" "public_a" {
  subnet_id = var.subnet_public_a
}

resource "aws_subnet" "public_b" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.42.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name                     = "relay-eks-public-1b"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_ec2_tag" "public_a_elb" {
  resource_id = var.subnet_public_a
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = data.aws_route_table.public_a.id
}

resource "aws_subnet" "private_a" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.42.10.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = false
  tags = {
    Name                              = "relay-eks-private-1a"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.42.11.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false
  tags = {
    Name                              = "relay-eks-private-1b"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_eip" "nat_a" {
  domain = "vpc"
  tags   = { Name = "relay-eks-nat-a" }
}

resource "aws_eip" "nat_b" {
  domain = "vpc"
  tags   = { Name = "relay-eks-nat-b" }
}

resource "aws_nat_gateway" "a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = var.subnet_public_a
  tags          = { Name = "relay-eks-nat-1a" }
  depends_on    = [data.aws_internet_gateway.lab]
}

resource "aws_nat_gateway" "b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_b.id
  tags          = { Name = "relay-eks-nat-1b" }
  depends_on    = [data.aws_internet_gateway.lab]
}

resource "aws_route_table" "private_a" {
  vpc_id = var.vpc_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.a.id
  }
  tags = { Name = "relay-eks-private-1a" }
}

resource "aws_route_table" "private_b" {
  vpc_id = var.vpc_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.b.id
  }
  tags = { Name = "relay-eks-private-1b" }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}
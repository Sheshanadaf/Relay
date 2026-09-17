output "public_b" {
  value = aws_subnet.public_b.id
}

output "private_a" {
  value = aws_subnet.private_a.id
}

output "private_b" {
  value = aws_subnet.private_b.id
}

output "cluster_name" {
  value = aws_eks_cluster.relay.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.relay.endpoint
}
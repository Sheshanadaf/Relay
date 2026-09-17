resource "aws_eks_cluster" "relay" {
  name     = "relay"
  role_arn = aws_iam_role.eks.arn
  version  = "1.31"

  vpc_config {
    subnet_ids              = [
      var.subnet_public_a,
      aws_subnet.public_b.id,
      aws_subnet.private_a.id,
      aws_subnet.private_b.id,
    ]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster,
    aws_iam_role_policy_attachment.eks_vpc,
    aws_nat_gateway.a,
    aws_nat_gateway.b,
  ]
}

resource "aws_eks_node_group" "relay" {
  cluster_name    = aws_eks_cluster.relay.name
  node_group_name = "relay-private"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_ecr,
  ]
}
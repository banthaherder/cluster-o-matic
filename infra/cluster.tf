resource "aws_eks_cluster" "demo" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = 1.14

  vpc_config {
    security_group_ids      = [aws_security_group.eks_demo.id]
    subnet_ids              = concat(aws_subnet.pub_subs[*].id, aws_subnet.private_subs[*].id)
    endpoint_public_access  = true
    endpoint_private_access = false
  }


  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy,
    aws_route_table.public_route_table,
    aws_route_table.private_route_table,
  ]

  tags = map(
    "Name", "EKSDemoCluster",
    "terraform", "true",
  )
}

resource "aws_eks_node_group" "group_a" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = "eks-demo-ng-public"
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = aws_subnet.pub_subs[*].id
  instance_types  = ["t3.medium"]
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_group_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_access,
  ]

  tags = map(
    "Name", "EKSDemoNodeGroupPublic",
    "terraform", "true",
  )
}

resource "aws_eks_node_group" "group_b" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = "eks-demo-ng-private"
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = aws_subnet.private_subs[*].id
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_group_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_access,
  ]

  tags = map(
    "Name", "EKSDemoNodeGroupPrivate",
    "terraform", "true",
  )
}
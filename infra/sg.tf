resource "aws_security_group" "eks_demo" {
  name        = "eks_cluster_sg"
  description = "Backend node communication"
  vpc_id      = aws_vpc.eks_demo.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-demo-sg"
  }
}

resource "aws_security_group_rule" "eks_public_https_ingress" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Access to the cluster"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_demo.id
  to_port           = 443
  type              = "ingress"
}

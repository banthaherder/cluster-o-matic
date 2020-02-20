# EKS Cluster IAM Resources
resource "aws_iam_role" "eks_cluster_role" {
  name = "EKSCluster"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# EKS Node Group IAM Resources
resource "aws_iam_role" "node_group_role" {
  name = "EKSNodeGroup"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks_node_group_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group_role.name
}

# Optional: used for container images within ECR
resource "aws_iam_role_policy_attachment" "eks_ecr_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group_role.name
}

# Allows the node group role to assume the EKS Demo pathed roles
resource "aws_iam_policy" "kaim_role_assumes" {
  name = "KIAMAssumeRoles"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "arn:aws:iam::${var.account_id}:role/EKSDemo/kiam/*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "kiam_role_assume" {
  policy_arn = aws_iam_policy.kaim_role_assumes.arn
  role       = aws_iam_role.node_group_role.name
}

# KIAM Role for cert-manager
resource "aws_iam_role" "kiam_node_role_cert_manager" {
  name               = "EKSKiamCertManger"
  path               = "/EKSDemo/kiam/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.node_group_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "cert_manager_policy" {
  name        = "KIAMCertManagerPolicy"
  description = "Used to enable the cert-manager service to perform ACME DNS validation"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "route53:GetChange",
            "Resource": "arn:aws:route53:::change/*"
        },
        {
            "Effect": "Allow",
            "Action": [
              "route53:ChangeResourceRecordSets",
              "route53:ListResourceRecordSets"
            ],
            "Resource": "arn:aws:route53:::hostedzone/*"
        },
        {
            "Effect": "Allow",
            "Action": "route53:ListHostedZonesByName",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "kiam_cert_manager" {
  policy_arn = aws_iam_policy.cert_manager_policy.arn
  role       = aws_iam_role.kiam_node_role_cert_manager.name
}

# KIAM Role for external dns
resource "aws_iam_role" "kiam_node_role_external_dns" {
  name               = "EKSKiamExternalDNS"
  path               = "/EKSDemo/kiam/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.node_group_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "external_dns_policy" {
  name        = "KIAMExternalDNSPolicy"
  description = "Used to enable the external dns service to perform dns record creation"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "kiam_external_dns" {
  policy_arn = aws_iam_policy.external_dns_policy.arn
  role       = aws_iam_role.kiam_node_role_external_dns.name
}

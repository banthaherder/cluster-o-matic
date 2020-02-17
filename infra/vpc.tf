data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "eks_demo" {
  cidr_block           = "10.101.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = map(
    "Name", "EKSDemo",
    "kubernetes.io/cluster/${var.cluster_name}", "shared",
  )
}

resource "aws_subnet" "pub_subs" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.101.${count.index}.0/24"
  vpc_id            = aws_vpc.eks_demo.id

  tags = map(
    "Name", "EKSDemoPubSub",
    "terraform", "true",
    "kubernetes.io/cluster/${var.cluster_name}", "shared",
    "kubernetes.io/role/elb", "1"
  )
  depends_on = [aws_vpc.eks_demo]
}

resource "aws_subnet" "private_subs" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.101.${count.index + 2}.0/24"
  vpc_id            = aws_vpc.eks_demo.id

  tags = map(
    "Name", "EKSDemoPrivateSub",
    "terraform", "true",
    "kubernetes.io/cluster/${var.cluster_name}", "shared",
    "kubernetes.io/role/internal-elb", "1"
  )
  depends_on = [aws_vpc.eks_demo]
}

resource "aws_eip" "nat" {
  vpc = true
  tags = map(
    "Name", "DemoEIP",
    "terraform", "true",
  )
}

resource "aws_nat_gateway" "routable_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.pub_subs[0].id

  tags = map(
    "Name", "DemoNAT",
    "terraform", "true",
  )
  depends_on = [aws_internet_gateway.eks_demo]
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.eks_demo.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.routable_gw.id
  }

  tags = map(
    "Name", "DemoRouteTableForPrivateSubnet",
    "terraform", "true",
  )

  depends_on = [
    aws_subnet.private_subs,
    aws_nat_gateway.routable_gw
  ]
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = 2
  subnet_id      = aws_subnet.private_subs["${count.index}"].id
  route_table_id = aws_route_table.private_route_table.id

  depends_on = [
    aws_subnet.private_subs,
  ]
}

resource "aws_internet_gateway" "eks_demo" {
  vpc_id = aws_vpc.eks_demo.id

  tags = map(
    "Name", "DemoIGW",
    "terraform", "true",
  )
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.eks_demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_demo.id
  }

  tags = map(
    "Name", "DemoRouteTableForPublicSubnet",
    "terraform", "true",
  )
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = 2
  subnet_id      = aws_subnet.pub_subs["${count.index}"].id
  route_table_id = aws_route_table.public_route_table.id

  depends_on = [
    aws_subnet.pub_subs,
  ]
}
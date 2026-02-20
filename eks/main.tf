############################
# Provider
############################
provider "aws" {
  region = "us-west-2"
}

############################
# VPC
############################
resource "aws_vpc" "DevOpsDiaries_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "DevOpsDiaries_vpc"
  }
}

############################
# Subnets (2 public subnets)
############################
resource "aws_subnet" "DevOpsDiaries_subnet" {
  count  = 2
  vpc_id = aws_vpc.DevOpsDiaries_vpc.id

  cidr_block = cidrsubnet(aws_vpc.DevOpsDiaries_vpc.cidr_block, 8, count.index)
  availability_zone = element(
    ["us-west-2a", "us-west-2b"],
    count.index
  )

  map_public_ip_on_launch = true

  tags = {
    Name = "DevOpsDiaries_subnet-${count.index}"
  }
}

############################
# Internet Gateway
############################
resource "aws_internet_gateway" "DevOpsDiaries_igw" {
  vpc_id = aws_vpc.DevOpsDiaries_vpc.id

  tags = {
    Name = "DevOpsDiaries_igw"
  }
}

############################
# Route Table
############################
resource "aws_route_table" "DevOpsDiaries_rt" {
  vpc_id = aws_vpc.DevOpsDiaries_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.DevOpsDiaries_igw.id
  }

  tags = {
    Name = "DevOpsDiaries_route_table"
  }
}

############################
# Route Table Association
############################
resource "aws_route_table_association" "DevOpsDiaries_rt_assoc" {
  count          = 2
  subnet_id      = aws_subnet.DevOpsDiaries_subnet[count.index].id
  route_table_id = aws_route_table.DevOpsDiaries_rt.id
}

############################
# Security Groups
############################

# EKS Cluster Security Group
resource "aws_security_group" "DevOpsDiaries_cluster_sg" {
  vpc_id = aws_vpc.DevOpsDiaries_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DevOpsDiaries-cluster-sg"
  }
}

# Worker Node Security Group
resource "aws_security_group" "DevOpsDiaries_node_sg" {
  vpc_id = aws_vpc.DevOpsDiaries_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DevOpsDiaries-node-sg"
  }
}

############################
# IAM Role - EKS Cluster
############################
resource "aws_iam_role" "DevOpsDiaries_eks_cluster_role" {
  name = "DevOpsDiaries_eks_cluster_role"

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

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.DevOpsDiaries_eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

############################
# IAM Role - Worker Nodes
############################
resource "aws_iam_role" "DevOpsDiaries_eks_node_role" {
  name = "DevOpsDiaries_eks_node_role"

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

resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  role       = aws_iam_role.DevOpsDiaries_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  role       = aws_iam_role.DevOpsDiaries_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_registry_policy" {
  role       = aws_iam_role.DevOpsDiaries_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

############################
# EKS Cluster
############################
resource "aws_eks_cluster" "DevOpsDiaries" {
  name     = "DevOpsDiaries-cluster"
  role_arn = aws_iam_role.DevOpsDiaries_eks_cluster_role.arn

  vpc_config {
    subnet_ids         = aws_subnet.DevOpsDiaries_subnet[*].id
    security_group_ids = [aws_security_group.DevOpsDiaries_cluster_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]
}

############################
# EKS Node Group
############################
resource "aws_eks_node_group" "DevOpsDiaries" {
  cluster_name    = aws_eks_cluster.DevOpsDiaries.name
  node_group_name = "DevOpsDiaries-node-group"
  node_role_arn   = aws_iam_role.DevOpsDiaries_eks_node_role.arn

  subnet_ids = aws_subnet.DevOpsDiaries_subnet[*].id

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 3
  }

  instance_types = ["t2.medium"]

  remote_access {
    ec2_ssh_key               = var.ssh_key_name
    source_security_group_ids = [aws_security_group.DevOpsDiaries_node_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_registry_policy
  ]
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_vpc" "site_a_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "site-a-vpc"
  }
}

# 2. Internet Gateway
resource "aws_internet_gateway" "site_a_igw" {
  vpc_id = aws_vpc.site_a_vpc.id

  tags = {
    Name = "site-a-igw"
  }
}

# 3. Public Subnets - 2 AZ me (Highly Available ke liye)
resource "aws_subnet" "site_a_public_1a" {
  vpc_id                  = aws_vpc.site_a_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "site-a-public-1a"
  }
}

resource "aws_subnet" "site_a_public_1b" {
  vpc_id                  = aws_vpc.site_a_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "site-a-public-1b"
  }
}

# 4. Private Subnets - 2 AZ me
resource "aws_subnet" "site_a_private_1a" {
  vpc_id            = aws_vpc.site_a_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "site-a-private-1a"
  }
}

resource "aws_subnet" "site_a_private_1b" {
  vpc_id            = aws_vpc.site_a_vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "site-a-private-1b"
  }
}

# 5. NAT Gateway ke liye Elastic IP
resource "aws_eip" "site_a_nat_eip" {
  domain = "vpc"

  tags = {
    Name = "site-a-nat-eip"
  }
}

resource "aws_nat_gateway" "site_a_nat" {
  allocation_id = aws_eip.site_a_nat_eip.id
  subnet_id     = aws_subnet.site_a_public_1a.id

  tags = {
    Name = "site-a-nat"
  }
}

# 6. Route Tables
resource "aws_route_table" "site_a_public_rt" {
  vpc_id = aws_vpc.site_a_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.site_a_igw.id
  }

  tags = {
    Name = "site-a-public-rt"
  }
}

resource "aws_route_table" "site_a_private_rt" {
  vpc_id = aws_vpc.site_a_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.site_a_nat.id
  }

  tags = {
    Name = "site-a-private-rt"
  }
}

resource "aws_route_table_association" "site_a_pub_1a" {
  subnet_id      = aws_subnet.site_a_public_1a.id
  route_table_id = aws_route_table.site_a_public_rt.id
}

resource "aws_route_table_association" "site_a_pub_1b" {
  subnet_id      = aws_subnet.site_a_public_1b.id
  route_table_id = aws_route_table.site_a_public_rt.id
}

resource "aws_route_table_association" "site_a_priv_1a" {
  subnet_id      = aws_subnet.site_a_private_1a.id
  route_table_id = aws_route_table.site_a_private_rt.id
}

resource "aws_route_table_association" "site_a_priv_1b" {
  subnet_id      = aws_subnet.site_a_private_1b.id
  route_table_id = aws_route_table.site_a_private_rt.id
}
# ============ SITE-B - us-west-2 ============

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

resource "aws_vpc" "site_b_vpc" {
  provider             = aws.west
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "site-b-vpc" }
}

resource "aws_internet_gateway" "site_b_igw" {
  provider = aws.west
  vpc_id   = aws_vpc.site_b_vpc.id
  tags     = { Name = "site-b-igw" }
}

resource "aws_subnet" "site_b_public_2a" {
  provider                = aws.west
  vpc_id                  = aws_vpc.site_b_vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags                    = { Name = "site-b-public-2a" }
}

resource "aws_subnet" "site_b_public_2b" {
  provider                = aws.west
  vpc_id                  = aws_vpc.site_b_vpc.id
  cidr_block              = "10.1.2.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
  tags                    = { Name = "site-b-public-2b" }
}

resource "aws_subnet" "site_b_private_2a" {
  provider          = aws.west
  vpc_id            = aws_vpc.site_b_vpc.id
  cidr_block        = "10.1.11.0/24"
  availability_zone = "us-west-2a"
  tags              = { Name = "site-b-private-2a" }
}

resource "aws_subnet" "site_b_private_2b" {
  provider          = aws.west
  vpc_id            = aws_vpc.site_b_vpc.id
  cidr_block        = "10.1.12.0/24"
  availability_zone = "us-west-2b"
  tags              = { Name = "site-b-private-2b" }
}

resource "aws_eip" "site_b_nat_eip" {
  provider = aws.west
  domain   = "vpc"
  tags     = { Name = "site-b-nat-eip" }
}

resource "aws_nat_gateway" "site_b_nat" {
  provider      = aws.west
  allocation_id = aws_eip.site_b_nat_eip.id
  subnet_id     = aws_subnet.site_b_public_2a.id
  tags          = { Name = "site-b-nat" }
}

resource "aws_route_table" "site_b_public_rt" {
  provider = aws.west
  vpc_id   = aws_vpc.site_b_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.site_b_igw.id
  }
  tags = { Name = "site-b-public-rt" }
}

resource "aws_route_table" "site_b_private_rt" {
  provider = aws.west
  vpc_id   = aws_vpc.site_b_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.site_b_nat.id
  }
  tags = { Name = "site-b-private-rt" }
}

resource "aws_route_table_association" "site_b_pub_2a" {
  provider       = aws.west
  subnet_id      = aws_subnet.site_b_public_2a.id
  route_table_id = aws_route_table.site_b_public_rt.id
}

resource "aws_route_table_association" "site_b_pub_2b" {
  provider       = aws.west
  subnet_id      = aws_subnet.site_b_public_2b.id
  route_table_id = aws_route_table.site_b_public_rt.id
}

resource "aws_route_table_association" "site_b_priv_2a" {
  provider       = aws.west
  subnet_id      = aws_subnet.site_b_private_2a.id
  route_table_id = aws_route_table.site_b_private_rt.id
}

resource "aws_route_table_association" "site_b_priv_2b" {
  provider       = aws.west
  subnet_id      = aws_subnet.site_b_private_2b.id
  route_table_id = aws_route_table.site_b_private_rt.id
}
# ============ VPC PEERING Site-A <-> Site-B ============

resource "aws_vpc_peering_connection" "site_a_to_b" {
  vpc_id      = aws_vpc.site_a_vpc.id
  peer_vpc_id = aws_vpc.site_b_vpc.id
  peer_region = "us-west-2"
  auto_accept = false

  tags = { Name = "site-a-to-site-b" }
}

resource "aws_vpc_peering_connection_accepter" "site_b_accept" {
  provider                  = aws.west
  vpc_peering_connection_id = aws_vpc_peering_connection.site_a_to_b.id
  auto_accept               = true

  tags = { Name = "site-a-to-site-b" }
}

# Site-A ke Route Tables me Site-B ka rasta
resource "aws_route" "site_a_to_b_public" {
  route_table_id            = aws_route_table.site_a_public_rt.id
  destination_cidr_block    = "10.1.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.site_a_to_b.id
}

resource "aws_route" "site_a_to_b_private" {
  route_table_id            = aws_route_table.site_a_private_rt.id
  destination_cidr_block    = "10.1.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.site_a_to_b.id
}

# Site-B ke Route Tables me Site-A ka rasta
resource "aws_route" "site_b_to_a_public" {
  provider                  = aws.west
  route_table_id            = aws_route_table.site_b_public_rt.id
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.site_a_to_b.id
}

resource "aws_route" "site_b_to_a_private" {
  provider                  = aws.west
  route_table_id            = aws_route_table.site_b_private_rt.id
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.site_a_to_b.id
}
# ============ EKS - Site-A Kubernetes ============

resource "aws_iam_role" "site_a_eks_cluster_role" {
  name = "site-a-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "site_a_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.site_a_eks_cluster_role.name
}

resource "aws_iam_role" "site_a_eks_node_role" {
  name = "site-a-eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "site_a_node_worker" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.site_a_eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "site_a_node_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.site_a_eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "site_a_node_registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.site_a_eks_node_role.name
}

resource "aws_eks_cluster" "site_a_cluster" {
  name     = "site-a-cluster"
  version  = "1.32"
  role_arn = aws_iam_role.site_a_eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.site_a_private_1a.id,
      aws_subnet.site_a_private_1b.id,
      aws_subnet.site_a_public_1a.id,
      aws_subnet.site_a_public_1b.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.site_a_eks_cluster_policy]
}

resource "aws_eks_node_group" "site_a_nodes" {
  cluster_name    = aws_eks_cluster.site_a_cluster.name
  node_group_name = "site-a-nodes"
  node_role_arn   = aws_iam_role.site_a_eks_node_role.arn
  subnet_ids = [
    aws_subnet.site_a_private_1a.id,
    aws_subnet.site_a_private_1b.id
  ]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.site_a_node_worker,
    aws_iam_role_policy_attachment.site_a_node_cni,
    aws_iam_role_policy_attachment.site_a_node_registry
  ]
}
# ================================
# SITE B - EKS IAM ROLES
# ================================

resource "aws_iam_role" "site_b_eks_cluster_role" {
  provider = aws.west
  name     = "site-b-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "site_b_eks_cluster_policy" {
  provider   = aws.west
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.site_b_eks_cluster_role.name
}

resource "aws_iam_role" "site_b_node_role" {
  provider = aws.west
  name     = "site-b-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "site_b_node_worker" {
  provider   = aws.west
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.site_b_node_role.name
}

resource "aws_iam_role_policy_attachment" "site_b_node_cni" {
  provider   = aws.west
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.site_b_node_role.name
}

resource "aws_iam_role_policy_attachment" "site_b_node_registry" {
  provider   = aws.west
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.site_b_node_role.name
}

# ================================
# SITE B - EKS CLUSTER
# ================================

resource "aws_eks_cluster" "site_b_cluster" {
  provider = aws.west
  name     = "site-b-cluster"
  role_arn = aws_iam_role.site_b_eks_cluster_role.arn
  version  = "1.30"

  vpc_config {
    subnet_ids = [
      aws_subnet.site_b_private_2a.id,
      aws_subnet.site_b_private_2b.id,
      aws_subnet.site_b_public_2a.id,
      aws_subnet.site_b_public_2b.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.site_b_eks_cluster_policy
  ]
}

resource "aws_eks_node_group" "site_b_nodes" {
  provider        = aws.west
  cluster_name    = aws_eks_cluster.site_b_cluster.name
  node_group_name = "site-b-nodes"
  node_role_arn   = aws_iam_role.site_b_node_role.arn

  subnet_ids = [
    aws_subnet.site_b_private_2a.id,
    aws_subnet.site_b_private_2b.id
  ]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.site_b_node_worker,
    aws_iam_role_policy_attachment.site_b_node_cni,
    aws_iam_role_policy_attachment.site_b_node_registry
  ]
}
# 1. VPC : ton réseau privé AWS
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = { Name = "drakkar-vpc" }
}

# 2. Subnets publics (2 zones pour haute dispo)
resource "aws_subnet" "public" {
  for_each               = zipmap(var.availability_zones, var.public_subnets)
  vpc_id                 = aws_vpc.main.id
  cidr_block             = each.value
  availability_zone      = each.key
  map_public_ip_on_launch = true
  tags = { Name = "drakkar-subnet-${each.key}" }
}

# 3. Internet Gateway : la "box" qui connecte ton VPC à Internet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "drakkar-igw" }
}

# 4. Route Table publique : dit "tout ce qui va vers 0.0.0.0/0 passe par la gateway"
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = { Name = "drakkar-rt-public" }
}

# 5. Association : relie chaque subnet public à cette table de routage
resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# 6. IAM Role pour l’EKS : autorise le service EKS à créer et gérer des ressources
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })

  tags = { Name = "eks-cluster-role" }
}

# 7. Attachement de la policy gérée : donne les permissions minimales pour EKS
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# 8. EKS Cluster : la ressource Kubernetes managée par AWS
resource "aws_eks_cluster" "drakkar" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    # Utilise les IDs de tous les subnets publics
    subnet_ids = values(aws_subnet.public)[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = { Name = var.cluster_name }
}
# ——————————————————————————
# 9. IAM Role pour les nœuds EKS
resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-nodegroup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Name = "eks-nodegroup-role" }
}

# 10. Attache les policies nécessaires aux nœuds
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "node_ECR_ReadOnly" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# 11. Définition du Node Group
resource "aws_eks_node_group" "drakkar_nodes" {
  cluster_name    = aws_eks_cluster.drakkar.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = values(aws_subnet.public)[*].id

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  # Type d'instances (tu peux ajuster)
  instance_types = ["t3.medium"]

  tags = {
    Name = "${var.cluster_name}-node"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

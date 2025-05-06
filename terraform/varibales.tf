# Région AWS (par défaut Paris)
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-3"
}

# Emplacement du bucket S3 pour le backend
variable "backend_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
  default     = "terraform-state-cloud-drakkar"
}

# Nom de la table DynamoDB pour le lock
variable "backend_lock_table" {
  description = "DynamoDB table for Terraform state lock"
  type        = string
  default     = "terraform-locks"
}

# CIDR du VPC
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# CIDRs des subnets publics
variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# Zones de disponibilité pour chaque subnet
variable "availability_zones" {
  description = "AZs for public subnets"
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b"]
}

# Nom du cluster EKS
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "drakkar-cluster"
}

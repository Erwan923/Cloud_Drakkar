output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "IDs of the public subnets"
  value       = values(aws_subnet.public)[*].id
}

output "eks_endpoint" {
  description = "Endpoint for the EKS cluster API"
  value       = aws_eks_cluster.drakkar.endpoint
}

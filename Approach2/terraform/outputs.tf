output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.zantac_vpc.id
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS control plane"
  value       = aws_eks_cluster.zantac.endpoint
}

output "eks_cluster_certificate_authority" {
  description = "Certificate authority data for the EKS cluster"
  value       = aws_eks_cluster.zantac.certificate_authority[0].data
}

output "ecr_repository_urls" {
  description = "URLs of the ECR repositories"
  value       = { for k, v in aws_ecr_repository.app_repos : k => v.repository_url }
}

output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.oracle.endpoint
}

output "dynamodb_table_names" {
  description = "Names of the DynamoDB tables"
  value       = [aws_dynamodb_table.catalog.name, aws_dynamodb_table.customer.name]
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.zantac.name} --region ${var.aws_region}"
}
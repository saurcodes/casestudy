# outputs.tf
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.zantac_vpc.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "application_subnet_ids" {
  description = "List of application subnet IDs"
  value       = aws_subnet.application[*].id
}

output "database_subnet_ids" {
  description = "List of database subnet IDs"
  value       = aws_subnet.database[*].id
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.web.dns_name
}

output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.oracle.endpoint
}

output "web_restart_user" {
  description = "IAM user with permissions to restart web servers"
  value       = aws_iam_user.web_restart.name
}
# variables.tf
variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "application_subnets_cidr" {
  description = "CIDR blocks for application subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "database_subnets_cidr" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  default     = "ami-0c55b159cbfafe1f0"
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  default     = "t3.medium"
}

variable "key_name" {
  description = "Key pair name"
  default     = "zantac-key"
}

variable "db_username" {
  description = "Database username"
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  sensitive   = true
}
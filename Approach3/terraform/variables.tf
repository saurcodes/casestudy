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

variable "private_subnets_cidr" {
  description = "CIDR blocks for private subnets"
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

variable "db_username" {
  description = "Database username"
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  sensitive   = true
}

# Reference to dummy Lambda functions for the Step Function
resource "aws_lambda_function" "validate_order" {
  function_name    = "${var.environment}-validate-order"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  filename         = "${path.module}/../lambda/orders/validate/function.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/orders/validate/function.zip")
}

resource "aws_lambda_function" "check_inventory" {
  function_name    = "${var.environment}-check-inventory"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  filename         = "${path.module}/../lambda/inventory/check/function.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/inventory/check/function.zip")
}

resource "aws_lambda_function" "process_payment" {
  function_name    = "${var.environment}-process-payment"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  filename         = "${path.module}/../lambda/payment/process/function.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/payment/process/function.zip")
}

resource "aws_lambda_function" "fulfill_order" {
  function_name    = "${var.environment}-fulfill-order"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  filename         = "${path.module}/../lambda/orders/fulfill/function.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/orders/fulfill/function.zip")
}

resource "aws_lambda_function" "notify_customer" {
  function_name    = "${var.environment}-notify-customer"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  filename         = "${path.module}/../lambda/customer/notify/function.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/customer/notify/function.zip")
}
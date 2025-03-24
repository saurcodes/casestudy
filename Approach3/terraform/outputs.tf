output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = "${aws_api_gateway_stage.zantac_api.invoke_url}"
}

output "cognito_user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.zantac_pool.id
}

output "cognito_app_client_id" {
  description = "ID of the Cognito App Client"
  value       = aws_cognito_user_pool_client.zantac_client.id
}

output "website_url" {
  description = "URL of the S3 website"
  value       = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}

output "cloudfront_distribution_domain" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.website.domain_name
}

output "aurora_endpoint" {
  description = "Endpoint of Aurora Serverless"
  value       = aws_rds_cluster.aurora_serverless.endpoint
}

output "dynamodb_table_names" {
  description = "Names of the DynamoDB tables"
  value       = [aws_dynamodb_table.products.name, aws_dynamodb_table.customers.name, aws_dynamodb_table.stores.name]
}

output "step_function_arn" {
  description = "ARN of the Step Function"
  value       = aws_sfn_state_machine.order_processing.arn
}
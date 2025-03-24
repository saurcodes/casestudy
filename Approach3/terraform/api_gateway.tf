resource "aws_api_gateway_rest_api" "zantac_api" {
  name        = "${var.environment}-zantac-api"
  description = "Zantac API Gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name        = "${var.environment}-zantac-api"
    Environment = var.environment
  }
}

# API Gateway Resources and Methods for E-commerce
resource "aws_api_gateway_resource" "products" {
  rest_api_id = aws_api_gateway_rest_api.zantac_api.id
  parent_id   = aws_api_gateway_rest_api.zantac_api.root_resource_id
  path_part   = "products"
}

resource "aws_api_gateway_method" "get_products" {
  rest_api_id   = aws_api_gateway_rest_api.zantac_api.id
  resource_id   = aws_api_gateway_resource.products.id
  http_method   = "GET"
  authorization_type = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "get_products_integration" {
  rest_api_id             = aws_api_gateway_rest_api.zantac_api.id
  resource_id             = aws_api_gateway_resource.products.id
  http_method             = aws_api_gateway_method.get_products.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.ecommerce_products.invoke_arn
}

resource "aws_api_gateway_authorizer" "cognito" {
  name            = "cognito-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.zantac_api.id
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [aws_cognito_user_pool.zantac_pool.arn]
}

resource "aws_api_gateway_deployment" "zantac_api" {
  depends_on = [
    aws_api_gateway_integration.get_products_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.zantac_api.id
  stage_name  = var.environment

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "zantac_api" {
  deployment_id = aws_api_gateway_deployment.zantac_api.id
  rest_api_id   = aws_api_gateway_rest_api.zantac_api.id
  stage_name    = var.environment

  xray_tracing_enabled = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format          = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"
  }
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${aws_api_gateway_rest_api.zantac_api.name}"
  retention_in_days = 30
}
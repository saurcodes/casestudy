resource "aws_cognito_user_pool" "zantac_pool" {
  name = "${var.environment}-zantac-user-pool"
  
  username_attributes      = ["email"]
  auto_verify_attributes   = ["email"]
  
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
  
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "Your verification code"
    email_message        = "Your verification code is {####}"
  }
  
  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }
  
  schema {
    name                = "name"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }
  
  tags = {
    Name        = "${var.environment}-zantac-user-pool"
    Environment = var.environment
  }
}

resource "aws_cognito_user_pool_client" "zantac_client" {
  name                         = "${var.environment}-zantac-client"
  user_pool_id                 = aws_cognito_user_pool.zantac_pool.id
  generate_secret              = true
  refresh_token_validity       = 30
  prevent_user_existence_errors = "ENABLED"
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]
}

resource "aws_cognito_identity_pool" "zantac_identity_pool" {
  identity_pool_name               = "${var.environment}ZantacIdentityPool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.zantac_client.id
    provider_name           = "cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.zantac_pool.id}"
    server_side_token_check = false
  }

  tags = {
    Name        = "${var.environment}-zantac-identity-pool"
    Environment = var.environment
  }
}
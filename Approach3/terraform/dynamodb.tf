resource "aws_dynamodb_table" "products" {
  name         = "${var.environment}-products"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "category"
    type = "S"
  }

  global_secondary_index {
    name               = "CategoryIndex"
    hash_key           = "category"
    projection_type    = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = "${var.environment}-products"
    Environment = var.environment
  }
}

resource "aws_dynamodb_table" "customers" {
  name         = "${var.environment}-customers"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  global_secondary_index {
    name               = "EmailIndex"
    hash_key           = "email"
    projection_type    = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = "${var.environment}-customers"
    Environment = var.environment
  }
}

resource "aws_dynamodb_table" "stores" {
  name         = "${var.environment}-stores"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "region"
    type = "S"
  }

  global_secondary_index {
    name               = "RegionIndex"
    hash_key           = "region"
    projection_type    = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = "${var.environment}-stores"
    Environment = var.environment
  }
}
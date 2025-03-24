resource "aws_dynamodb_table" "catalog" {
  name         = "${var.environment}-catalog"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ProductId"

  attribute {
    name = "ProductId"
    type = "S"
  }

  attribute {
    name = "Category"
    type = "S"
  }

  global_secondary_index {
    name               = "CategoryIndex"
    hash_key           = "Category"
    projection_type    = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = "${var.environment}-catalog"
    Environment = var.environment
  }
}

resource "aws_dynamodb_table" "customer" {
  name         = "${var.environment}-customer"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "CustomerId"

  attribute {
    name = "CustomerId"
    type = "S"
  }

  attribute {
    name = "Email"
    type = "S"
  }

  global_secondary_index {
    name               = "EmailIndex"
    hash_key           = "Email"
    projection_type    = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = "${var.environment}-customer"
    Environment = var.environment
  }
}
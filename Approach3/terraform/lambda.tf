resource "aws_lambda_function" "ecommerce_products" {
  function_name    = "${var.environment}-ecommerce-products"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  filename         = "${path.module}/../lambda/ecommerce/products/function.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/ecommerce/products/function.zip")
  timeout          = 30
  memory_size      = 256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.products.name
    }
  }

  tracing_config {
    mode = "Active"
  }

  tags = {
    Name        = "${var.environment}-ecommerce-products"
    Environment = var.environment
  }
}

resource "aws_lambda_permission" "ecommerce_products_api" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ecommerce_products.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.zantac_api.execution_arn}/*/*"
}

resource "aws_lambda_function" "retail_stores" {
  function_name    = "${var.environment}-retail-stores"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  filename         = "${path.module}/../lambda/retail/stores/function.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/retail/stores/function.zip")
  timeout          = 30
  memory_size      = 256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.stores.name
    }
  }

  tracing_config {
    mode = "Active"
  }

  tags = {
    Name        = "${var.environment}-retail-stores"
    Environment = var.environment
  }
}

resource "aws_lambda_function" "customer_management" {
  function_name    = "${var.environment}-customer-management"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  filename         = "${path.module}/../lambda/customer/management/function.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/customer/management/function.zip")
  timeout          = 30
  memory_size      = 256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.customers.name
    }
  }

  tracing_config {
    mode = "Active"
  }

  tags = {
    Name        = "${var.environment}-customer-management"
    Environment = var.environment
  }
}

# Step Functions for order processing
resource "aws_sfn_state_machine" "order_processing" {
  name     = "${var.environment}-order-processing"
  role_arn = aws_iam_role.step_function_role.arn

  definition = <<EOF
{
  "Comment": "Order Processing Workflow",
  "StartAt": "ValidateOrder",
  "States": {
    "ValidateOrder": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.validate_order.arn}",
      "Next": "CheckInventory"
    },
    "CheckInventory": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.check_inventory.arn}",
      "Next": "ProcessPayment"
    },
    "ProcessPayment": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.process_payment.arn}",
      "Next": "FulfillOrder"
    },
    "FulfillOrder": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.fulfill_order.arn}",
      "Next": "NotifyCustomer"
    },
    "NotifyCustomer": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.notify_customer.arn}",
      "End": true
    }
  }
}
EOF

  tags = {
    Name        = "${var.environment}-order-processing"
    Environment = var.environment
  }
}
resource "aws_iam_role" "lambda_role" {
  name = "${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-lambda-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "${var.environment}-lambda-dynamodb-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Effect   = "Allow"
        Resource = [
          aws_dynamodb_table.products.arn,
          aws_dynamodb_table.customers.arn,
          aws_dynamodb_table.stores.arn,
          "${aws_dynamodb_table.products.arn}/index/*",
          "${aws_dynamodb_table.customers.arn}/index/*",
          "${aws_dynamodb_table.stores.arn}/index/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_xray" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role" "step_function_role" {
  name = "${var.environment}-step-function-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-step-function-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "step_function_lambda" {
  name = "${var.environment}-step-function-lambda-policy"
  role = aws_iam_role.step_function_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "events_role" {
  name = "${var.environment}-events-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-events-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "events_step_functions" {
  name = "${var.environment}-events-step-functions-policy"
  role = aws_iam_role.events_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "states:StartExecution"
        ]
        Effect   = "Allow"
        Resource = aws_sfn_state_machine.order_processing.arn
      }
    ]
  })
}

# Create an IAM user who can restart web server (serverless context)
resource "aws_iam_user" "web_restart" {
  name = "web-restart-user"
  
  tags = {
    Name        = "Web Restart User"
    Environment = var.environment
  }
}

resource "aws_iam_policy" "web_restart" {
  name        = "WebServerRestartPolicy"
  description = "Policy to allow restarting web server functions"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:UpdateFunctionConfiguration",
          "lambda:UpdateFunctionCode"
        ],
        Effect   = "Allow",
        Resource = [
          aws_lambda_function.ecommerce_products.arn,
          aws_lambda_function.retail_stores.arn
        ]
      },
      {
        Action = [
          "lambda:ListFunctions"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "web_restart" {
  user       = aws_iam_user.web_restart.name
  policy_arn = aws_iam_policy.web_restart.arn
}

# Security Group for Lambda VPC Access
resource "aws_security_group" "lambda" {
  name        = "${var.environment}-lambda-sg"
  description = "Security group for Lambda functions with VPC access"
  vpc_id      = aws_vpc.zantac_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-lambda-sg"
    Environment = var.environment
  }
}
# iam.tf - IAM roles and policies
resource "aws_iam_role" "web_server" {
  name = "${var.environment}-web-server-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-web-server-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "web_server" {
  name = "${var.environment}-web-server-policy"
  role = aws_iam_role.web_server.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "web_server" {
  name = "${var.environment}-web-server-profile"
  role = aws_iam_role.web_server.name
}

# Create an IAM user who can restart the web server
resource "aws_iam_user" "web_restart" {
  name = "web-restart-user"
  
  tags = {
    Name        = "Web Restart User"
    Environment = var.environment
  }
}

resource "aws_iam_policy" "web_restart" {
  name        = "WebServerRestartPolicy"
  description = "Policy to allow restarting web servers"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:RebootInstances"
        ]
        Effect   = "Allow"
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Name": "${var.environment}-web-instance"
          }
        }
      },
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "web_restart" {
  user       = aws_iam_user.web_restart.name
  policy_arn = aws_iam_policy.web_restart.arn
}
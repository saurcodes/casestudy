resource "aws_ecr_repository" "app_repos" {
  for_each = toset([
    "ecommerce",
    "retail",
    "customer",
    "backend",
    "middleware",
    "mobile-api"
  ])

  name                 = each.key
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = each.key
    Environment = var.environment
  }
}
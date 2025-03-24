resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = "S3-Website"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-Website"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "${var.environment}-zantac-cf-distribution"
    Environment = var.environment
  }
}

resource "aws_cloudfront_origin_access_identity" "website" {
  comment = "OAI for Zantac website"
}

# eventbridge.tf - EventBridge for event-driven architecture
resource "aws_cloudwatch_event_bus" "zantac" {
  name = "${var.environment}-zantac-events"
}

resource "aws_cloudwatch_event_rule" "order_created" {
  name           = "${var.environment}-order-created"
  description    = "Capture order creation events"
  event_bus_name = aws_cloudwatch_event_bus.zantac.name

  event_pattern = jsonencode({
    source      = ["com.zantac.orders"],
    detail-type = ["OrderCreated"]
  })
}

resource "aws_cloudwatch_event_target" "order_processing" {
  rule           = aws_cloudwatch_event_rule.order_created.name
  event_bus_name = aws_cloudwatch_event_bus.zantac.name
  target_id      = "OrderProcessingStateMachine"
  arn            = aws_sfn_state_machine.order_processing.arn
  role_arn       = aws_iam_role.events_role.arn
}
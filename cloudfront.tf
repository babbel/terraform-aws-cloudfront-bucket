resource "aws_cloudfront_distribution" "this" {
  comment = aws_s3_bucket.this.bucket
  enabled = true

  aliases = var.aliases

  http_version = var.http_version

  default_root_object = var.default_root_object

  origin {
    origin_id   = "S3-${aws_s3_bucket.this.bucket}"
    domain_name = aws_s3_bucket.this.bucket_domain_name

    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  default_cache_behavior {
    target_origin_id       = "S3-${aws_s3_bucket.this.bucket}"
    viewer_protocol_policy = "https-only"

    trusted_key_groups = var.trusted_key_groups == null ? null : var.trusted_key_groups[*].id

    allowed_methods = [
      "GET",
      "HEAD",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    forwarded_values {
      query_string = false

      headers = [
        "Access-Control-Request-Headers",
        "Access-Control-Request-Method",
        "Origin",
      ]

      cookies {
        forward = "none"
      }
    }

    min_ttl     = var.ttl.min
    default_ttl = var.ttl.default
    max_ttl     = var.ttl.max

    compress = true
  }

  viewer_certificate {
    acm_certificate_arn            = local.viewer_certificate.acm_certificate_arn
    cloudfront_default_certificate = local.viewer_certificate.cloudfront_default_certificate

    minimum_protocol_version = local.viewer_certificate.minimum_protocol_version
    ssl_support_method       = local.viewer_certificate.ssl_support_method
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_response

    content {
      error_caching_min_ttl = custom_error_response.error_caching_min_ttl
      error_code            = custom_error_response.error_code
      response_code         = custom_error_response.response_code
      response_page_path    = custom_error_response.response_page_path
    }
  }

  tags = var.tags
}

locals {
  default_viewer_certificate = {
    acm_certificate_arn            = null
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
    ssl_support_method             = null
  }

  acm_viewer_certificate = {
    acm_certificate_arn            = try(var.acm_certificate.arn, null)
    cloudfront_default_certificate = false
    minimum_protocol_version       = var.acm_certificate_minimum_protocol_version
    ssl_support_method             = "sni-only"
  }

  viewer_certificate = var.acm_certificate != null ? local.acm_viewer_certificate : local.default_viewer_certificate
}

resource "aws_cloudfront_origin_access_control" "this" {
  name        = aws_s3_bucket.this.bucket
  description = var.aliases != null ? join(", ", var.aliases) : aws_s3_bucket.this.bucket

  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

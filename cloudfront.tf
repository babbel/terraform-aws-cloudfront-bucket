resource "aws_cloudfront_distribution" "this" {
  comment = aws_s3_bucket.this.bucket
  enabled = true

  aliases = var.aliases

  http_version = var.http_version

  default_root_object = var.default_root_object

  web_acl_id = var.web_acl_id

  origin {
    origin_id   = local.default_s3_origin_id
    domain_name = aws_s3_bucket.this.bucket_domain_name

    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  dynamic "origin" {
    for_each = var.additional_origins

    content {
      origin_id   = origin.value.origin_id
      domain_name = origin.value.domain_name

      custom_origin_config {
        http_port              = origin.value.custom_origin_config.http_port
        https_port             = origin.value.custom_origin_config.https_port
        origin_protocol_policy = origin.value.custom_origin_config.origin_protocol_policy
        origin_ssl_protocols   = origin.value.custom_origin_config.origin_ssl_protocols
      }
    }
  }

  default_cache_behavior {
    target_origin_id       = local.default_s3_origin_id
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

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors

    content {
      path_pattern           = ordered_cache_behavior.value.path_pattern
      target_origin_id       = ordered_cache_behavior.value.target_origin_id
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy
      allowed_methods        = ordered_cache_behavior.value.allowed_methods
      cached_methods         = ordered_cache_behavior.value.cached_methods
      compress               = ordered_cache_behavior.value.compress
      cache_policy_id        = ordered_cache_behavior.value.cache_policy_id

      origin_request_policy_id   = ordered_cache_behavior.value.origin_request_policy_id
      response_headers_policy_id = ordered_cache_behavior.value.response_headers_policy_id
      trusted_key_groups         = ordered_cache_behavior.value.trusted_key_groups
    }
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
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
    }
  }

  tags = merge(var.default_tags, var.cloudfront_distribution_tags)
}

locals {
  default_s3_origin_id = "S3-${var.bucket_name}"

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

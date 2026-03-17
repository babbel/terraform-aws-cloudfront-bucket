provider "aws" {
  region = "local"
}

module "s3-bucket-with-cloudfront" {
  source = "./.."

  bucket_name = "example-with-default-cert"
}

module "s3-bucket-with-cloudfront-with-custom-cert" {
  source = "./.."

  bucket_name = "example-with-custom-cert"

  acm_certificate = {
    arn = "arn:aws:acm:eu-west-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  }

  custom_error_response = [{
    error_code            = 403
    response_page_path    = "/404.html"
    response_code         = 404
    error_caching_min_ttl = null
  }]
}

module "s3-bucket-with-cloudfront-with-cors" {
  source = "./.."

  bucket_name = "example-with-cors"

  response_headers_policy_id = "60669652-455b-4ae9-85a4-c4c02393f86c"
}

module "s3-bucket-with-cloudfront-with-path-routing" {
  source = "./.."

  bucket_name = "example-with-path-routing"

  additional_origins = [
    {
      origin_id   = "custom-edge-origin"
      domain_name = "gtm-123456.fps.goog"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  ]

  ordered_cache_behaviors = [
    {
      path_pattern               = "/edge/*"
      target_origin_id           = "custom-edge-origin"
      viewer_protocol_policy     = "https-only"
      allowed_methods            = ["GET", "HEAD", "OPTIONS"]
      cached_methods             = ["GET", "HEAD"]
      compress                   = true
      cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      origin_request_policy_id   = null
      response_headers_policy_id = null
      trusted_key_groups         = []
    }
  ]
}

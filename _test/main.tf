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

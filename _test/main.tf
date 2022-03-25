module "s3-bucket-with-cloudfront" {
  source = "./.."

  bucket_name = ""
}

module "s3-bucket-with-cloudfront-with-custom-cert" {
  source = "./.."

  bucket_name = ""

  acm_certificate = {
    arn = "arn:aws:acm:eu-west-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  }
}

variable "acm_certificate" {
  type = object({
    arn = string
  })
  default = null

  description = <<EOS
The ARN of the ACM certificate that you want to use with the CloudFront distribution.
If not specified, the default CloudFront certificate for *.cloudfront.net will be used.

This only makes sense in combination with `aliases`.
EOS
}

variable "acm_certificate_minimum_protocol_version" {
  type    = string
  default = "TLSv1.2_2021"

  description = <<EOS
The minimum protocol version for the ACM viewer certificate that you want to use with
the CloudFront distribution.
Supported protocols and ciphers are documented here:
https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html

If not specified, it defaults to `"TLSv1.2_2021"`.
EOS
}

variable "aliases" {
  type    = list(string)
  default = null

  description = <<EOS
List of custom domain which shall be served by the CloudFront distribution.

In order to serve the content via HTTPS, you need to specify an ACM certificate
with matchgin domains via `acm_certificate_arn`.
EOS
}

variable "bucket_name" {
  type = string

  description = <<EOS
Name of the S3 bucket to create.
EOS
}

variable "cloudfront_distribution_tags" {
  type    = map(string)
  default = {}

  description = <<EOS
Map of tags assigned to the CloudFront distribution created by this module. Tags in this map will override tags in `var.default_tags`.
EOS
}

variable "custom_error_response" {
  type = list(
    object({
      error_caching_min_ttl = number
      error_code            = number
      response_code         = number
      response_page_path    = string
    })
  )
  default = []

  description = <<EOS
One or more custom error response elements to be used for the CloudFront distribution.
EOS
}

variable "default_root_object" {
  type    = string
  default = null

  description = <<EOS
The default root object CloudFront is to request from the S3 bucket as root URL.
EOS
}

variable "default_tags" {
  type    = map(string)
  default = {}

  description = <<EOS
Map of tags assigned to all AWS resources created by this module.
EOS
}

variable "http_version" {
  type    = string
  default = "http2"

  description = <<EOS
Supported HTTP versions set on the CloudFront distribution.
EOS
}

variable "s3_bucket_tags" {
  type    = map(string)
  default = {}

  description = <<EOS
Map of tags assigned to the S3 bucket created by this module. Tags in this map will override tags in `var.default_tags`.
EOS
}

variable "trusted_key_groups" {
  type = list(
    object({
      id = string
    })
  )
  default = null

  description = <<EOS
List of AWS Key Groups to trust for CloudFront distribution's default cache behavior.
EOS
}

variable "ttl" {
  type = object({
    min     = number
    default = number
    max     = number
  })
  default = {
    min     = 0
    default = 86400
    max     = 31536000
  }

  description = <<EOS
The min, default and max TTLs set on the CloudFront distribution.
EOS
}

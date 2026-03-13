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

variable "additional_origins" {
  type = list(
    object({
      origin_id   = string
      domain_name = string
      custom_origin_config = object({
        http_port              = number
        https_port             = number
        origin_protocol_policy = string
        origin_ssl_protocols   = list(string)
      })
    })
  )
  default = []

  description = <<EOS
Additional non-S3 origins to attach to the CloudFront distribution.
Each origin must provide a unique `origin_id` that can be referenced by
`ordered_cache_behaviors[*].target_origin_id`.
EOS

  validation {
    condition     = length(distinct([for origin in var.additional_origins : origin.origin_id])) == length(var.additional_origins)
    error_message = "Each additional_origins.origin_id must be unique."
  }

  validation {
    condition = length([
      for origin in var.additional_origins : origin
      if !contains(["http-only", "https-only", "match-viewer"], origin.custom_origin_config.origin_protocol_policy)
    ]) == 0
    error_message = "additional_origins.custom_origin_config.origin_protocol_policy must be one of: http-only, https-only, match-viewer."
  }
}

variable "ordered_cache_behaviors" {
  type = list(
    object({
      path_pattern               = string
      target_origin_id           = string
      viewer_protocol_policy     = string
      allowed_methods            = list(string)
      cached_methods             = list(string)
      compress                   = bool
      cache_policy_id            = string
      origin_request_policy_id   = string
      response_headers_policy_id = string
      trusted_key_groups         = list(string)
    })
  )
  default = []

  description = <<EOS
Additional ordered cache behaviors for path-based routing.
For compatibility with older Terraform versions, set optional fields to `null` when unused:
`origin_request_policy_id`, `response_headers_policy_id`.
Use an empty list for `trusted_key_groups` when unused.
EOS

  validation {
    condition     = length(distinct([for behavior in var.ordered_cache_behaviors : behavior.path_pattern])) == length(var.ordered_cache_behaviors)
    error_message = "Each ordered_cache_behaviors.path_pattern must be unique."
  }

  validation {
    condition = length([
      for behavior in var.ordered_cache_behaviors : behavior
      if !can(regex("^/", behavior.path_pattern))
    ]) == 0
    error_message = "Each ordered_cache_behaviors.path_pattern must start with '/'."
  }

  validation {
    condition = length([
      for behavior in var.ordered_cache_behaviors : behavior
      if !contains(["allow-all", "https-only", "redirect-to-https"], behavior.viewer_protocol_policy)
    ]) == 0
    error_message = "ordered_cache_behaviors.viewer_protocol_policy must be one of: allow-all, https-only, redirect-to-https."
  }

  validation {
    condition = length([
      for behavior in var.ordered_cache_behaviors : behavior
      if length(setsubtract(toset(behavior.cached_methods), toset(behavior.allowed_methods))) > 0
    ]) == 0
    error_message = "Each ordered_cache_behaviors.cached_methods must be a subset of allowed_methods."
  }
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

variable "web_acl_id" {
  type    = string
  default = null

  description = <<EOS
The ARN of the WAFv2 Web ACL to associate with the CloudFront distribution.
This enables AWS WAF protection for the distribution.

Example:
  web_acl_id = aws_wafv2_web_acl.example.arn
EOS
}

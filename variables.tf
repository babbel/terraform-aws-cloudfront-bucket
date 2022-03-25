variable "acm_certificate_arn" {
  type    = string
  default = null

  description = <<EOS
The ARN of the ACM certificate that you want to use with the CloudFront distribution.
If not specified, the default CloudFront certificate for *.cloudfront.net will be used.

This only makes sense in combination with `aliases`.
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

  description = "Name of the S3 bucket to create"
}

variable "tags" {
  type    = map(string)
  default = {}

  description = "Tags to be assigned to the S3 bucket and the CloudFront distribution"
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

  description = "The min, default and max TTLs set on the CloudFront distribution"
}

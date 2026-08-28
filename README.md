# terraform-aws-cloudfront-bucket

This modules creates an S3 bucket with a CloudFront distribution in front.
The integration between CloudFront and the S3 bucket is protected,
and the bucket is set up to be not directly accessible, only via the CDN.

## Example

```tf
module "cloudfront-bucket-example" {
  source  = "babbel/cloudfront-bucket/aws"
  version = "~> 2.0"

  bucket_name = "foo"
}
```

## Example with WAF

```tf
resource "aws_wafv2_web_acl" "example" {
  provider = aws.global

  name        = "example-waf"
  description = "WAF for example CloudFront distribution"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # Add AWS Managed Rule Groups here
  # ...

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "example"
    sampled_requests_enabled   = true
  }
}

module "cloudfront-bucket-example" {
  source  = "babbel/cloudfront-bucket/aws"
  version = "~> 2.1"

  bucket_name = "foo"
  web_acl_id  = aws_wafv2_web_acl.example.arn
}
```

## Example with path-based routing to a custom origin

```tf
data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

module "cloudfront-bucket-example" {
  source  = "babbel/cloudfront-bucket/aws"
  version = "~> 2.2"

  bucket_name = "foo"

  additional_origins = [
    {
      origin_id   = "edge-origin"
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
      target_origin_id           = "edge-origin"
      viewer_protocol_policy     = "https-only"
      allowed_methods            = ["GET", "HEAD", "OPTIONS"]
      cached_methods             = ["GET", "HEAD"]
      compress                   = true
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id   = "00000000-0000-0000-0000-000000000000"
      response_headers_policy_id = null
      trusted_key_groups         = []
    }
  ]
}
```

## Example with additional bucket policy statements

The module manages the bucket policy that grants its CloudFront distribution read access.
A bucket has exactly one policy, so declaring a second `aws_s3_bucket_policy` for the same
bucket outside of the module makes the two resources overwrite each other on every apply.
Pass extra statements in instead:

```tf
data "aws_iam_policy_document" "example-write" {
  statement {
    sid = "example-write"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::123456789012:root"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${module.cloudfront-bucket-example.bucket.arn}/*"]
  }
}

module "cloudfront-bucket-example" {
  source  = "babbel/cloudfront-bucket/aws"
  version = "~> 2.2"

  bucket_name = "foo"

  additional_bucket_policy_documents = [
    data.aws_iam_policy_document.example-write.json
  ]
}
```

## New optional inputs

- `additional_bucket_policy_documents`: Merges extra statements into the bucket policy managed by the module.
- `additional_origins`: Adds non-S3 origins to the CloudFront distribution.
- `ordered_cache_behaviors`: Adds path-based routing to default S3 or additional origins.

When omitted, these inputs default to `[]`, so existing consumers keep the same behavior.

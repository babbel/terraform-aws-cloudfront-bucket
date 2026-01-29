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

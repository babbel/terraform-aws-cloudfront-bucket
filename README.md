# terraform-aws-cloudfront-bucket

This modules creates an S3 bucket with a CloudFront distribution in front.
The integration between CloudFront and the S3 bucket is protected,
and the bucket is set up to be not directly accessible, only via the CDN.

## Example

```tf
module "cloudfront-bucket-example" {
  source  = "babbel/cloudfront-bucket/aws"
  version = "~> 1.0"

  bucket_name = "foo"
}
```

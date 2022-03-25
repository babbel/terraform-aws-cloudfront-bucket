# terraform-aws-cloudfront-bucket

This modules creates an S3 bucket with a CloudFront distribution in front.

## Example

```tf
module "cloudfront-bucket-example" {
  source  = "babbel/cloudfront-bucket/aws"
  version = "~> 1.0"

  bucket_name = "foo"

  tags = {
    environment = "production"
  }
}
```

output "bucket" {
  value = aws_s3_bucket.this

  description = "The created bucket"
}

output "cloudfront_distribution" {
  value = aws_cloudfront_distribution.this

  description = "The CloudFront distribution connected with the created bucket"
}

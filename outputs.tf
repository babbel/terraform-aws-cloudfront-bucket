output "bucket" {
  value = aws_s3_bucket.this

  description = "The created bucket"
}

output "bucket_fullaccess_policy_document" {
  value = data.aws_iam_policy_document.fullaccess.json

  description = "IAM policy document granting full access to the created bucket"
}

output "cloudfront_distribution" {
  value = aws_cloudfront_distribution.this

  description = "The CloudFront distribution connected with the created bucket"
}

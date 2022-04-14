resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = var.tags
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {

    principals {
      type        = "CanonicalUser"
      identifiers = [aws_cloudfront_origin_access_identity.this.s3_canonical_user_id]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.bucket
  policy = data.aws_iam_policy_document.bucket_policy.json
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = var.tags
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.this.iam_arn]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.bucket
  policy = data.aws_iam_policy_document.bucket_policy.json
}

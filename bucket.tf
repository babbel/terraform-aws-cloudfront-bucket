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

  lifecycle {
    ignore_changes = [
      # When setting a "CanonicalUser" in an S3 bucket policy,
      # S3 changes the policy into something like
      # "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ...",
      # sometimes with spaces and sometimes with underscores as separators after
      # "user/".
      #
      # We also cannot set that IAM user directly, because we cannot know whether
      # a bucket accepts an IAM user with spaces or with underscores.
      #
      # https://github.com/terraform-providers/terraform-provider-aws/issues/10158
      #
      # However, we can always set the documented way using "CanonicalUser",
      # even if S3 changes value into the IAM user later on.
      #
      # We just need to ignore changes on the policy when refreshing
      # the Terraform state from the S3 API.
      #
      policy,
    ]
  }
}

data "aws_iam_policy_document" "fullaccess" {
  statement {
    actions   = ["s3:List*", "s3:Get*"]
    resources = [aws_s3_bucket.this.arn]
  }

  statement {
    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }
}

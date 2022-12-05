# logging bucket
resource "aws_s3_bucket" "logs" {
  bucket = "${var.site}-site-logs"
  acl = "log-delivery-write"
  force_destroy = "true"
}

# site bucket
resource "aws_s3_bucket" "site" {
  bucket        = var.site
  acl           = "public-read"
  force_destroy = "true"

  tags = {
    Purpose     = "TE-Onboarding"
    Environment = "Dev"
  }

  logging {
    target_bucket = aws_s3_bucket.logs.bucket
    # target_prefix = "www.${var.site}/"
  }

  website {
    index_document = "index.html"
    #redirect_all_requests_to = "https://${var.site}"
  }

  versioning {
    enabled = true
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Slalom POC"
}

data "aws_iam_policy_document" "site_read" {
  statement {
    sid       = "AllowPublicRead"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "site_read" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.site_read.json
}

# usually terraform is not recommended for putting objects
# terrafrom should only be used for configuration management
resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.site.bucket
  key    = "index.html"
  source = "site/index.html"
  content_type = "text/html"
}
resource "aws_s3_bucket_object" "error" {
  bucket = aws_s3_bucket.site.bucket
  key    = "404.html"
  source = "site/404.html"
  content_type = "text/html"
}
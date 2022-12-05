#Find a certificate that is issued
# data "aws_acm_certificate" "cert" {
#   domain   = "*.slalompoc.com"
#   statuses = ["ISSUED"]
# }



resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = "${var.site}.s3.${var.region}.amazonaws.com"
    origin_id   = var.origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.origin_id
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # aliases = [aws_s3_bucket.site.id]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# resource "aws_route53_zone" "zone" {
#   name = aws_s3_bucket.site.id
# }

# resource "aws_route53_record" "www" {
#   zone_id = aws_route53_zone.zone.zone_id
#   name    = aws_s3_bucket.site.id
#   type    = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.distribution.domain_name
#     zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
#     evaluate_target_health = false
#   }
#   depends_on = [
#     aws_cloudfront_distribution.distribution
#   ]
# }
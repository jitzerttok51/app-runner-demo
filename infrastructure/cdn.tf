resource "aws_cloudfront_origin_access_control" "cloudfront_s3_oac" {
  name                              = "CloudFront S3 OAC"
  description                       = "Cloud Front S3 OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_identity" "ads-storage-access" {
  comment = "ads-storage-access"
}

data "aws_iam_policy_document" "ads-storage-policy" {
  statement {
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.ads-storage.arn}/*",
      "${aws_s3_bucket.ads-storage.arn}/ads/*"
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.ads-storage-access.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.ads-storage.id
  policy = data.aws_iam_policy_document.ads-storage-policy.json
}

resource "aws_cloudfront_distribution" "my_distrib" {

  origin {
    domain_name = aws_s3_bucket.ads-storage.bucket_regional_domain_name
    origin_id   = "s3Primary"
    # origin_path = "/ads"

    # origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_s3_oac.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.ads-storage-access.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3Primary"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  enabled = true
}

output "cdn-url" {
  value = "https://${aws_cloudfront_distribution.my_distrib.domain_name}"
}
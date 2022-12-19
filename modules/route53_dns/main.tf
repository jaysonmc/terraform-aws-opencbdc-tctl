
data "aws_route53_zone" "base_domain" {
  name = var.dns_base_domain
}

# ACM
resource "aws_acm_certificate" "domain_cert" {
  domain_name               = var.dns_base_domain
  subject_alternative_names = ["*.${var.dns_base_domain}"]
  validation_method         = "DNS"

  tags = merge(
    {
      Name = var.dns_base_domain
    },
    var.tags
  )
}

resource "aws_route53_record" "domain_cert_validation_dns" {
  name    = tolist(aws_acm_certificate.domain_cert.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.domain_cert.domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.base_domain.id
  records = [tolist(aws_acm_certificate.domain_cert.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "domain_cert_validation" {
  certificate_arn         = aws_acm_certificate.domain_cert.arn
  validation_record_fqdns = [aws_route53_record.domain_cert_validation_dns.fqdn]
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "jaysosmc-opencbdc-react-build.s3.us-east-1.amazonaws.com"
}

data "aws_s3_bucket" "build_bucket" {
  bucket = "${var.s3_build_bucket}"
}

locals {
  s3_origin_id = "opencbdcS3OriginID"
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name               = data.aws_s3_bucket.build_bucket.bucket_regional_domain_name
    #origin_access_control_id  = aws_cloudfront_origin_access_control.default.id
    origin_id                 = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  custom_error_response {
    error_code          = 403
    response_code       = 200
    response_page_path  = "index.html"  
  }

  # If using route53 aliases for DNS we need to declare it here too, otherwise we'll get 403s.
  aliases = ["test-controller.${var.dns_base_domain}"] // TO-DO pull test-controller from var instead of hard coding

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.s3_build_bucket}"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  # The cheapest priceclass
  price_class = "PriceClass_100"

  # This is required to be specified even if it's not used.
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA"]
    }
  }

  viewer_certificate {
    acm_certificate_arn       = "arn:aws:acm:us-east-1:252265768975:certificate/76b4657f-1a64-4588-aeab-e6a8fdc3d6df" // TO-DO remove hard coded ARN
    ssl_support_method        = "sni-only"
    minimum_protocol_version  = "TLSv1"
  }
  
  depends_on = [
    data.aws_s3_bucket.build_bucket
  ]
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.build_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "mybucket" {
  bucket = data.aws_s3_bucket.build_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_s3_bucket_public_access_block" "mybucket" {
  bucket = data.aws_s3_bucket.build_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  //ignore_public_acls      = true
  //restrict_public_buckets = true
}


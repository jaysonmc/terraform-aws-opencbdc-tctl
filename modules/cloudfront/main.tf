
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "jaysosmc-opencbdc-react-build.s3.us-east-1.amazonaws.com"
}

resource "aws_s3_bucket" "build_bucket" {
  bucket = "${var.s3_build_bucket}"

  tags = merge(
    var.tags
  )
}

data "aws_iam_policy_document" "build_bucket" {
  statement {
    actions = ["s3:GetObject"]
    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
    resources = ["${aws_s3_bucket.build_bucket.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "build_bucket" {
  bucket = "${aws_s3_bucket.build_bucket.id}"
  policy = "${data.aws_iam_policy_document.build_bucket.json}"
}

data "aws_lb" "auth_nlb" {
  name = "${var.dns_prefix}-ui-nlb"
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = "${aws_s3_bucket.build_bucket.bucket_regional_domain_name}"
    origin_id   = "S3-${aws_s3_bucket.build_bucket.bucket}"
    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  origin {
    domain_name = data.aws_lb.auth_nlb.dns_name
    origin_id   = data.aws_lb.auth_nlb.dns_name
    custom_origin_config {
      http_port               = "80" // TO-DO pull from test-controller module
      https_port              = "8443" // TO-DO pull from test-controller module
      origin_protocol_policy  = "https-only"
      origin_ssl_protocols    = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  custom_error_response {
    error_code          = 403
    response_code       = 200
    response_page_path  = "/index.html"  
  }

  # If using route53 aliases for DNS we need to declare it here too, otherwise we'll get 403s.
  # aliases = ["test-controller.${var.dns_base_domain}"] 

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.build_bucket.bucket}"

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

  ordered_cache_behavior {
    path_pattern     = "/auth"
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = data.aws_lb.auth_nlb.dns_name

    forwarded_values {
      query_string = false
      #headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
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

  #viewer_certificate {
  #  acm_certificate_arn       = var.cert_arn
  #  ssl_support_method        = "sni-only"
  #  minimum_protocol_version  = "TLSv1"
  #}

  ## Start with default cert, and replace in cloudfront_addcert module (to avoid cycle with route53 module)
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  
  depends_on = [
    aws_s3_bucket.build_bucket,
    aws_cloudfront_origin_access_identity.origin_access_identity,
    data.aws_lb.auth_nlb
  ]
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.build_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "mybucket" {
  bucket = aws_s3_bucket.build_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_s3_bucket_public_access_block" "mybucket" {
  bucket = aws_s3_bucket.build_bucket.id

  block_public_acls       = true
  block_public_policy     = true
}


# Create alias for CloudFront
resource "aws_route53_record" "cloudfront" {
  zone_id = var.hosted_zone_id
  name    = "${var.dns_prefix}.${var.dns_base_domain}"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = true
  }

  depends_on = [
    aws_cloudfront_distribution.cdn
  ]
}

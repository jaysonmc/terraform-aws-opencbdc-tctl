data "aws_cloudfront_distribution" "test" {
  id = var.cloudfront_id

  viewer_certificate {
    acm_certificate_arn       = var.cert_arn
    ssl_support_method        = "sni-only"
    minimum_protocol_version  = "TLSv1"
  }
}


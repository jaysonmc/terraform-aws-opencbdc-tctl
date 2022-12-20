output "cloudfront_address" {
  value       = aws_cloudfront_distribution.cdn.domain_name
  description = "Cloudfront address"
}
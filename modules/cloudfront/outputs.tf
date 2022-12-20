output "cloudfront_address" {
  value       = aws_cloudfront_distribution.cdn[0].domain_name
  description = "Cloudfront address"
}
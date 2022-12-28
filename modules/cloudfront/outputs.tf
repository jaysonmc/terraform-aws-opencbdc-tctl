output "cloudfront_address" {
  value       = aws_cloudfront_distribution.cdn.domain_name
  description = "Cloudfront address"
}

output "ui_endpoint" {
  value = aws_route53_record.cloudfront.fqdn
  description = "The test controller endpoint where users can connect to the UI"
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.cdn.id
  description = "ID of the CF distribution"
}

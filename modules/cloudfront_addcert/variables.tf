variable "cert_arn" {
  type        = string
  description = "ARN of ACM certificate"
}

variable "cloudfront_id" {
  type        = string
  description = "ID of the CF distribution"
}

variable "dns_base_domain" {
  type        = string
  description = "DNS Zone name to be used for ACM cert creation."
}
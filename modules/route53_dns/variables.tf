variable "dns_base_domain" {
  type        = string
  description = "DNS Zone name to be used for ACM cert creation."
}

variable "cloudfront_domain" {
  type        = string
  description = "CloudFront domain (origin domain name required for https connection to avoid CF returning 502)"
}

variable "tags" {
  type        = map(string)
  description = "Tags to set for all resources"
  default     = {}
}

variable "hosted_zone_id" {
  type = string
  description = "DNS zone hosted ID"
}

variable "dns_prefix" {
  type = string
  description = "Test controller name"
}

variable "ui_nlb" {
  type = string
  description = "Name of the UI NLB"
}
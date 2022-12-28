variable "cert_arn" {
  type        = string
  description = "ARN of ACM certificate"
}

variable "cloudfront_id" {
  type        = string
  description = "ID of the CF distribution"
}
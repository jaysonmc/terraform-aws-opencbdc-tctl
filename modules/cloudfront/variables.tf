variable "s3_build_bucket" {
  type        = string
  description = "S3 bucket where the react build folder exists."
}

variable "tags" {
  type        = map(string)
  description = "Tags to set for all resources"
  default     = {}
}

variable "dns_base_domain" {
  type        = string
  description = "DNS Zone name to be used for ACM cert creation."
}
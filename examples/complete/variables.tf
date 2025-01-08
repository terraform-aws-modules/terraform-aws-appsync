variable "main_region" {
  type        = string
  description = "AWS main region"
  default     = "eu-west-1"
}

variable "existing_route53_zone" {
  type = object({
    # Use existing zone (via data source) or create new one (will fail validation, if zone is not reachable)
    use         = optional(bool, true)
    domain_name = optional(string, "terraform-aws-modules.modules.tf")
  })
  description = "Override this value to use an existing Route 53 zone"
  default     = {}
}

variable "existing_acm_certificate" {
  type = object({
    # Use existing certificate (via data source) or create new one
    use         = optional(bool, false)
    domain_name = optional(string)
  })
  description = "Override this value to use an existing ACM certificate"
  default     = {}
}

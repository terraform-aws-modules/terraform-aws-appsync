variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "eu-west-1"
}

variable "use_existing_route53_zone" {
  description = "Whether to use an existing Route 53 zone"
  type        = bool
  default     = true
}

variable "route53_domain_name" {
  description = "Existing Route 53 domain name"
  type        = string
  default     = "terraform-aws-modules.modules.tf"
}

variable "use_existing_acm_certificate" {
  description = "Whether to use an existing ACM certificate"
  type        = bool
  default     = false
}

variable "existing_acm_certificate_domain_name" {
  description = "Existing ACM certificate domain name"
  type        = string
  default     = "terraform-aws-modules.modules.tf"
}

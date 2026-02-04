variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name for the AppSync Event API"
  type        = string
  default     = "event-api-complete-example"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for custom domain (must be in us-east-1)"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Custom domain name for Event API"
  type        = string
  default     = ""
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID for authentication"
  type        = string
  default     = ""
}

variable "oidc_issuer" {
  description = "OpenID Connect issuer URL"
  type        = string
  default     = ""
}

variable "oidc_client_id" {
  description = "OpenID Connect client ID"
  type        = string
  default     = ""
}

variable "lambda_authorizer_arn" {
  description = "Lambda function ARN for custom authorization"
  type        = string
  default     = ""
}

variable "chat_handler_lambda_arn" {
  description = "Lambda function ARN for chat channel handler"
  type        = string
  default     = ""
}

variable "http_endpoint" {
  description = "HTTP endpoint URL for HTTP datasource"
  type        = string
  default     = "https://api.example.com"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "example"
    ManagedBy   = "Terraform"
    Example     = "event-api-complete"
  }
}

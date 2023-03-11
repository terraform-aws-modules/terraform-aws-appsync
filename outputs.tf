# GraphQL API
output "appsync_graphql_api_id" {
  description = "ID of GraphQL API"
  value       = try(aws_appsync_graphql_api.this[0].id, null)
}

output "appsync_graphql_api_arn" {
  description = "ARN of GraphQL API"
  value       = try(aws_appsync_graphql_api.this[0].arn, null)
}

output "appsync_graphql_api_uris" {
  description = "Map of URIs associated with the API"
  value       = try(aws_appsync_graphql_api.this[0].uris, null)
}

# API Key
output "appsync_api_key_id" {
  description = "Map of API Key ID (Formatted as ApiId:Key)"
  value       = { for k, v in aws_appsync_api_key.this : k => v.id }
}

output "appsync_api_key_key" {
  description = "Map of API Keys"
  value       = { for k, v in aws_appsync_api_key.this : k => v.key }
  sensitive   = true
}

# Datasources
output "appsync_datasource_arn" {
  description = "Map of ARNs of datasources"
  value       = { for k, v in aws_appsync_datasource.this : k => v.arn }
}

# Resolvers
output "appsync_resolver_arn" {
  description = "Map of ARNs of resolvers"
  value       = { for k, v in aws_appsync_resolver.this : k => v.arn }
}

# Functions
output "appsync_function_arn" {
  description = "Map of ARNs of functions"
  value       = { for k, v in aws_appsync_function.this : k => v.arn }
}

output "appsync_function_id" {
  description = "Map of IDs of functions"
  value       = { for k, v in aws_appsync_function.this : k => v.id }
}

output "appsync_function_function_id" {
  description = "Map of function IDs of functions"
  value       = { for k, v in aws_appsync_function.this : k => v.function_id }
}

# Domain
output "appsync_domain_id" {
  description = "The Appsync Domain Name."
  value       = try(aws_appsync_domain_name.this[0].id, null)
}

output "appsync_domain_name" {
  description = "The domain name that AppSync provides."
  value       = try(aws_appsync_domain_name.this[0].appsync_domain_name, null)
}

output "appsync_domain_hosted_zone_id" {
  description = "The ID of your Amazon Route 53 hosted zone."
  value       = try(aws_appsync_domain_name.this[0].hosted_zone_id, null)
}

# Extra
output "appsync_graphql_api_fqdns" {
  description = "Map of FQDNs associated with the API (no protocol and path)"
  value       = { for k, v in try(aws_appsync_graphql_api.this[0].uris, []) : k => regex("://([^/?#]*)?", v)[0] if length(aws_appsync_graphql_api.this) > 0 }
}

# GraphQL API
output "appsync_graphql_api_id" {
  description = "ID of GraphQL API"
  value       = element(concat(aws_appsync_graphql_api.this.*.id, [""]), 0)
}

output "appsync_graphql_api_arn" {
  description = "ARN of GraphQL API"
  value       = element(concat(aws_appsync_graphql_api.this.*.arn, [""]), 0)
}

output "appsync_graphql_api_uris" {
  description = "Map of URIs associated with the API"
  value       = element(concat(aws_appsync_graphql_api.this.*.uris, [""]), 0)
}

# API Key
output "appsync_api_key_id" {
  description = "Map of API Key ID (Formatted as ApiId:Key)"
  value       = { for k, v in aws_appsync_api_key.this : k => v.id }
}

output "appsync_api_key_key" {
  description = "Map of API Keys"
  value       = { for k, v in aws_appsync_api_key.this : k => v.key }
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

# Extra
output "appsync_graphql_api_fqdns" {
  description = "Map of FQDNs associated with the API (no protocol and path)"
  value       = length(aws_appsync_graphql_api.this) != 0 ? { for k, v in element(concat(aws_appsync_graphql_api.this.*.uris, [""]), 0) : k => regex("://([^/?#]*)?", v)[0] } : {}
}

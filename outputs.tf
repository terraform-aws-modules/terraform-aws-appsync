# GraphQL API
output "this_appsync_graphql_api_id" {
  description = "ID of GraphQL API"
  value       = element(concat(aws_appsync_graphql_api.this.*.id, [""]), 0)
}

output "this_appsync_graphql_api_arn" {
  description = "ARN of GraphQL API"
  value       = element(concat(aws_appsync_graphql_api.this.*.arn, [""]), 0)
}

output "this_appsync_graphql_api_uris" {
  description = "Map of URIs associated with the API"
  value       = element(concat(aws_appsync_graphql_api.this.*.uris, [""]), 0)
}

# API Key
output "this_appsync_api_key_id" {
  description = "Map of API Key ID (Formatted as ApiId:Key)"
  value       = { for k, v in aws_appsync_api_key.this : k => v.id }
}

output "this_appsync_api_key_key" {
  description = "Map of API Keys"
  value       = { for k, v in aws_appsync_api_key.this : k => v.key }
}

# Datasources
output "this_appsync_datasource_arn" {
  description = "Map of ARNs of datasources"
  value       = { for k, v in aws_appsync_datasource.this : k => v.arn }
}

# Resolvers
output "this_appsync_resolver_arn" {
  description = "Map of ARNs of resolvers"
  value       = { for k, v in aws_appsync_resolver.this : k => v.arn }
}

# Extra
output "this_appsync_graphql_api_fqdns" {
  description = "Map of FQDNs associated with the API (no protocol and path)"
  value       = { for k, v in element(concat(aws_appsync_graphql_api.this.*.uris, [""]), 0) : k => regex("://([^/?#]*)?", v)[0] }
}

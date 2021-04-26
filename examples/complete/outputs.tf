# GraphQL API
output "appsync_graphql_api_id" {
  description = "ID of GraphQL API"
  value       = module.appsync.appsync_graphql_api_id
}

output "appsync_graphql_api_arn" {
  description = "ARN of GraphQL API"
  value       = module.appsync.appsync_graphql_api_arn
}

output "appsync_graphql_api_uris" {
  description = "Map of URIs associated with the API"
  value       = module.appsync.appsync_graphql_api_uris
}

# API Key
output "appsync_api_key_id" {
  description = "Map of API Key ID (Formatted as ApiId:Key)"
  value       = module.appsync.appsync_api_key_id
}

output "appsync_api_key_key" {
  description = "Map of API Keys"
  value       = module.appsync.appsync_api_key_key
}

# Datasources
output "appsync_datasource_arn" {
  description = "Map of ARNs of datasources"
  value       = module.appsync.appsync_datasource_arn
}

# Resolvers
output "appsync_resolver_arn" {
  description = "Map of ARNs of resolvers"
  value       = module.appsync.appsync_resolver_arn
}

# Extra
output "appsync_graphql_api_fqdns" {
  description = "Map of FQDNs associated with the API (no protocol and path)"
  value       = module.appsync.appsync_graphql_api_fqdns
}

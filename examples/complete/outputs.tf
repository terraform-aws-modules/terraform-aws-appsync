# GraphQL API
output "this_appsync_graphql_api_id" {
  description = "ID of GraphQL API"
  value       = module.appsync.this_appsync_graphql_api_id
}

output "this_appsync_graphql_api_arn" {
  description = "ARN of GraphQL API"
  value       = module.appsync.this_appsync_graphql_api_arn
}

output "this_appsync_graphql_api_uris" {
  description = "Map of URIs associated with the API"
  value       = module.appsync.this_appsync_graphql_api_uris
}

# API Key
output "this_appsync_api_key_id" {
  description = "Map of API Key ID (Formatted as ApiId:Key)"
  value       = module.appsync.this_appsync_api_key_id
}

output "this_appsync_api_key_key" {
  description = "Map of API Keys"
  value       = module.appsync.this_appsync_api_key_key
}

# Datasources
output "this_appsync_datasource_arn" {
  description = "Map of ARNs of datasources"
  value       = module.appsync.this_appsync_datasource_arn
}

# Resolvers
output "this_appsync_resolver_arn" {
  description = "Map of ARNs of resolvers"
  value       = module.appsync.this_appsync_resolver_arn
}

# Extra
output "this_appsync_graphql_api_fqdns" {
  description = "Map of FQDNs associated with the API (no protocol and path)"
  value       = module.appsync.this_appsync_graphql_api_fqdns
}

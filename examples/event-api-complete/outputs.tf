##############################################################
# Event API Outputs
##############################################################

output "event_api_id" {
  description = "The ID of the AppSync Event API"
  value       = module.event_api_complete.event_api_id
}

output "event_api_arn" {
  description = "The ARN of the AppSync Event API"
  value       = module.event_api_complete.event_api_arn
}

output "event_api_endpoint" {
  description = "The WebSocket endpoint URL for the Event API"
  value       = module.event_api_complete.event_api_endpoint
}

##############################################################
# API Key for Testing
##############################################################

output "api_key" {
  description = "API key for testing (valid for 365 days)"
  value       = aws_appsync_api_key.example.key
  sensitive   = true
}

output "api_key_expires" {
  description = "API key expiration timestamp"
  value       = aws_appsync_api_key.example.expires
}

##############################################################
# Channel Namespaces
##############################################################

output "channel_namespace_arns" {
  description = "ARNs of channel namespaces"
  value       = module.event_api_complete.channel_namespace_arns
}

##############################################################
# Custom Domain (if configured)
##############################################################

output "custom_domain_name" {
  description = "Custom domain name for the Event API"
  value       = module.event_api_complete.event_api_custom_domain_name
}

output "custom_domain_appsync_domain" {
  description = "AppSync domain name for DNS configuration"
  value       = module.event_api_complete.appsync_domain_name
}

output "custom_domain_hosted_zone_id" {
  description = "Hosted Zone ID for the AppSync domain"
  value       = module.event_api_complete.appsync_domain_hosted_zone_id
}

##############################################################
# Testing Instructions
##############################################################

output "testing_instructions" {
  description = "Instructions for testing the Event API"
  value       = <<-EOT

  ========================================
  Event API Testing Instructions
  ========================================

  1. Get API Key:
     terraform output -raw api_key

  2. WebSocket Endpoint:
     ${module.event_api_complete.event_api_endpoint}

  3. Event API ID:
     ${module.event_api_complete.event_api_id}

  4. Channel Namespaces:
     - chat
     - notifications
     - presence

  5. Test WebSocket Connection:
     Use wscat or similar tool:
     wscat -c "wss://${module.event_api_complete.event_api_endpoint}" \
       -H "x-api-key: YOUR_API_KEY"

  6. Subscribe to Channel:
     After connection, send:
     {"action":"subscribe","channel":"/chat/general"}

  7. Publish Event (from another terminal):
     wscat -c "wss://${module.event_api_complete.event_api_endpoint}" \
       -H "x-api-key: YOUR_API_KEY"
     {"action":"publish","channel":"/chat/general","events":["Hello World"]}

  8. Check CloudWatch Logs:
     Log Group: /aws/appsync/apis/${module.event_api_complete.event_api_id}

     aws logs tail "/aws/appsync/apis/${module.event_api_complete.event_api_id}" --follow

  ========================================
  EOT
}

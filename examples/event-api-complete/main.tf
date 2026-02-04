##############################################################
# AppSync Event API - Complete Example
#
# This example demonstrates all Event API features:
# - All authentication types (API_KEY, IAM, Cognito, OIDC, Lambda)
# - Multiple channel namespaces with JavaScript and Lambda handlers
# - Lambda and HTTP datasources
# - Custom domain name association
# - CloudWatch Logs integration
##############################################################

locals {
  # Read JavaScript handler code from files
  on_publish_code   = file("${path.module}/handlers/onPublish.js")
  on_subscribe_code = file("${path.module}/handlers/onSubscribe.js")

  # Domain name association enabled only if cert and domain provided
  enable_custom_domain = var.certificate_arn != "" && var.domain_name != ""

  # Determine primary auth type based on what's provided
  primary_auth_type = var.lambda_authorizer_arn != "" ? "AWS_LAMBDA" : (var.cognito_user_pool_id != "" ? "AWS_COGNITO_USER_POOLS" : (var.oidc_issuer != "" ? "OPENID_CONNECT" : "API_KEY"))

  # Build auth_provider configuration based on primary auth type
  auth_provider_config = {
    auth_type = local.primary_auth_type

    # Cognito configuration (if primary auth or available)
    cognito_config = var.cognito_user_pool_id != "" ? {
      user_pool_id        = var.cognito_user_pool_id
      aws_region          = var.region
      app_id_client_regex = null
    } : null

    # Lambda authorizer configuration (if primary auth or available)
    lambda_authorizer_config = var.lambda_authorizer_arn != "" ? {
      authorizer_uri                   = var.lambda_authorizer_arn
      authorizer_result_ttl_in_seconds = 300
      identity_validation_expression   = null
    } : null

    # OIDC configuration (if primary auth or available)
    oidc_config = var.oidc_issuer != "" ? {
      issuer    = var.oidc_issuer
      client_id = var.oidc_client_id
      auth_ttl  = 3600
      iat_ttl   = 3600
    } : null
  }

  # Build connection_auth_modes list conditionally
  connection_auth_modes = concat(
    [
      { auth_type = "API_KEY" },
      { auth_type = "AWS_IAM" },
    ],
    var.cognito_user_pool_id != "" ? [{ auth_type = "AWS_COGNITO_USER_POOLS" }] : [],
    var.oidc_issuer != "" ? [{ auth_type = "OPENID_CONNECT" }] : [],
    var.lambda_authorizer_arn != "" ? [{ auth_type = "AWS_LAMBDA" }] : []
  )
}

##############################################################
# AppSync Event API with All Authentication Types
##############################################################

module "event_api_complete" {
  source = "../.."

  # Create Event API only (not GraphQL)
  create_graphql_api   = false
  create_websocket_api = true

  name   = var.name
  region = var.region

  ##############################################################
  # Authentication Configuration
  ##############################################################

  event_config = {
    # Primary authentication provider with nested auth configs
    auth_provider = local.auth_provider_config

    # Connection authentication modes (all types)
    connection_auth_modes = local.connection_auth_modes

    # Publish authentication modes
    default_publish_auth_modes = [
      { auth_type = "API_KEY" },
      { auth_type = "AWS_IAM" },
    ]

    # Subscribe authentication modes
    default_subscribe_auth_modes = [
      { auth_type = "API_KEY" },
      { auth_type = "AWS_IAM" },
    ]
  }

  ##############################################################
  # Channel Namespaces with JavaScript Handlers
  ##############################################################

  channel_namespaces = {
    # Namespace 1: Chat channels with JavaScript code handlers
    "chat" = {
      code_handlers = "${local.on_publish_code}\n\n${local.on_subscribe_code}"
    }

    # Namespace 2: Notifications with JavaScript handlers
    "notifications" = {
      code_handlers = "${local.on_publish_code}\n\n${local.on_subscribe_code}"
    }

    # Namespace 3: Presence tracking with JavaScript handlers
    "presence" = {
      code_handlers = "${local.on_publish_code}\n\n${local.on_subscribe_code}"
    }
  }

  ##############################################################
  # Datasources
  ##############################################################

  datasources = {
    # Lambda datasource for async processing (using placeholder if not provided)
    "lambda_processor" = {
      type         = "AWS_LAMBDA"
      function_arn = var.chat_handler_lambda_arn != "" ? var.chat_handler_lambda_arn : "arn:aws:lambda:${var.region}:123456789012:function:placeholder"
    }

    # HTTP datasource for external API integration
    "external_api" = {
      type               = "HTTP"
      http_endpoint      = var.http_endpoint
      authorization_type = "AWS_IAM"
      signing_region     = var.region
      signing_service    = "execute-api"
    }
  }

  ##############################################################
  # CloudWatch Logs Configuration
  ##############################################################

  logging_enabled     = true
  log_field_log_level = "ALL" # ALL | ERROR | NONE
  create_logs_role    = true

  ##############################################################
  # Custom Domain Name Association (if certificate provided)
  ##############################################################

  domain_name_association_enabled = local.enable_custom_domain
  certificate_arn                 = var.certificate_arn
  domain_name                     = var.domain_name

  ##############################################################
  # Tags
  ##############################################################

  tags = var.tags
}

##############################################################
# Optional: Create API Key for Testing
##############################################################

resource "aws_appsync_api_key" "example" {
  api_id  = module.event_api_complete.event_api_id
  expires = timeadd(timestamp(), "365d")
}

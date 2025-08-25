module "wrapper" {
  source = "../"

  for_each = var.items

  additional_authentication_provider = try(each.value.additional_authentication_provider, var.defaults.additional_authentication_provider, {})
  api_keys                           = try(each.value.api_keys, var.defaults.api_keys, {})
  authentication_type                = try(each.value.authentication_type, var.defaults.authentication_type, "API_KEY")
  cache_at_rest_encryption_enabled   = try(each.value.cache_at_rest_encryption_enabled, var.defaults.cache_at_rest_encryption_enabled, false)
  cache_transit_encryption_enabled   = try(each.value.cache_transit_encryption_enabled, var.defaults.cache_transit_encryption_enabled, false)
  cache_ttl                          = try(each.value.cache_ttl, var.defaults.cache_ttl, 1)
  cache_type                         = try(each.value.cache_type, var.defaults.cache_type, "SMALL")
  caching_behavior                   = try(each.value.caching_behavior, var.defaults.caching_behavior, "FULL_REQUEST_CACHING")
  caching_enabled                    = try(each.value.caching_enabled, var.defaults.caching_enabled, false)
  certificate_arn                    = try(each.value.certificate_arn, var.defaults.certificate_arn, "")
  create_graphql_api                 = try(each.value.create_graphql_api, var.defaults.create_graphql_api, true)
  create_logs_role                   = try(each.value.create_logs_role, var.defaults.create_logs_role, true)
  datasources                        = try(each.value.datasources, var.defaults.datasources, {})
  direct_lambda_request_template = try(each.value.direct_lambda_request_template, var.defaults.direct_lambda_request_template, <<-EOF
  {
    "version" : "2017-02-28",
    "operation": "Invoke",
    "payload": {
      "arguments": $util.toJson($ctx.arguments),
      "identity": $util.toJson($ctx.identity),
      "source": $util.toJson($ctx.source),
      "request": $util.toJson($ctx.request),
      "prev": $util.toJson($ctx.prev),
      "info": {
          "selectionSetList": $util.toJson($ctx.info.selectionSetList),
          "selectionSetGraphQL": $util.toJson($ctx.info.selectionSetGraphQL),
          "parentTypeName": $util.toJson($ctx.info.parentTypeName),
          "fieldName": $util.toJson($ctx.info.fieldName),
          "variables": $util.toJson($ctx.info.variables)
      },
      "stash": $util.toJson($ctx.stash)
    }
  }
  EOF
  )
  direct_lambda_response_template = try(each.value.direct_lambda_response_template, var.defaults.direct_lambda_response_template, <<-EOF
  $util.toJson($ctx.result)
  EOF
  )
  domain_name                         = try(each.value.domain_name, var.defaults.domain_name, "")
  domain_name_association_enabled     = try(each.value.domain_name_association_enabled, var.defaults.domain_name_association_enabled, false)
  domain_name_description             = try(each.value.domain_name_description, var.defaults.domain_name_description, null)
  dynamodb_allowed_actions            = try(each.value.dynamodb_allowed_actions, var.defaults.dynamodb_allowed_actions, ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem", "dynamodb:UpdateItem", "dynamodb:Query", "dynamodb:Scan", "dynamodb:BatchGetItem", "dynamodb:BatchWriteItem"])
  elasticsearch_allowed_actions       = try(each.value.elasticsearch_allowed_actions, var.defaults.elasticsearch_allowed_actions, ["es:ESHttpDelete", "es:ESHttpHead", "es:ESHttpGet", "es:ESHttpPost", "es:ESHttpPut"])
  enhanced_metrics_config             = try(each.value.enhanced_metrics_config, var.defaults.enhanced_metrics_config, {})
  eventbridge_allowed_actions         = try(each.value.eventbridge_allowed_actions, var.defaults.eventbridge_allowed_actions, ["events:PutEvents"])
  functions                           = try(each.value.functions, var.defaults.functions, {})
  graphql_api_tags                    = try(each.value.graphql_api_tags, var.defaults.graphql_api_tags, {})
  iam_permissions_boundary            = try(each.value.iam_permissions_boundary, var.defaults.iam_permissions_boundary, null)
  introspection_config                = try(each.value.introspection_config, var.defaults.introspection_config, null)
  lambda_allowed_actions              = try(each.value.lambda_allowed_actions, var.defaults.lambda_allowed_actions, ["lambda:invokeFunction"])
  lambda_authorizer_config            = try(each.value.lambda_authorizer_config, var.defaults.lambda_authorizer_config, {})
  log_cloudwatch_logs_role_arn        = try(each.value.log_cloudwatch_logs_role_arn, var.defaults.log_cloudwatch_logs_role_arn, null)
  log_exclude_verbose_content         = try(each.value.log_exclude_verbose_content, var.defaults.log_exclude_verbose_content, false)
  log_field_log_level                 = try(each.value.log_field_log_level, var.defaults.log_field_log_level, null)
  logging_enabled                     = try(each.value.logging_enabled, var.defaults.logging_enabled, false)
  logs_role_description               = try(each.value.logs_role_description, var.defaults.logs_role_description, null)
  logs_role_name                      = try(each.value.logs_role_name, var.defaults.logs_role_name, null)
  logs_role_tags                      = try(each.value.logs_role_tags, var.defaults.logs_role_tags, {})
  name                                = try(each.value.name, var.defaults.name, "")
  openid_connect_config               = try(each.value.openid_connect_config, var.defaults.openid_connect_config, {})
  opensearchservice_allowed_actions   = try(each.value.opensearchservice_allowed_actions, var.defaults.opensearchservice_allowed_actions, ["es:ESHttpDelete", "es:ESHttpHead", "es:ESHttpGet", "es:ESHttpPost", "es:ESHttpPut"])
  query_depth_limit                   = try(each.value.query_depth_limit, var.defaults.query_depth_limit, null)
  region                              = try(each.value.region, var.defaults.region, null)
  relational_database_allowed_actions = try(each.value.relational_database_allowed_actions, var.defaults.relational_database_allowed_actions, ["rds-data:BatchExecuteStatement", "rds-data:BeginTransaction", "rds-data:CommitTransaction", "rds-data:ExecuteStatement", "rds-data:RollbackTransaction"])
  resolver_caching_ttl                = try(each.value.resolver_caching_ttl, var.defaults.resolver_caching_ttl, 60)
  resolver_count_limit                = try(each.value.resolver_count_limit, var.defaults.resolver_count_limit, null)
  resolvers                           = try(each.value.resolvers, var.defaults.resolvers, {})
  schema                              = try(each.value.schema, var.defaults.schema, "")
  secrets_manager_allowed_actions     = try(each.value.secrets_manager_allowed_actions, var.defaults.secrets_manager_allowed_actions, ["secretsmanager:GetSecretValue"])
  tags                                = try(each.value.tags, var.defaults.tags, {})
  user_pool_config                    = try(each.value.user_pool_config, var.defaults.user_pool_config, {})
  visibility                          = try(each.value.visibility, var.defaults.visibility, null)
  xray_enabled                        = try(each.value.xray_enabled, var.defaults.xray_enabled, false)
}

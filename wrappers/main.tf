module "wrapper" {
  source = "../"

  for_each = var.items

  create_graphql_api                 = try(each.value.create_graphql_api, var.defaults.create_graphql_api, true)
  logging_enabled                    = try(each.value.logging_enabled, var.defaults.logging_enabled, false)
  domain_name_association_enabled    = try(each.value.domain_name_association_enabled, var.defaults.domain_name_association_enabled, false)
  caching_enabled                    = try(each.value.caching_enabled, var.defaults.caching_enabled, false)
  xray_enabled                       = try(each.value.xray_enabled, var.defaults.xray_enabled, false)
  name                               = try(each.value.name, var.defaults.name, "")
  schema                             = try(each.value.schema, var.defaults.schema, "")
  visibility                         = try(each.value.visibility, var.defaults.visibility, null)
  authentication_type                = try(each.value.authentication_type, var.defaults.authentication_type, "API_KEY")
  create_logs_role                   = try(each.value.create_logs_role, var.defaults.create_logs_role, true)
  logs_role_name                     = try(each.value.logs_role_name, var.defaults.logs_role_name, null)
  log_cloudwatch_logs_role_arn       = try(each.value.log_cloudwatch_logs_role_arn, var.defaults.log_cloudwatch_logs_role_arn, null)
  log_field_log_level                = try(each.value.log_field_log_level, var.defaults.log_field_log_level, null)
  log_exclude_verbose_content        = try(each.value.log_exclude_verbose_content, var.defaults.log_exclude_verbose_content, false)
  lambda_authorizer_config           = try(each.value.lambda_authorizer_config, var.defaults.lambda_authorizer_config, {})
  openid_connect_config              = try(each.value.openid_connect_config, var.defaults.openid_connect_config, {})
  user_pool_config                   = try(each.value.user_pool_config, var.defaults.user_pool_config, {})
  additional_authentication_provider = try(each.value.additional_authentication_provider, var.defaults.additional_authentication_provider, {})
  graphql_api_tags                   = try(each.value.graphql_api_tags, var.defaults.graphql_api_tags, {})
  logs_role_tags                     = try(each.value.logs_role_tags, var.defaults.logs_role_tags, {})
  tags                               = try(each.value.tags, var.defaults.tags, {})
  domain_name                        = try(each.value.domain_name, var.defaults.domain_name, "")
  domain_name_description            = try(each.value.domain_name_description, var.defaults.domain_name_description, null)
  certificate_arn                    = try(each.value.certificate_arn, var.defaults.certificate_arn, "")
  caching_behavior                   = try(each.value.caching_behavior, var.defaults.caching_behavior, "FULL_REQUEST_CACHING")
  cache_type                         = try(each.value.cache_type, var.defaults.cache_type, "SMALL")
  cache_ttl                          = try(each.value.cache_ttl, var.defaults.cache_ttl, 1)
  cache_at_rest_encryption_enabled   = try(each.value.cache_at_rest_encryption_enabled, var.defaults.cache_at_rest_encryption_enabled, false)
  cache_transit_encryption_enabled   = try(each.value.cache_transit_encryption_enabled, var.defaults.cache_transit_encryption_enabled, false)
  api_keys                           = try(each.value.api_keys, var.defaults.api_keys, {})
  lambda_allowed_actions             = try(each.value.lambda_allowed_actions, var.defaults.lambda_allowed_actions, ["lambda:invokeFunction"])
  dynamodb_allowed_actions           = try(each.value.dynamodb_allowed_actions, var.defaults.dynamodb_allowed_actions, ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem", "dynamodb:UpdateItem", "dynamodb:Query", "dynamodb:Scan", "dynamodb:BatchGetItem", "dynamodb:BatchWriteItem"])
  elasticsearch_allowed_actions      = try(each.value.elasticsearch_allowed_actions, var.defaults.elasticsearch_allowed_actions, ["es:ESHttpDelete", "es:ESHttpHead", "es:ESHttpGet", "es:ESHttpPost", "es:ESHttpPut"])
  opensearchservice_allowed_actions  = try(each.value.opensearchservice_allowed_actions, var.defaults.opensearchservice_allowed_actions, ["es:ESHttpDelete", "es:ESHttpHead", "es:ESHttpGet", "es:ESHttpPost", "es:ESHttpPut"])
  eventbridge_allowed_actions        = try(each.value.eventbridge_allowed_actions, var.defaults.eventbridge_allowed_actions, ["events:PutEvents"])
  iam_permissions_boundary           = try(each.value.iam_permissions_boundary, var.defaults.iam_permissions_boundary, null)
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
  resolver_caching_ttl = try(each.value.resolver_caching_ttl, var.defaults.resolver_caching_ttl, 60)
  datasources          = try(each.value.datasources, var.defaults.datasources, {})
  resolvers            = try(each.value.resolvers, var.defaults.resolvers, {})
  functions            = try(each.value.functions, var.defaults.functions, {})
}

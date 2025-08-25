locals {
  resolvers = { for k, v in var.resolvers : k => merge(v, {
    type  = split(".", k)[0]
    field = join(".", slice(split(".", k), 1, length(split(".", k))))
  }) if var.create_graphql_api }
}

# GraphQL API
resource "aws_appsync_graphql_api" "this" {
  count = var.create_graphql_api ? 1 : 0

  region = var.region

  name                = var.name
  authentication_type = var.authentication_type
  schema              = var.schema
  xray_enabled        = var.xray_enabled
  visibility          = var.visibility

  introspection_config = var.introspection_config
  query_depth_limit    = var.query_depth_limit
  resolver_count_limit = var.resolver_count_limit

  dynamic "log_config" {
    for_each = var.logging_enabled ? [true] : []

    content {
      cloudwatch_logs_role_arn = var.create_logs_role ? aws_iam_role.logs[0].arn : var.log_cloudwatch_logs_role_arn
      field_log_level          = var.log_field_log_level
      exclude_verbose_content  = var.log_exclude_verbose_content
    }
  }

  dynamic "lambda_authorizer_config" {
    for_each = length(keys(var.lambda_authorizer_config)) == 0 ? [] : [true]

    content {
      authorizer_uri                   = var.lambda_authorizer_config["authorizer_uri"]
      authorizer_result_ttl_in_seconds = lookup(var.lambda_authorizer_config, "authorizer_result_ttl_in_seconds", null)
      identity_validation_expression   = lookup(var.lambda_authorizer_config, "identity_validation_expression", null)
    }
  }

  dynamic "openid_connect_config" {
    for_each = length(keys(var.openid_connect_config)) == 0 ? [] : [true]

    content {
      issuer    = var.openid_connect_config["issuer"]
      client_id = lookup(var.openid_connect_config, "client_id", null)
      auth_ttl  = lookup(var.openid_connect_config, "auth_ttl", null)
      iat_ttl   = lookup(var.openid_connect_config, "iat_ttl", null)
    }
  }

  dynamic "user_pool_config" {
    for_each = length(keys(var.user_pool_config)) == 0 ? [] : [true]

    content {
      default_action      = var.user_pool_config["default_action"]
      user_pool_id        = var.user_pool_config["user_pool_id"]
      app_id_client_regex = lookup(var.user_pool_config, "app_id_client_regex", null)
      aws_region          = lookup(var.user_pool_config, "aws_region", null)
    }
  }

  dynamic "additional_authentication_provider" {
    for_each = var.additional_authentication_provider

    content {
      authentication_type = additional_authentication_provider.value.authentication_type

      dynamic "openid_connect_config" {
        for_each = length(keys(lookup(additional_authentication_provider.value, "openid_connect_config", {}))) == 0 ? [] : [additional_authentication_provider.value.openid_connect_config]

        content {
          issuer    = openid_connect_config.value.issuer
          client_id = lookup(openid_connect_config.value, "client_id", null)
          auth_ttl  = lookup(openid_connect_config.value, "auth_ttl", null)
          iat_ttl   = lookup(openid_connect_config.value, "iat_ttl", null)
        }
      }

      dynamic "user_pool_config" {
        for_each = length(keys(lookup(additional_authentication_provider.value, "user_pool_config", {}))) == 0 ? [] : [additional_authentication_provider.value.user_pool_config]

        content {
          user_pool_id        = user_pool_config.value.user_pool_id
          app_id_client_regex = lookup(user_pool_config.value, "app_id_client_regex", null)
          aws_region          = lookup(user_pool_config.value, "aws_region", null)
        }
      }
      dynamic "lambda_authorizer_config" {
        for_each = length(keys(lookup(additional_authentication_provider.value, "lambda_authorizer_config", {}))) == 0 ? [] : [additional_authentication_provider.value.lambda_authorizer_config]

        content {
          authorizer_uri                   = lambda_authorizer_config.value.authorizer_uri
          authorizer_result_ttl_in_seconds = lookup(lambda_authorizer_config.value, "authorizer_result_ttl_in_seconds", null)
          identity_validation_expression   = lookup(lambda_authorizer_config.value, "identity_validation_expression", null)
        }
      }
    }
  }

  dynamic "enhanced_metrics_config" {
    for_each = length(keys(var.enhanced_metrics_config)) == 0 ? [] : [true]

    content {
      data_source_level_metrics_behavior = lookup(var.enhanced_metrics_config, "data_source_level_metrics_behavior", null)
      operation_level_metrics_config     = lookup(var.enhanced_metrics_config, "operation_level_metrics_config", null)
      resolver_level_metrics_behavior    = lookup(var.enhanced_metrics_config, "resolver_level_metrics_behavior", null)
    }
  }

  tags = merge({ Name = var.name }, var.graphql_api_tags)
}

# API Association & Domain Name
resource "aws_appsync_domain_name" "this" {
  count = var.create_graphql_api && var.domain_name_association_enabled ? 1 : 0

  region = var.region

  domain_name     = var.domain_name
  description     = var.domain_name_description
  certificate_arn = var.certificate_arn
}

resource "aws_appsync_domain_name_api_association" "this" {
  count = var.create_graphql_api && var.domain_name_association_enabled ? 1 : 0

  region = var.region

  api_id      = aws_appsync_graphql_api.this[0].id
  domain_name = aws_appsync_domain_name.this[0].domain_name
}

# API Cache
resource "aws_appsync_api_cache" "this" {
  count = var.create_graphql_api && var.caching_enabled ? 1 : 0

  region = var.region

  api_id = aws_appsync_graphql_api.this[0].id

  api_caching_behavior       = var.caching_behavior
  type                       = var.cache_type
  ttl                        = var.cache_ttl
  at_rest_encryption_enabled = var.cache_at_rest_encryption_enabled
  transit_encryption_enabled = var.cache_transit_encryption_enabled
}

# API Key
resource "aws_appsync_api_key" "this" {
  for_each = var.create_graphql_api && var.authentication_type == "API_KEY" ? var.api_keys : {}

  region = var.region

  api_id      = aws_appsync_graphql_api.this[0].id
  description = each.key
  expires     = each.value
}

# Datasource
resource "aws_appsync_datasource" "this" {
  for_each = var.create_graphql_api ? var.datasources : {}

  region = var.region

  api_id           = aws_appsync_graphql_api.this[0].id
  name             = each.key
  type             = each.value.type
  description      = lookup(each.value, "description", null)
  service_role_arn = lookup(each.value, "service_role_arn", tobool(lookup(each.value, "create_service_role", contains(["AWS_LAMBDA", "AMAZON_DYNAMODB", "AMAZON_ELASTICSEARCH", "AMAZON_OPENSEARCH_SERVICE", "AMAZON_EVENTBRIDGE", "RELATIONAL_DATABASE"], each.value.type))) ? aws_iam_role.service_role[each.key].arn : null)

  dynamic "http_config" {
    for_each = each.value.type == "HTTP" ? [true] : []

    content {
      endpoint = each.value.endpoint
    }
  }

  dynamic "lambda_config" {
    for_each = each.value.type == "AWS_LAMBDA" ? [true] : []

    content {
      function_arn = each.value.function_arn
    }
  }

  dynamic "dynamodb_config" {
    for_each = each.value.type == "AMAZON_DYNAMODB" ? [true] : []

    content {
      table_name             = each.value.table_name
      region                 = lookup(each.value, "region", null)
      use_caller_credentials = lookup(each.value, "use_caller_credentials", null)
    }
  }

  dynamic "elasticsearch_config" {
    for_each = each.value.type == "AMAZON_ELASTICSEARCH" ? [true] : []

    content {
      endpoint = each.value.endpoint
      region   = lookup(each.value, "region", null)
    }
  }

  dynamic "opensearchservice_config" {
    for_each = each.value.type == "AMAZON_OPENSEARCH_SERVICE" ? [true] : []

    content {
      endpoint = each.value.endpoint
      region   = lookup(each.value, "region", null)
    }
  }

  dynamic "event_bridge_config" {
    for_each = each.value.type == "AMAZON_EVENTBRIDGE" ? [true] : []

    content {
      event_bus_arn = each.value.event_bus_arn
    }
  }

  dynamic "relational_database_config" {
    for_each = each.value.type == "RELATIONAL_DATABASE" ? [true] : []

    content {
      source_type = lookup(each.value, "source_type", "RDS_HTTP_ENDPOINT")

      http_endpoint_config {
        db_cluster_identifier = each.value.cluster_arn
        aws_secret_store_arn  = each.value.secret_arn
        database_name         = lookup(each.value, "database_name", null)
        region                = split(":", each.value.cluster_arn)[3]
        schema                = lookup(each.value, "schema", null)
      }
    }
  }
}

# Resolvers
resource "aws_appsync_resolver" "this" {
  for_each = local.resolvers

  region = var.region

  api_id = aws_appsync_graphql_api.this[0].id
  type   = each.value.type
  field  = each.value.field
  kind   = lookup(each.value, "kind", null)

  dynamic "runtime" {
    for_each = try([each.value.runtime], [])

    content {
      name            = runtime.value.name
      runtime_version = try(runtime.value.runtime_version, "1.0.0")
    }
  }

  # code is required when runtime is APPSYNC_JS
  code = try(each.value.runtime.name == "APPSYNC_JS", false) ? each.value.code : null

  request_template  = lookup(each.value, "request_template", tobool(lookup(each.value, "direct_lambda", false)) ? var.direct_lambda_request_template : try(each.value.runtime.name == "APPSYNC_JS", false) ? null : "{}")
  response_template = lookup(each.value, "response_template", tobool(lookup(each.value, "direct_lambda", false)) ? var.direct_lambda_response_template : try(each.value.runtime.name == "APPSYNC_JS", false) ? null : "{}")

  data_source = lookup(each.value, "data_source", null) != null ? aws_appsync_datasource.this[each.value.data_source].name : lookup(each.value, "data_source_arn", null)

  dynamic "pipeline_config" {
    for_each = lookup(each.value, "functions", null) != null ? [true] : []

    content {
      functions = [for k in each.value.functions :
      contains(keys(aws_appsync_function.this), k) ? aws_appsync_function.this[k].function_id : k]
    }
  }

  dynamic "caching_config" {
    for_each = lookup(each.value, "caching_keys", null) != null ? [true] : []

    content {
      caching_keys = each.value.caching_keys
      ttl          = lookup(each.value, "caching_ttl", var.resolver_caching_ttl)
    }
  }

  max_batch_size = lookup(each.value, "max_batch_size", null)
}

# Functions
resource "aws_appsync_function" "this" {
  for_each = { for k, v in var.functions : k => v if var.create_graphql_api == true }

  region = var.region

  api_id           = aws_appsync_graphql_api.this[0].id
  data_source      = lookup(each.value, "data_source", null)
  name             = each.key
  description      = lookup(each.value, "description", null)
  function_version = lookup(each.value, "function_version", try(each.value.code == null, false) ? "2018-05-29" : null)
  max_batch_size   = lookup(each.value, "max_batch_size", null)

  request_mapping_template  = lookup(each.value, "request_mapping_template", try(each.value.runtime.name == "APPSYNC_JS", false) ? null : "{}")
  response_mapping_template = lookup(each.value, "response_mapping_template", try(each.value.runtime.name == "APPSYNC_JS", false) ? null : "{}")

  code = try(each.value.code, null)

  dynamic "sync_config" {
    for_each = try([each.value.sync_config], [])

    content {
      conflict_detection = try(sync_config.value.conflict_detection, "NONE")
      conflict_handler   = try(sync_config.value.conflict_handler, "NONE")

      dynamic "lambda_conflict_handler_config" {
        for_each = try([each.value.sync_config.lambda_conflict_handler_config], [])
        content {
          lambda_conflict_handler_arn = try(lambda_conflict_handler_config.value.lambda_conflict_handler_arn, null)
        }
      }
    }
  }

  dynamic "runtime" {
    for_each = try([each.value.runtime], [])

    content {
      name            = runtime.value.name
      runtime_version = try(runtime.value.runtime_version, "1.0.0")
    }
  }

  depends_on = [aws_appsync_datasource.this]
}

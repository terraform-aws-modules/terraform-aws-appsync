locals {
  resolvers = var.create_graphql_api ? { for k, v in var.resolvers : k => merge(v, {
    type  = split(" ", k)[0]
    field = join(" ", slice(split(" ", k), 1, length(split(" ", k))))
  }) } : tomap({})
}

# GraphQL API
resource "aws_appsync_graphql_api" "this" {
  count = var.create_graphql_api ? 1 : 0

  name                = var.name
  authentication_type = var.authentication_type
  schema              = var.schema
  xray_enabled        = var.xray_enabled

  dynamic "log_config" {
    for_each = var.logging_enabled ? [true] : []

    content {
      cloudwatch_logs_role_arn = var.create_logs_role ? aws_iam_role.logs[0].arn : var.log_cloudwatch_logs_role_arn
      field_log_level          = var.log_field_log_level
      exclude_verbose_content  = var.log_exclude_verbose_content
    }
  }

  tags = merge({ Name = var.name }, var.graphql_api_tags)
}

# API Key
resource "aws_appsync_api_key" "this" {
  for_each = var.create_graphql_api && var.authentication_type == "API_KEY" ? var.api_keys : {}

  api_id      = aws_appsync_graphql_api.this[0].id
  description = each.key
  expires     = each.value
}

# Datasource
resource "aws_appsync_datasource" "this" {
  for_each = var.create_graphql_api ? var.datasources : {}

  api_id           = aws_appsync_graphql_api.this[0].id
  name             = each.key
  type             = each.value.type
  description      = lookup(each.value, "description", null)
  service_role_arn = lookup(each.value, "service_role_arn", tobool(lookup(each.value, "create_service_role", contains(["AWS_LAMBDA", "AMAZON_DYNAMODB", "AMAZON_ELASTICSEARCH"], each.value.type))) ? aws_iam_role.service_role[each.key].arn : null)

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
}

# Resolvers
resource "aws_appsync_resolver" "this" {
  for_each = local.resolvers

  api_id = aws_appsync_graphql_api.this[0].id
  type   = each.value.type
  field  = each.value.field
  kind   = lookup(each.value, "kind", null)

  request_template  = lookup(each.value, "request_template", tobool(lookup(each.value, "direct_lambda", false)) ? var.direct_lambda_request_template : "{}")
  response_template = lookup(each.value, "response_template", tobool(lookup(each.value, "direct_lambda", false)) ? var.direct_lambda_response_template : "{}")

  data_source = lookup(each.value, "data_source", null) != null ? aws_appsync_datasource.this[each.value.data_source].name : lookup(each.value, "data_source_arn", null)

  dynamic "pipeline_config" {
    for_each = lookup(each.value, "functions", null) != null ? [true] : []

    content {
      functions = each.value.functions
    }
  }

  dynamic "caching_config" {
    for_each = lookup(each.value, "caching_keys", null) != null ? [true] : []

    content {
      caching_keys = each.value.caching_keys
      ttl          = lookup(each.value, "caching_ttl", var.resolver_caching_ttl)
    }
  }
}

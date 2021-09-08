locals {
  service_roles_with_policies = var.create_graphql_api ? { for k, v in var.datasources : k => v if contains(["AWS_LAMBDA", "AMAZON_DYNAMODB", "AMAZON_ELASTICSEARCH"], v.type) && tobool(lookup(v, "create_service_role", true)) } : {}

  service_roles_with_policies_lambda = { for k, v in local.service_roles_with_policies : k => merge(v,
    {
      policy_statements = {
        lambda = {
          effect    = "Allow"
          actions   = lookup(v, "policy_actions", null) == null ? var.lambda_allowed_actions : v.policy_actions
          resources = [for _, f in ["%v", "%v:*"] : format(f, v.function_arn)]
        }
      }
    }
  ) if v.type == "AWS_LAMBDA" }

  service_roles_with_policies_dynamodb = { for k, v in local.service_roles_with_policies : k => merge(v,
    {
      policy_statements = {
        dynamodb = {
          effect    = "Allow"
          actions   = lookup(v, "policy_actions", null) == null ? var.dynamodb_allowed_actions : v.policy_actions
          resources = [for _, f in ["arn:aws:dynamodb:%v:%v:table/%v", "arn:aws:dynamodb:%v:%v:table/%v/*"] : format(f, v.region, lookup(v, "aws_account_id", data.aws_caller_identity.this.account_id), v.table_name)]
        }
      }
    }
  ) if v.type == "AMAZON_DYNAMODB" }

  service_roles_with_policies_elasticsearch = { for k, v in local.service_roles_with_policies : k => merge(v,
    {
      policy_statements = {
        elasticsearch = {
          effect    = "Allow"
          actions   = lookup(v, "policy_actions", null) == null ? var.elasticsearch_allowed_actions : v.policy_actions
          resources = [format("arn:aws:es:%v::domain/%v/*", v.region, v.endpoint)]
        }
      }
    }
  ) if v.type == "AMAZON_ELASTICSEARCH" }

  service_roles_with_specific_policies = merge(
    local.service_roles_with_policies_lambda,
    local.service_roles_with_policies_dynamodb,
    local.service_roles_with_policies_elasticsearch,
  )
}

data "aws_caller_identity" "this" {}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["appsync.amazonaws.com"]
    }
  }
}

# Logs
resource "aws_iam_role" "logs" {
  count = var.logging_enabled && var.create_logs_role ? 1 : 0

  name                 = coalesce(var.logs_role_name, "${var.name}-logs")
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
  permissions_boundary = var.iam_permissions_boundary

  tags = merge(var.tags, var.logs_role_tags)
}

resource "aws_iam_role_policy_attachment" "logs" {
  count = var.logging_enabled && var.create_logs_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppSyncPushToCloudWatchLogs"
  role       = aws_iam_role.logs[0].name
}

# Service role for datasource
resource "aws_iam_role" "service_role" {
  for_each = local.service_roles_with_specific_policies

  name                 = lookup(each.value, "service_role_name", "${each.key}-role")
  permissions_boundary = var.iam_permissions_boundary
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "this" {
  for_each = local.service_roles_with_specific_policies

  name   = "service-policy"
  role   = aws_iam_role.service_role[each.key].id
  policy = data.aws_iam_policy_document.service_policy[each.key].json
}

data "aws_iam_policy_document" "service_policy" {
  for_each = local.service_roles_with_specific_policies

  dynamic "statement" {
    for_each = each.value.policy_statements

    content {
      sid           = lookup(statement.value, "sid", replace(statement.key, "/[^0-9A-Za-z]*/", ""))
      effect        = lookup(statement.value, "effect", null)
      actions       = lookup(statement.value, "actions", null)
      not_actions   = lookup(statement.value, "not_actions", null)
      resources     = lookup(statement.value, "resources", null)
      not_resources = lookup(statement.value, "not_resources", null)

      dynamic "principals" {
        for_each = lookup(statement.value, "principals", [])
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = lookup(statement.value, "not_principals", [])
        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = lookup(statement.value, "condition", [])
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

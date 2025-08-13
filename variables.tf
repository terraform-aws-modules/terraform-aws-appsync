variable "create_graphql_api" {
  description = "Whether to create GraphQL API"
  type        = bool
  default     = true
}

variable "logging_enabled" {
  description = "Whether to enable Cloudwatch logging on GraphQL API"
  type        = bool
  default     = false
}

variable "domain_name_association_enabled" {
  description = "Whether to enable domain name association on GraphQL API"
  type        = bool
  default     = false
}

variable "caching_enabled" {
  description = "Whether caching with Elasticache is enabled."
  type        = bool
  default     = false
}

variable "xray_enabled" {
  description = "Whether tracing with X-ray is enabled."
  type        = bool
  default     = false
}

variable "name" {
  description = "Name of GraphQL API"
  type        = string
  default     = ""
}

variable "schema" {
  description = "The schema definition, in GraphQL schema language format. Terraform cannot perform drift detection of this configuration."
  type        = string
  default     = ""
}

variable "visibility" {
  description = "The API visibility. Valid values: GLOBAL, PRIVATE."
  type        = string
  default     = null
}

variable "authentication_type" {
  description = "The authentication type to use by GraphQL API"
  type        = string
  default     = "API_KEY"
}

variable "create_logs_role" {
  description = "Whether to create service role for Cloudwatch logs"
  type        = bool
  default     = true
}

variable "logs_role_name" {
  description = "Name of IAM role to create for Cloudwatch logs"
  type        = string
  default     = null
}

variable "logs_role_description" {
  description = "Description for the IAM role to create for Cloudwatch logs"
  type        = string
  default     = null
}

variable "log_cloudwatch_logs_role_arn" {
  description = "Amazon Resource Name of the service role that AWS AppSync will assume to publish to Amazon CloudWatch logs in your account."
  type        = string
  default     = null
}

variable "log_field_log_level" {
  description = "Field logging level. Valid values: ALL, ERROR, NONE."
  type        = string
  default     = null
}

variable "log_exclude_verbose_content" {
  description = "Set to TRUE to exclude sections that contain information such as headers, context, and evaluated mapping templates, regardless of logging level."
  type        = bool
  default     = false
}

variable "lambda_authorizer_config" {
  description = "Nested argument containing Lambda authorizer configuration."
  type        = map(string)
  default     = {}
}

variable "openid_connect_config" {
  description = "Nested argument containing OpenID Connect configuration."
  type        = map(string)
  default     = {}
}

variable "user_pool_config" {
  description = "The Amazon Cognito User Pool configuration."
  type        = map(string)
  default     = {}
}

variable "additional_authentication_provider" {
  description = "One or more additional authentication providers for the GraphqlApi."
  type        = any
  default     = {}
}

variable "enhanced_metrics_config" {
  description = "Nested argument containing Lambda Ehanced metrics configuration."
  type        = map(string)
  default     = {}
}

variable "graphql_api_tags" {
  description = "Map of tags to add to GraphQL API"
  type        = map(string)
  default     = {}
}

variable "logs_role_tags" {
  description = "Map of tags to add to Cloudwatch logs IAM role"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Map of tags to add to all GraphQL resources created by this module"
  type        = map(string)
  default     = {}
}

# API Association & Domain Name
variable "domain_name" {
  description = "The domain name that AppSync gets associated with."
  type        = string
  default     = ""
}

variable "domain_name_description" {
  description = "A description of the Domain Name."
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "The Amazon Resource Name (ARN) of the certificate."
  type        = string
  default     = ""
}

# API Cache
variable "caching_behavior" {
  description = "Caching behavior."
  type        = string
  default     = "FULL_REQUEST_CACHING"

  validation {
    condition = contains([
      "FULL_REQUEST_CACHING",
      "PER_RESOLVER_CACHING"
    ], var.caching_behavior)
    error_message = "Allowed values for input_parameter are \"FULL_REQUEST_CACHING\", or \"PER_RESOLVER_CACHING\"."
  }
}

variable "cache_type" {
  description = "The cache instance type."
  type        = string
  default     = "SMALL"

  validation {
    condition = contains([
      "SMALL",
      "MEDIUM",
      "LARGE",
      "XLARGE",
      "LARGE_2X",
      "LARGE_4X",
      "LARGE_8X",
      "LARGE_12X",
      "T2_SMALL",
      "T2_MEDIUM",
      "R4_LARGE",
      "R4_XLARGE",
      "R4_2XLARGE",
      "R4_4XLARGE",
      "R4_8XLARGE"
    ], var.cache_type)
    error_message = "Allowed values for input_parameter are \"SMALL\", \"MEDIUM\", \"LARGE\", \"XLARGE\", \"LARGE_2X\", \"LARGE_4X\", \"LARGE_8X\", \"LARGE_12X\", \"T2_SMALL\", \"T2_MEDIUM\", \"R4_LARGE\", \"R4_XLARGE\", \"R4_2XLARGE\", \"R4_4XLARGE\", or \"R4_8XLARGE\"."
  }
}

variable "cache_ttl" {
  description = "TTL in seconds for cache entries"
  type        = number
  default     = 1
}

variable "cache_at_rest_encryption_enabled" {
  description = "At-rest encryption flag for cache."
  type        = bool
  default     = false
}

variable "cache_transit_encryption_enabled" {
  description = "Transit encryption flag when connecting to cache."
  type        = bool
  default     = false
}

# API Keys
variable "api_keys" {
  description = "Map of API keys to create"
  type        = map(string)
  default     = {}
}


# IAM service roles
variable "lambda_allowed_actions" {
  description = "List of allowed IAM actions for datasources type AWS_LAMBDA"
  type        = list(string)
  default     = ["lambda:invokeFunction"]
}

variable "dynamodb_allowed_actions" {
  description = "List of allowed IAM actions for datasources type AMAZON_DYNAMODB"
  type        = list(string)
  default     = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem", "dynamodb:UpdateItem", "dynamodb:Query", "dynamodb:Scan", "dynamodb:BatchGetItem", "dynamodb:BatchWriteItem"]
}

variable "elasticsearch_allowed_actions" {
  description = "List of allowed IAM actions for datasources type AMAZON_ELASTICSEARCH"
  type        = list(string)
  default     = ["es:ESHttpDelete", "es:ESHttpHead", "es:ESHttpGet", "es:ESHttpPost", "es:ESHttpPut"]
}

variable "opensearchservice_allowed_actions" {
  description = "List of allowed IAM actions for datasources type AMAZON_OPENSEARCH_SERVICE"
  type        = list(string)
  default     = ["es:ESHttpDelete", "es:ESHttpHead", "es:ESHttpGet", "es:ESHttpPost", "es:ESHttpPut"]
}

variable "eventbridge_allowed_actions" {
  description = "List of allowed IAM actions for datasources type AMAZON_EVENTBRIDGE"
  type        = list(string)
  default     = ["events:PutEvents"]
}

variable "relational_database_allowed_actions" {
  description = "List of allowed IAM actions for datasources type RELATIONAL_DATABASE"
  type        = list(string)
  default     = ["rds-data:BatchExecuteStatement", "rds-data:BeginTransaction", "rds-data:CommitTransaction", "rds-data:ExecuteStatement", "rds-data:RollbackTransaction"]
}

variable "secrets_manager_allowed_actions" {
  description = "List of allowed IAM actions for secrets manager datasources type RELATIONAL_DATABASE"
  type        = list(string)
  default     = ["secretsmanager:GetSecretValue"]
}

variable "iam_permissions_boundary" {
  description = "ARN for iam permissions boundary"
  type        = string
  default     = null
}

# VTL request/response templates
variable "direct_lambda_request_template" {
  description = "VTL request template for the direct lambda integrations"
  type        = string
  default     = <<-EOF
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
}

variable "direct_lambda_response_template" {
  description = "VTL response template for the direct lambda integrations"
  type        = string
  default     = <<-EOF
  $util.toJson($ctx.result)
  EOF
}

variable "resolver_caching_ttl" {
  description = "Default caching TTL for resolvers when caching is enabled"
  type        = number
  default     = 60
}

# Datasources
variable "datasources" {
  description = "Map of datasources to create"
  type        = any
  default     = {}
}

# Resolvers
variable "resolvers" {
  description = "Map of resolvers to create"
  type        = any
  default     = {}
}

# Functions
variable "functions" {
  description = "Map of functions to create"
  type        = any
  default     = {}
}
variable "introspection_config" {
  description = "Whether to enable or disable introspection of the GraphQL API."
  type        = string
  default     = null
}

variable "query_depth_limit" {
  description = "The maximum depth a query can have in a single request."
  type        = number
  default     = null
}

variable "resolver_count_limit" {
  description = "The maximum number of resolvers that can be invoked in a single request."
  type        = number
  default     = null
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the region set in the provider configuration"
  type        = string
  default     = null
}

# AWS AppSync Terraform module

Terraform module which creates AWS AppSync resources and connects them together.

This Terraform module is part of [serverless.tf framework](https://serverless.tf), which aims to simplify all operations when working with the serverless in Terraform.

## Usage

### Complete AppSync with datasources and resolvers

```hcl
module "appsync" {
  source = "terraform-aws-modules/appsync/aws"

  name = "dev-appsync"

  schema = file("schema.graphql")

  visibility = "GLOBAL"

  api_keys = {
    default = null # such key will expire in 7 days
  }

  additional_authentication_provider = {
    iam = {
      authentication_type = "AWS_IAM"
    }

    openid_connect_1 = {
      authentication_type = "OPENID_CONNECT"

      openid_connect_config = {
        issuer    = "https://www.issuer1.com/"
        client_id = "client_id1"
      }
    }
  }

  datasources = {
    registry_terraform_io = {
      type     = "HTTP"
      endpoint = "https://registry.terraform.io"
    }

    lambda_create_zip = {
      type         = "AWS_LAMBDA"
      function_arn = "arn:aws:lambda:eu-west-1:135367859850:function:index_1"
    }

    dynamodb1 = {
      type       = "AMAZON_DYNAMODB"
      table_name = "my-table"
      region     = "eu-west-1"
    }

    elasticsearch1 = {
      type     = "AMAZON_ELASTICSEARCH"
      endpoint = "https://search-my-domain.eu-west-1.es.amazonaws.com"
      region   = "eu-west-1"
    }

    opensearchservice1 = {
      type     = "AMAZON_OPENSEARCH_SERVICE"
      endpoint = "https://opensearch-my-domain.eu-west-1.es.amazonaws.com"
      region   = "eu-west-1"
    }

    eventbridge1 = {
      type          = "AMAZON_EVENTBRIDGE"
      event_bus_arn = "arn:aws:events:us-west-1:135367859850:event-bus/eventbridge1"
    }

    rds1 = {
      type          = "RELATIONAL_DATABASE"
      cluster_arn   = "arn:aws:rds:us-west-1:135367859850:cluster:rds1"
      secret_arn    = "arn:aws:secretsmanager:us-west-1:135367859850:secret:rds-secret1"
      database_name = "mydb"
      schema        = "myschema"
    }
  }

  resolvers = {
    "Query.getZip" = {
      data_source   = "lambda_create_zip"
      direct_lambda = true
    }

    "Query.getModuleFromRegistry" = {
      data_source       = "registry_terraform_io"
      request_template  = file("vtl-templates/request.Query.getModuleFromRegistry.vtl")
      response_template = file("vtl-templates/response.Query.getModuleFromRegistry.vtl")
    }
  }
}
```

## Conditional creation

Sometimes you need to have a way to create resources conditionally but Terraform 0.12 does not allow usage of `count` inside `module` block, so the solution is to specify `create_graphql_api` argument.

```hcl
module "appsync" {
  source = "terraform-aws-modules/appsync/aws"

  create_graphql_api = false # to disable all resources

  # ... omitted
}
```

## Relationship between Data-Source and Resolver resources

`datasources` define keys which can be referenced in `resolvers`. For initial configuration and parameters updates Terraform is able to understand the order of resources correctly.

In order to change name of keys in both places (eg from `lambda-old` to `lambda-new`), you will need to change key in both variables, and then run Terraform with partial configuration (using `-target`) to handle the migration in the `aws_appsync_resolver` resource (eg, `Post.id`):

```shell
# Create new resources and update resolver
$ terraform apply -target="module.appsync.aws_appsync_resolver.this[\"Post.id\"]" -target="module.appsync.aws_appsync_datasource.this[\"lambda-new\"]" -target="module.appsync.aws_iam_role.service_role[\"lambda-new\"]" -target="module.appsync.aws_iam_role_policy.this[\"lambda-new\"]"

# Delete orphan resources ("lambda-old")
$ terraform apply
```

## Examples

- [Complete](https://github.com/terraform-aws-modules/terraform-aws-appsync/tree/master/examples/complete) - Create AppSync with datasources, resolvers, and authorization providers in various combinations.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appsync_api_cache.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_api_cache) | resource |
| [aws_appsync_api_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_api_key) | resource |
| [aws_appsync_datasource.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_datasource) | resource |
| [aws_appsync_domain_name.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_domain_name) | resource |
| [aws_appsync_domain_name_api_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_domain_name_api_association) | resource |
| [aws_appsync_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_function) | resource |
| [aws_appsync_graphql_api.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_graphql_api) | resource |
| [aws_appsync_resolver.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_resolver) | resource |
| [aws_iam_role.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.service_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_authentication_provider"></a> [additional\_authentication\_provider](#input\_additional\_authentication\_provider) | One or more additional authentication providers for the GraphqlApi. | `any` | `{}` | no |
| <a name="input_api_keys"></a> [api\_keys](#input\_api\_keys) | Map of API keys to create | `map(string)` | `{}` | no |
| <a name="input_authentication_type"></a> [authentication\_type](#input\_authentication\_type) | The authentication type to use by GraphQL API | `string` | `"API_KEY"` | no |
| <a name="input_cache_at_rest_encryption_enabled"></a> [cache\_at\_rest\_encryption\_enabled](#input\_cache\_at\_rest\_encryption\_enabled) | At-rest encryption flag for cache. | `bool` | `false` | no |
| <a name="input_cache_transit_encryption_enabled"></a> [cache\_transit\_encryption\_enabled](#input\_cache\_transit\_encryption\_enabled) | Transit encryption flag when connecting to cache. | `bool` | `false` | no |
| <a name="input_cache_ttl"></a> [cache\_ttl](#input\_cache\_ttl) | TTL in seconds for cache entries | `number` | `1` | no |
| <a name="input_cache_type"></a> [cache\_type](#input\_cache\_type) | The cache instance type. | `string` | `"SMALL"` | no |
| <a name="input_caching_behavior"></a> [caching\_behavior](#input\_caching\_behavior) | Caching behavior. | `string` | `"FULL_REQUEST_CACHING"` | no |
| <a name="input_caching_enabled"></a> [caching\_enabled](#input\_caching\_enabled) | Whether caching with Elasticache is enabled. | `bool` | `false` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | The Amazon Resource Name (ARN) of the certificate. | `string` | `""` | no |
| <a name="input_create_graphql_api"></a> [create\_graphql\_api](#input\_create\_graphql\_api) | Whether to create GraphQL API | `bool` | `true` | no |
| <a name="input_create_logs_role"></a> [create\_logs\_role](#input\_create\_logs\_role) | Whether to create service role for Cloudwatch logs | `bool` | `true` | no |
| <a name="input_datasources"></a> [datasources](#input\_datasources) | Map of datasources to create | `any` | `{}` | no |
| <a name="input_direct_lambda_request_template"></a> [direct\_lambda\_request\_template](#input\_direct\_lambda\_request\_template) | VTL request template for the direct lambda integrations | `string` | `"{\n  \"version\" : \"2017-02-28\",\n  \"operation\": \"Invoke\",\n  \"payload\": {\n    \"arguments\": $util.toJson($ctx.arguments),\n    \"identity\": $util.toJson($ctx.identity),\n    \"source\": $util.toJson($ctx.source),\n    \"request\": $util.toJson($ctx.request),\n    \"prev\": $util.toJson($ctx.prev),\n    \"info\": {\n        \"selectionSetList\": $util.toJson($ctx.info.selectionSetList),\n        \"selectionSetGraphQL\": $util.toJson($ctx.info.selectionSetGraphQL),\n        \"parentTypeName\": $util.toJson($ctx.info.parentTypeName),\n        \"fieldName\": $util.toJson($ctx.info.fieldName),\n        \"variables\": $util.toJson($ctx.info.variables)\n    },\n    \"stash\": $util.toJson($ctx.stash)\n  }\n}\n"` | no |
| <a name="input_direct_lambda_response_template"></a> [direct\_lambda\_response\_template](#input\_direct\_lambda\_response\_template) | VTL response template for the direct lambda integrations | `string` | `"$util.toJson($ctx.result)\n"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain name that AppSync gets associated with. | `string` | `""` | no |
| <a name="input_domain_name_association_enabled"></a> [domain\_name\_association\_enabled](#input\_domain\_name\_association\_enabled) | Whether to enable domain name association on GraphQL API | `bool` | `false` | no |
| <a name="input_domain_name_description"></a> [domain\_name\_description](#input\_domain\_name\_description) | A description of the Domain Name. | `string` | `null` | no |
| <a name="input_dynamodb_allowed_actions"></a> [dynamodb\_allowed\_actions](#input\_dynamodb\_allowed\_actions) | List of allowed IAM actions for datasources type AMAZON\_DYNAMODB | `list(string)` | <pre>[<br/>  "dynamodb:GetItem",<br/>  "dynamodb:PutItem",<br/>  "dynamodb:DeleteItem",<br/>  "dynamodb:UpdateItem",<br/>  "dynamodb:Query",<br/>  "dynamodb:Scan",<br/>  "dynamodb:BatchGetItem",<br/>  "dynamodb:BatchWriteItem"<br/>]</pre> | no |
| <a name="input_elasticsearch_allowed_actions"></a> [elasticsearch\_allowed\_actions](#input\_elasticsearch\_allowed\_actions) | List of allowed IAM actions for datasources type AMAZON\_ELASTICSEARCH | `list(string)` | <pre>[<br/>  "es:ESHttpDelete",<br/>  "es:ESHttpHead",<br/>  "es:ESHttpGet",<br/>  "es:ESHttpPost",<br/>  "es:ESHttpPut"<br/>]</pre> | no |
| <a name="input_enhanced_metrics_config"></a> [enhanced\_metrics\_config](#input\_enhanced\_metrics\_config) | Nested argument containing Lambda Ehanced metrics configuration. | `map(string)` | `{}` | no |
| <a name="input_eventbridge_allowed_actions"></a> [eventbridge\_allowed\_actions](#input\_eventbridge\_allowed\_actions) | List of allowed IAM actions for datasources type AMAZON\_EVENTBRIDGE | `list(string)` | <pre>[<br/>  "events:PutEvents"<br/>]</pre> | no |
| <a name="input_functions"></a> [functions](#input\_functions) | Map of functions to create | `any` | `{}` | no |
| <a name="input_graphql_api_tags"></a> [graphql\_api\_tags](#input\_graphql\_api\_tags) | Map of tags to add to GraphQL API | `map(string)` | `{}` | no |
| <a name="input_iam_permissions_boundary"></a> [iam\_permissions\_boundary](#input\_iam\_permissions\_boundary) | ARN for iam permissions boundary | `string` | `null` | no |
| <a name="input_introspection_config"></a> [introspection\_config](#input\_introspection\_config) | Whether to enable or disable introspection of the GraphQL API. | `string` | `null` | no |
| <a name="input_lambda_allowed_actions"></a> [lambda\_allowed\_actions](#input\_lambda\_allowed\_actions) | List of allowed IAM actions for datasources type AWS\_LAMBDA | `list(string)` | <pre>[<br/>  "lambda:invokeFunction"<br/>]</pre> | no |
| <a name="input_lambda_authorizer_config"></a> [lambda\_authorizer\_config](#input\_lambda\_authorizer\_config) | Nested argument containing Lambda authorizer configuration. | `map(string)` | `{}` | no |
| <a name="input_log_cloudwatch_logs_role_arn"></a> [log\_cloudwatch\_logs\_role\_arn](#input\_log\_cloudwatch\_logs\_role\_arn) | Amazon Resource Name of the service role that AWS AppSync will assume to publish to Amazon CloudWatch logs in your account. | `string` | `null` | no |
| <a name="input_log_exclude_verbose_content"></a> [log\_exclude\_verbose\_content](#input\_log\_exclude\_verbose\_content) | Set to TRUE to exclude sections that contain information such as headers, context, and evaluated mapping templates, regardless of logging level. | `bool` | `false` | no |
| <a name="input_log_field_log_level"></a> [log\_field\_log\_level](#input\_log\_field\_log\_level) | Field logging level. Valid values: ALL, ERROR, NONE. | `string` | `null` | no |
| <a name="input_logging_enabled"></a> [logging\_enabled](#input\_logging\_enabled) | Whether to enable Cloudwatch logging on GraphQL API | `bool` | `false` | no |
| <a name="input_logs_role_description"></a> [logs\_role\_description](#input\_logs\_role\_description) | Description for the IAM role to create for Cloudwatch logs | `string` | `null` | no |
| <a name="input_logs_role_name"></a> [logs\_role\_name](#input\_logs\_role\_name) | Name of IAM role to create for Cloudwatch logs | `string` | `null` | no |
| <a name="input_logs_role_tags"></a> [logs\_role\_tags](#input\_logs\_role\_tags) | Map of tags to add to Cloudwatch logs IAM role | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of GraphQL API | `string` | `""` | no |
| <a name="input_openid_connect_config"></a> [openid\_connect\_config](#input\_openid\_connect\_config) | Nested argument containing OpenID Connect configuration. | `map(string)` | `{}` | no |
| <a name="input_opensearchservice_allowed_actions"></a> [opensearchservice\_allowed\_actions](#input\_opensearchservice\_allowed\_actions) | List of allowed IAM actions for datasources type AMAZON\_OPENSEARCH\_SERVICE | `list(string)` | <pre>[<br/>  "es:ESHttpDelete",<br/>  "es:ESHttpHead",<br/>  "es:ESHttpGet",<br/>  "es:ESHttpPost",<br/>  "es:ESHttpPut"<br/>]</pre> | no |
| <a name="input_query_depth_limit"></a> [query\_depth\_limit](#input\_query\_depth\_limit) | The maximum depth a query can have in a single request. | `number` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the region set in the provider configuration | `string` | `null` | no |
| <a name="input_relational_database_allowed_actions"></a> [relational\_database\_allowed\_actions](#input\_relational\_database\_allowed\_actions) | List of allowed IAM actions for datasources type RELATIONAL\_DATABASE | `list(string)` | <pre>[<br/>  "rds-data:BatchExecuteStatement",<br/>  "rds-data:BeginTransaction",<br/>  "rds-data:CommitTransaction",<br/>  "rds-data:ExecuteStatement",<br/>  "rds-data:RollbackTransaction"<br/>]</pre> | no |
| <a name="input_resolver_caching_ttl"></a> [resolver\_caching\_ttl](#input\_resolver\_caching\_ttl) | Default caching TTL for resolvers when caching is enabled | `number` | `60` | no |
| <a name="input_resolver_count_limit"></a> [resolver\_count\_limit](#input\_resolver\_count\_limit) | The maximum number of resolvers that can be invoked in a single request. | `number` | `null` | no |
| <a name="input_resolvers"></a> [resolvers](#input\_resolvers) | Map of resolvers to create | `any` | `{}` | no |
| <a name="input_schema"></a> [schema](#input\_schema) | The schema definition, in GraphQL schema language format. Terraform cannot perform drift detection of this configuration. | `string` | `""` | no |
| <a name="input_secrets_manager_allowed_actions"></a> [secrets\_manager\_allowed\_actions](#input\_secrets\_manager\_allowed\_actions) | List of allowed IAM actions for secrets manager datasources type RELATIONAL\_DATABASE | `list(string)` | <pre>[<br/>  "secretsmanager:GetSecretValue"<br/>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to add to all GraphQL resources created by this module | `map(string)` | `{}` | no |
| <a name="input_user_pool_config"></a> [user\_pool\_config](#input\_user\_pool\_config) | The Amazon Cognito User Pool configuration. | `map(string)` | `{}` | no |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | The API visibility. Valid values: GLOBAL, PRIVATE. | `string` | `null` | no |
| <a name="input_xray_enabled"></a> [xray\_enabled](#input\_xray\_enabled) | Whether tracing with X-ray is enabled. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_appsync_api_key_id"></a> [appsync\_api\_key\_id](#output\_appsync\_api\_key\_id) | Map of API Key ID (Formatted as ApiId:Key) |
| <a name="output_appsync_api_key_key"></a> [appsync\_api\_key\_key](#output\_appsync\_api\_key\_key) | Map of API Keys |
| <a name="output_appsync_datasource_arn"></a> [appsync\_datasource\_arn](#output\_appsync\_datasource\_arn) | Map of ARNs of datasources |
| <a name="output_appsync_domain_hosted_zone_id"></a> [appsync\_domain\_hosted\_zone\_id](#output\_appsync\_domain\_hosted\_zone\_id) | The ID of your Amazon Route 53 hosted zone. |
| <a name="output_appsync_domain_id"></a> [appsync\_domain\_id](#output\_appsync\_domain\_id) | The Appsync Domain Name. |
| <a name="output_appsync_domain_name"></a> [appsync\_domain\_name](#output\_appsync\_domain\_name) | The domain name that AppSync provides. |
| <a name="output_appsync_function_arn"></a> [appsync\_function\_arn](#output\_appsync\_function\_arn) | Map of ARNs of functions |
| <a name="output_appsync_function_function_id"></a> [appsync\_function\_function\_id](#output\_appsync\_function\_function\_id) | Map of function IDs of functions |
| <a name="output_appsync_function_id"></a> [appsync\_function\_id](#output\_appsync\_function\_id) | Map of IDs of functions |
| <a name="output_appsync_graphql_api_arn"></a> [appsync\_graphql\_api\_arn](#output\_appsync\_graphql\_api\_arn) | ARN of GraphQL API |
| <a name="output_appsync_graphql_api_fqdns"></a> [appsync\_graphql\_api\_fqdns](#output\_appsync\_graphql\_api\_fqdns) | Map of FQDNs associated with the API (no protocol and path) |
| <a name="output_appsync_graphql_api_id"></a> [appsync\_graphql\_api\_id](#output\_appsync\_graphql\_api\_id) | ID of GraphQL API |
| <a name="output_appsync_graphql_api_uris"></a> [appsync\_graphql\_api\_uris](#output\_appsync\_graphql\_api\_uris) | Map of URIs associated with the API |
| <a name="output_appsync_resolver_arn"></a> [appsync\_resolver\_arn](#output\_appsync\_resolver\_arn) | Map of ARNs of resolvers |
<!-- END_TF_DOCS -->

## Authors

Module managed by [Anton Babenko](https://github.com/antonbabenko). Check out [serverless.tf](https://serverless.tf) to learn more about doing serverless with Terraform.

Please reach out to [Betajob](https://www.betajob.com/) if you are looking for commercial support for your Terraform, AWS, or serverless project.

## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-appsync/tree/master/LICENSE) for full details.

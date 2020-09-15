# AWS AppSync Terraform module

Terraform module which creates AWS AppSync resources and connects them together.

These types of resources supported:

* [GraphQL API](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_graphql_api)
* [API Key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_api_key)
* [DataSource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_datasource)
* [Resolver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_resolver)

Not supported, yet:
* [Function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_function)


This Terraform module is part of [serverless.tf framework](https://serverless.tf), which aims to simplify all operations when working with the serverless in Terraform.


## Usage

### Complete AppSync with datasources and resolvers

```hcl
module "appsync" {
  source = "terraform-aws-modules/appsync/aws"

  name = "dev-appsync"

  schema = file("schema.graphql")

  api_keys = {
    default = null # such key will expire in 7 days
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

## Limitations

- [ ] Missing support for several authentication providers in GraphQL API resource


## Examples

* [Complete](https://github.com/terraform-aws-modules/terraform-aws-appsync/tree/master/examples/complete) - Create AppSync with datasources and resolvers in various combinations


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.6, < 0.14 |
| aws | >= 2.46, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.46, < 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| api\_keys | Map of API keys to create | `map(string)` | `{}` | no |
| authentication\_type | The authentication type to use by GraphQL API | `string` | `"API_KEY"` | no |
| create\_graphql\_api | Whether to create GraphQL API | `bool` | `true` | no |
| create\_logs\_role | Whether to create service role for Cloudwatch logs | `bool` | `true` | no |
| datasources | Map of datasources to create | `any` | `{}` | no |
| direct\_lambda\_request\_template | VTL request template for the direct lambda integrations | `string` | `"{\n  \"version\" : \"2017-02-28\",\n  \"operation\": \"Invoke\",\n  \"payload\": {\n    \"arguments\": $util.toJson($ctx.arguments),\n    \"identity\": $util.toJson($ctx.identity),\n    \"source\": $util.toJson($ctx.source),\n    \"request\": $util.toJson($ctx.request),\n    \"prev\": $util.toJson($ctx.prev),\n    \"info\": {\n        \"selectionSetList\": $util.toJson($ctx.info.selectionSetList),\n        \"selectionSetGraphQL\": $util.toJson($ctx.info.selectionSetGraphQL),\n        \"parentTypeName\": $util.toJson($ctx.info.parentTypeName),\n        \"fieldName\": $util.toJson($ctx.info.fieldName),\n        \"variables\": $util.toJson($ctx.info.variables)\n    },\n    \"stash\": $util.toJson($ctx.stash)\n  }\n}\n"` | no |
| direct\_lambda\_response\_template | VTL response template for the direct lambda integrations | `string` | `"$util.toJson($ctx.result)\n"` | no |
| dynamodb\_allowed\_actions | List of allowed IAM actions for datasources type AMAZON\_DYNAMODB | `list(string)` | <pre>[<br>  "dynamodb:GetItem",<br>  "dynamodb:PutItem",<br>  "dynamodb:DeleteItem",<br>  "dynamodb:UpdateItem",<br>  "dynamodb:Query",<br>  "dynamodb:Scan",<br>  "dynamodb:BatchGetItem",<br>  "dynamodb:BatchWriteItem"<br>]</pre> | no |
| elasticsearch\_allowed\_actions | List of allowed IAM actions for datasources type AMAZON\_ELASTICSEARCH | `list(string)` | <pre>[<br>  "es:ESHttpDelete",<br>  "es:ESHttpHead",<br>  "es:ESHttpGet",<br>  "es:ESHttpPost",<br>  "es:ESHttpPut"<br>]</pre> | no |
| graphql\_api\_tags | Map of tags to add to GraphQL API | `map(string)` | `{}` | no |
| lambda\_allowed\_actions | List of allowed IAM actions for datasources type AWS\_LAMBDA | `list(string)` | <pre>[<br>  "lambda:invokeFunction"<br>]</pre> | no |
| log\_cloudwatch\_logs\_role\_arn | Amazon Resource Name of the service role that AWS AppSync will assume to publish to Amazon CloudWatch logs in your account. | `string` | `null` | no |
| log\_exclude\_verbose\_content | Set to TRUE to exclude sections that contain information such as headers, context, and evaluated mapping templates, regardless of logging level. | `bool` | `false` | no |
| log\_field\_log\_level | Field logging level. Valid values: ALL, ERROR, NONE. | `string` | `null` | no |
| logging\_enabled | Whether to enable Cloudwatch logging on GraphQL API | `bool` | `false` | no |
| logs\_role\_name | Name of IAM role to create for Cloudwatch logs | `string` | `null` | no |
| logs\_role\_tags | Map of tags to add to Cloudwatch logs IAM role | `map(string)` | `{}` | no |
| name | Name of GraphQL API | `string` | `""` | no |
| resolver\_caching\_ttl | Default caching TTL for resolvers when caching is enabled | `number` | `60` | no |
| resolvers | Map of resolvers to create | `any` | `{}` | no |
| schema | The schema definition, in GraphQL schema language format. Terraform cannot perform drift detection of this configuration. | `string` | `""` | no |
| tags | Map of tags to add to all GraphQL resources created by this module | `map(string)` | `{}` | no |
| xray\_enabled | Whether tracing with X-ray is enabled. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| this\_appsync\_api\_key\_id | Map of API Key ID (Formatted as ApiId:Key) |
| this\_appsync\_api\_key\_key | Map of API Keys |
| this\_appsync\_datasource\_arn | Map of ARNs of datasources |
| this\_appsync\_graphql\_api\_arn | ARN of GraphQL API |
| this\_appsync\_graphql\_api\_fqdns | Map of FQDNs associated with the API (no protocol and path) |
| this\_appsync\_graphql\_api\_id | ID of GraphQL API |
| this\_appsync\_graphql\_api\_uris | Map of URIs associated with the API |
| this\_appsync\_resolver\_arn | Map of ARNs of resolvers |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module managed by [Anton Babenko](https://github.com/antonbabenko). Check out [serverless.tf](https://serverless.tf) to learn more about doing serverless with Terraform.

Please reach out to [Betajob](https://www.betajob.com/) if you are looking for commercial support for your Terraform, AWS, or serverless project.


## License

Apache 2 Licensed. See LICENSE for full details.

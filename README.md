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

### Event API (WebSocket) Configuration

AWS AppSync Event API provides serverless WebSocket pub/sub messaging for real-time communication. This module supports creating an Event API **instead of** a GraphQL API (they are mutually exclusive within a single module instance).

**Documentation:** [AWS AppSync Event API Guide](https://docs.aws.amazon.com/appsync/latest/eventapi/)

#### Basic Event API Example

```hcl
module "appsync_event_api" {
  source = "terraform-aws-modules/appsync/aws"

  # Create Event API only (not GraphQL)
  create_graphql_api   = false
  create_websocket_api = true

  name   = "my-event-api"
  region = "us-east-1"

  # Authentication configuration
  event_config = {
    auth_provider = {
      auth_type = "API_KEY"
    }
    connection_auth_modes = [
      { auth_type = "API_KEY" },
      { auth_type = "AWS_IAM" }
    ]
    default_publish_auth_modes = [
      { auth_type = "API_KEY" }
    ]
    default_subscribe_auth_modes = [
      { auth_type = "API_KEY" }
    ]
  }

  # Channel namespaces with handlers
  channel_namespaces = {
    "chat" = {
      code_handlers = file("${path.module}/handlers/chat.js")
    }
  }

  # CloudWatch Logs
  logging_enabled     = true
  log_field_log_level = "ALL"

  tags = {
    Environment = "production"
  }
}
```

#### Authentication Configuration

The `event_config` variable configures authentication for Event APIs. It supports all AWS AppSync authentication types:

**Supported Authentication Types:**

- `API_KEY` - Simple API key authentication
- `AWS_IAM` - IAM-based authentication with SigV4 signing
- `AWS_COGNITO_USER_POOLS` - Amazon Cognito User Pools
- `OPENID_CONNECT` - OpenID Connect providers
- `AWS_LAMBDA` - Custom Lambda authorizers

**Structure:**

```hcl
event_config = {
  # Primary authentication provider
  auth_provider = {
    auth_type = "API_KEY"  # or AWS_IAM, AWS_COGNITO_USER_POOLS, etc.

    # Optional: Cognito configuration (required when auth_type is AWS_COGNITO_USER_POOLS)
    cognito_config = {
      user_pool_id        = "us-east-1_ABC123"
      aws_region          = "us-east-1"
      app_id_client_regex = null
    }

    # Optional: OIDC configuration (required when auth_type is OPENID_CONNECT)
    oidc_config = {
      issuer    = "https://accounts.google.com"
      client_id = "your-client-id"
      auth_ttl  = 3600
      iat_ttl   = 3600
    }

    # Optional: Lambda authorizer configuration (required when auth_type is AWS_LAMBDA)
    lambda_authorizer_config = {
      authorizer_uri                   = "arn:aws:lambda:us-east-1:123456789012:function:authorizer"
      authorizer_result_ttl_in_seconds = 300
      identity_validation_expression   = null
    }
  }

  # Authentication modes for WebSocket connection establishment
  connection_auth_modes = [
    { auth_type = "API_KEY" },
    { auth_type = "AWS_IAM" }
  ]

  # Authentication modes for publishing events
  default_publish_auth_modes = [
    { auth_type = "API_KEY" }
  ]

  # Authentication modes for subscribing to channels
  default_subscribe_auth_modes = [
    { auth_type = "API_KEY" }
  ]
}
```

#### Channel Namespaces

Channel namespaces organize pub/sub channels and define event handlers for message processing.

**Channel Naming Pattern:** `/namespace/channel-name`

Examples:

- `/chat/room-123` - Chat room channel
- `/notifications/user-456` - User notification channel
- `/presence/global` - Global presence channel

**Configuration:**

```hcl
channel_namespaces = {
  # Namespace with JavaScript code handlers
  "chat" = {
    code_handlers = file("${path.module}/handlers/chat.js")
  }

  # Namespace with Lambda handlers
  "notifications" = {
    handler_configs = [
      {
        handler_arn = aws_lambda_function.notification_handler.arn
      }
    ]
  }

  # Namespace with inline JavaScript code
  "presence" = {
    code_handlers = <<-JS
      export function onPublish(ctx) {
        return { action: "ALLOW", data: ctx.args.data };
      }
      export function onSubscribe(ctx) {
        return { action: "ALLOW" };
      }
    JS
  }
}
```

#### Handler Code Management

**JavaScript Code Handlers:**

Handlers must export `onPublish` and `onSubscribe` functions:

```javascript
/**
 * Runtime: APPSYNC_JS 1.0.0
 */

// Handles publish events (when messages are sent)
export function onPublish(
  ctx,
) {
  const {
    data,
  } =
    ctx.args;
  const {
    identity,
    info,
  } =
    ctx;

  // Your logic here: filtering, transformation, authorization
  return {
    action:
      "ALLOW", // or "DENY"
    data: enrichedData, // optional transformation
  };
}

// Handles subscribe events (when clients subscribe)
export function onSubscribe(
  ctx,
) {
  const {
    channelName,
  } =
    ctx.args;
  const {
    identity,
  } =
    ctx;

  // Your logic here: authorization, access control
  return {
    action:
      "ALLOW", // or "DENY"
  };
}
```

**Recommendations:**

1. **Use `file()` for external handlers:**

   ```hcl
   code_handlers = file("${path.module}/handlers/chat.js")
   ```

2. **Organize handlers by namespace:**

   ```
   handlers/
   ├── chat.js
   ├── notifications.js
   └── presence.js
   ```

3. **Keep handlers lightweight:**
   - Complex logic → Use Lambda datasources
   - External API calls → Use Lambda
   - Database operations → Use Lambda

4. **Runtime Environment:**
   - Language: JavaScript (ES6+)
   - Runtime: APPSYNC_JS 1.0.0
   - Timeout: 30 seconds max
   - Stateless execution

See [examples/event-api-complete/handlers/](./examples/event-api-complete/handlers/) for production-ready handler examples.

#### GraphQL vs Event API: When to Use Each

**Use GraphQL API when:**

- ✅ You need flexible data querying (queries, mutations)
- ✅ Your data has complex relationships and nested structures
- ✅ You want strongly-typed schema with introspection
- ✅ You need field-level authorization
- ✅ Your use case is data-centric (CRUD operations)

**Use Event API when:**

- ✅ You need real-time pub/sub messaging
- ✅ Your use case is event-driven (chat, notifications, presence)
- ✅ You want lightweight WebSocket connections
- ✅ You need channel-based communication
- ✅ Your use case is message-centric (broadcasting, notifications)

**Feature Comparison:**

| Feature                   | GraphQL API                     | Event API                                    |
| ------------------------- | ------------------------------- | -------------------------------------------- |
| **Primary Use Case**      | Data querying & manipulation    | Real-time pub/sub messaging                  |
| **Protocol**              | HTTP, WebSocket (subscriptions) | WebSocket, HTTP (publishing)                 |
| **Communication Pattern** | Request-response, Subscriptions | Pub/Sub channels                             |
| **Schema**                | GraphQL schema required         | No schema required                           |
| **Data Structure**        | Strongly-typed, hierarchical    | Flexible JSON events                         |
| **Authorization**         | Field-level, type-level         | Channel-level, message-level                 |
| **Resolvers**             | VTL or JavaScript resolvers     | JavaScript handlers (onPublish, onSubscribe) |
| **Datasources**           | Multiple types supported        | Lambda, HTTP                                 |
| **X-Ray Tracing**         | ✅ Supported                    | ❌ Not supported                             |
| **CloudWatch Logs**       | ✅ Supported                    | ✅ Supported                                 |
| **Custom Domains**        | ✅ Supported                    | ✅ Supported                                 |

**Can you use both together?**

GraphQL and Event APIs are **mutually exclusive** within a single module instance. The module enforces this with a Terraform `precondition` that will fail `terraform plan` if both `create_graphql_api = true` and `create_websocket_api = true` are set simultaneously.

To use both API types, create **separate module instances**:

```hcl
# GraphQL API instance
module "appsync_graphql" {
  source = "terraform-aws-modules/appsync/aws"

  create_graphql_api = true  # default
  name               = "my-graphql-api"
  schema             = file("schema.graphql")
  # ... GraphQL-specific configuration
}

# Event API instance
module "appsync_event" {
  source = "terraform-aws-modules/appsync/aws"

  create_graphql_api   = false
  create_websocket_api = true
  name                 = "my-event-api"
  event_config         = { /* ... */ }
  # ... Event API-specific configuration
}
```

> **Note:** The mutual exclusivity is enforced by a `null_resource.validate_api_mutual_exclusivity` precondition in `main.tf`. Attempting to set both flags to `true` will produce the error: _"Cannot enable both GraphQL and Event APIs in the same module instance."_

**Common Use Cases:**

- **GraphQL API:** REST API replacement, mobile/web app backend, data aggregation layer
- **Event API:** Chat applications, real-time notifications, user presence, live updates, IoT messaging

#### Limitations

**Event API Specific:**

- ❌ X-Ray tracing not supported (`xray_enabled` only applies to GraphQL APIs)
- ❌ Enhanced metrics configuration not supported for Event APIs
- ❌ Cannot use VTL resolvers (JavaScript handlers only)

**Shared CloudWatch Logs:**

- Both GraphQL and Event APIs can share the same CloudWatch Logs IAM role
- Use `logging_enabled = true` and `create_logs_role = true` for automatic setup

#### Complete Event API Example

See [examples/event-api-complete/](./examples/event-api-complete/) for a full-featured example demonstrating:

- All authentication types (API_KEY, IAM, Cognito, OIDC, Lambda)
- Multiple channel namespaces (chat, notifications, presence)
- JavaScript and Lambda handlers
- CloudWatch Logs integration
- Custom domain association
- Production-ready handler patterns

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.28 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.28 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appsync_api.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_api) | resource |
| [aws_appsync_api_cache.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_api_cache) | resource |
| [aws_appsync_api_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_api_key) | resource |
| [aws_appsync_channel_namespace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_channel_namespace) | resource |
| [aws_appsync_datasource.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_datasource) | resource |
| [aws_appsync_domain_name.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_domain_name) | resource |
| [aws_appsync_domain_name_api_association.event](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_domain_name_api_association) | resource |
| [aws_appsync_domain_name_api_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_domain_name_api_association) | resource |
| [aws_appsync_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_function) | resource |
| [aws_appsync_graphql_api.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_graphql_api) | resource |
| [aws_appsync_resolver.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_resolver) | resource |
| [aws_iam_role.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [null_resource.validate_api_mutual_exclusivity](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.validate_event_api_datasources](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.service_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_auth_providers"></a> [additional\_auth\_providers](#input\_additional\_auth\_providers) | Additional auth providers for the Event API, beyond the primary auth\_provider.<br/><br/>Use this to register extra auth types (e.g. API\_KEY alongside AWS\_LAMBDA) so they can<br/>be referenced in connection\_auth\_modes, default\_publish\_auth\_modes,<br/>default\_subscribe\_auth\_modes, or channel namespace publish/subscribe auth overrides.<br/><br/>Each auth type used anywhere in the event\_config or channel\_namespaces MUST appear in<br/>either auth\_provider or additional\_auth\_providers.<br/><br/>Example - API\_KEY publish + AWS\_LAMBDA subscribe:<br/>  additional\_auth\_providers = [<br/>    { auth\_type = "API\_KEY" }<br/>  ] | <pre>list(object({<br/>    auth_type = string<br/>  }))</pre> | `[]` | no |
| <a name="input_additional_authentication_provider"></a> [additional\_authentication\_provider](#input\_additional\_authentication\_provider) | One or more additional authentication providers for the GraphqlApi. | `any` | `{}` | no |
| <a name="input_api_keys"></a> [api\_keys](#input\_api\_keys) | Map of API keys to create | `map(string)` | `{}` | no |
| <a name="input_authentication_type"></a> [authentication\_type](#input\_authentication\_type) | The authentication type to use by Service Deployment | `string` | `"API_KEY"` | no |
| <a name="input_cache_at_rest_encryption_enabled"></a> [cache\_at\_rest\_encryption\_enabled](#input\_cache\_at\_rest\_encryption\_enabled) | At-rest encryption flag for cache. | `bool` | `false` | no |
| <a name="input_cache_transit_encryption_enabled"></a> [cache\_transit\_encryption\_enabled](#input\_cache\_transit\_encryption\_enabled) | Transit encryption flag when connecting to cache. | `bool` | `false` | no |
| <a name="input_cache_ttl"></a> [cache\_ttl](#input\_cache\_ttl) | TTL in seconds for cache entries | `number` | `1` | no |
| <a name="input_cache_type"></a> [cache\_type](#input\_cache\_type) | The cache instance type. | `string` | `"SMALL"` | no |
| <a name="input_caching_behavior"></a> [caching\_behavior](#input\_caching\_behavior) | Caching behavior. | `string` | `"FULL_REQUEST_CACHING"` | no |
| <a name="input_caching_enabled"></a> [caching\_enabled](#input\_caching\_enabled) | Whether caching with Elasticache is enabled. | `bool` | `false` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | The Amazon Resource Name (ARN) of the certificate. | `string` | `""` | no |
| <a name="input_channel_namespaces"></a> [channel\_namespaces](#input\_channel\_namespaces) | NOTE: Handlers (code\_handlers and handler\_configs) are optional. When no handlers are<br/>specified, AWS provides default handlers that approve all publish and subscribe operations.<br/>See: https://docs.aws.amazon.com/appsync/latest/eventapi/event-handlers-overview.html<br/><br/>Map of channel namespace configurations for Event APIs. Key is the namespace name.<br/><br/>Channel namespaces organize pub/sub channels and define event handlers for message processing.<br/>Each namespace can have different authentication, handlers, and behavior.<br/><br/>Handler Options:<br/>1. code\_handlers: JavaScript code (inline or file path) for event processing<br/>   - Runtime: APPSYNC\_JS version 1.0.0 (always, implicit)<br/>   - Language: JavaScript (not VTL)<br/>   - Functions: export function onPublish(ctx) {} and onSubscribe(ctx) {}<br/>   - Example: file("handlers/channel.js") or inline code string<br/><br/>2. handler\_configs: Lambda datasource integrations for publish/subscribe events<br/>   - on\_publish: Lambda invoked when messages are published<br/>   - on\_subscribe: Lambda invoked when clients subscribe<br/>   - Requires datasource configured in var.datasources<br/>   - Behavior: "CODE" (JavaScript) or "DIRECT" (datasource bypass)<br/><br/>Authentication Modes:<br/>- publish\_auth\_modes: Override default\_publish\_auth\_modes for this namespace<br/>- subscribe\_auth\_modes: Override default\_subscribe\_auth\_modes for this namespace<br/>- Valid auth types: API\_KEY, AWS\_IAM, AMAZON\_COGNITO\_USER\_POOLS, OPENID\_CONNECT, AWS\_LAMBDA<br/><br/>Example - JavaScript Handlers (Recommended for most use cases):<br/>  channel\_namespaces = {<br/>    "chat/rooms" = {<br/>      code\_handlers = file("${path.module}/handlers/chat.js")<br/>      publish\_auth\_modes = [<br/>        { auth\_type = "AMAZON\_COGNITO\_USER\_POOLS" }<br/>      ]<br/>      subscribe\_auth\_modes = [<br/>        { auth\_type = "AMAZON\_COGNITO\_USER\_POOLS" }<br/>      ]<br/>    }<br/>  }<br/><br/>Example - Lambda Integration (For complex business logic):<br/>  channel\_namespaces = {<br/>    "notifications/user" = {<br/>      handler\_configs = {<br/>        on\_publish = {<br/>          behavior = "DIRECT"<br/>          integration = {<br/>            data\_source\_name = "notification\_processor"<br/>            lambda\_config = {<br/>              invoke\_type = "REQUEST\_RESPONSE"<br/>            }<br/>          }<br/>        }<br/>      }<br/>    }<br/>  }<br/><br/>Example - Multiple Namespaces:<br/>  channel\_namespaces = {<br/>    "chat/rooms" = {<br/>      code\_handlers = file("handlers/chat.js")<br/>    }<br/>    "presence/users" = {<br/>      code\_handlers = file("handlers/presence.js")<br/>    }<br/>    "notifications/system" = {<br/>      handler\_configs = {<br/>        on\_publish = {<br/>          behavior = "DIRECT"<br/>          integration = {<br/>            data\_source\_name = "notification\_lambda"<br/>          }<br/>        }<br/>      }<br/>      publish\_auth\_modes = [{ auth\_type = "AWS\_IAM" }]<br/>    }<br/>  }<br/><br/>Handler Code Structure (JavaScript):<br/>  export function onPublish(ctx) {<br/>    // ctx.args.data: published message data<br/>    // ctx.identity: authenticated user information<br/>    // ctx.info: metadata (channelNamespace, channelName)<br/>    // Return: { action: "ALLOW"\|"DENY", data: {...}, reason: "..." }<br/>  }<br/><br/>  export function onSubscribe(ctx) {<br/>    // Validate subscription authorization<br/>    // Return: { action: "ALLOW"\|"DENY", reason: "..." }<br/>  }<br/><br/>Security Best Practices:<br/>- Use JavaScript handlers for message validation and filtering<br/>- Implement rate limiting in handler code<br/>- Validate user permissions before allowing publish/subscribe<br/>- Use channel-specific authentication modes for sensitive data<br/>- Keep handler code lightweight (< 50ms execution time)<br/>- Use Lambda for complex business logic (> 50ms)<br/>- Always return explicit ALLOW/DENY actions in handlers | <pre>map(object({<br/>    # JavaScript code handlers (string: file path or inline code)<br/>    code_handlers = optional(string)<br/><br/>    # Lambda integration handlers<br/>    handler_configs = optional(object({<br/>      on_publish = optional(object({<br/>        behavior = string # "CODE" (JavaScript) or "DIRECT" (datasource)<br/>        integration = optional(object({<br/>          data_source_name = string<br/>          lambda_config = optional(object({<br/>            invoke_type = optional(string) # "REQUEST_RESPONSE" or "EVENT"<br/>          }))<br/>        }))<br/>      }))<br/>      on_subscribe = optional(object({<br/>        behavior = string # "CODE" (JavaScript) or "DIRECT" (datasource)<br/>        integration = optional(object({<br/>          data_source_name = string<br/>          lambda_config = optional(object({<br/>            invoke_type = optional(string)<br/>          }))<br/>        }))<br/>      }))<br/>    }))<br/><br/>    # Publish authentication modes for this channel namespace<br/>    publish_auth_modes = optional(list(object({<br/>      auth_type = string<br/>    })), [])<br/><br/>    # Subscribe authentication modes for this channel namespace<br/>    subscribe_auth_modes = optional(list(object({<br/>      auth_type = string<br/>    })), [])<br/><br/>    # Tags specific to this channel namespace<br/>    tags = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_create_event_api"></a> [create\_event\_api](#input\_create\_event\_api) | Whether to create an Event API for real-time pub/sub messaging.<br/><br/>Mutually exclusive with create\_graphql\_api - set only one to true.<br/><br/>Event APIs enable:<br/>- Real-time Event API connections<br/>- Channel-based pub/sub messaging<br/>- JavaScript handlers for message processing<br/>- Event-driven architectures (chat, notifications, presence)<br/><br/>Example:<br/>  create\_event\_api   = true<br/>  create\_graphql\_api = false<br/><br/>Security Note: Always configure authentication via event\_config when true. | `bool` | `false` | no |
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
| <a name="input_event_config"></a> [event\_config](#input\_event\_config) | Event API authentication configuration. Required when create\_event\_api is true.<br/><br/>Authentication Types (auth\_provider.auth\_type):<br/>- API\_KEY: Simple API key authentication (default, least secure, good for development)<br/>- AWS\_IAM: IAM-based authentication using SigV4 (secure, good for service-to-service)<br/>- AMAZON\_COGNITO\_USER\_POOLS: Cognito User Pools (secure, good for user authentication)<br/>- OPENID\_CONNECT: OIDC authentication (secure, good for federated identity)<br/>- AWS\_LAMBDA: Custom Lambda authorizer (flexible, custom validation logic)<br/><br/>Authentication Scopes:<br/>- connection\_auth\_modes: Authenticate Event API connection establishment<br/>- default\_publish\_auth\_modes: Authenticate publishing events to channels<br/>- default\_subscribe\_auth\_modes: Authenticate subscribing to channels<br/><br/>Example - API Key (Development):<br/>  event\_config = {<br/>    auth\_provider = {<br/>      auth\_type = "API\_KEY"<br/>    }<br/>    connection\_auth\_modes        = [{ auth\_type = "API\_KEY" }]<br/>    default\_publish\_auth\_modes   = [{ auth\_type = "API\_KEY" }]<br/>    default\_subscribe\_auth\_modes = [{ auth\_type = "API\_KEY" }]<br/>  }<br/><br/>Example - Cognito (Production):<br/>  event\_config = {<br/>    auth\_provider = {<br/>      auth\_type = "AMAZON\_COGNITO\_USER\_POOLS"<br/>      cognito\_config = {<br/>        user\_pool\_id = "us-east-1\_ABC123"<br/>        aws\_region   = "us-east-1"<br/>      }<br/>    }<br/>    connection\_auth\_modes        = [{ auth\_type = "AMAZON\_COGNITO\_USER\_POOLS" }]<br/>    default\_publish\_auth\_modes   = [{ auth\_type = "AMAZON\_COGNITO\_USER\_POOLS" }]<br/>    default\_subscribe\_auth\_modes = [{ auth\_type = "AMAZON\_COGNITO\_USER\_POOLS" }]<br/>  }<br/><br/>Example - Lambda Authorizer (Custom Logic):<br/>  event\_config = {<br/>    auth\_provider = {<br/>      auth\_type = "AWS\_LAMBDA"<br/>      lambda\_authorizer\_config = {<br/>        authorizer\_uri                   = "arn:aws:lambda:us-east-1:123456789012:function:authorizer"<br/>        authorizer\_result\_ttl\_in\_seconds = 300<br/>      }<br/>    }<br/>    connection\_auth\_modes        = [{ auth\_type = "AWS\_LAMBDA" }]<br/>    default\_publish\_auth\_modes   = [{ auth\_type = "AWS\_LAMBDA" }]<br/>    default\_subscribe\_auth\_modes = [{ auth\_type = "AWS\_LAMBDA" }]<br/>  }<br/><br/>Security Best Practices:<br/>- Use IAM, Cognito, OIDC, or Lambda for production (not API\_KEY)<br/>- Configure different auth modes for connect/publish/subscribe as needed<br/>- Set authorizer\_result\_ttl\_in\_seconds appropriately for Lambda (default 300s)<br/>- Validate tokens in handler code for additional security<br/>- Use AWS\_IAM for service-to-service communication | <pre>object({<br/>    auth_provider = object({<br/>      auth_type = string<br/><br/>      # Optional: Cognito configuration (required when auth_type is AMAZON_COGNITO_USER_POOLS)<br/>      cognito_config = optional(object({<br/>        user_pool_id        = string<br/>        aws_region          = string<br/>        app_id_client_regex = optional(string)<br/>      }))<br/><br/>      # Optional: Lambda authorizer configuration (required when auth_type is AWS_LAMBDA)<br/>      lambda_authorizer_config = optional(object({<br/>        authorizer_uri                   = string<br/>        authorizer_result_ttl_in_seconds = optional(number)<br/>        identity_validation_expression   = optional(string)<br/>      }))<br/><br/>      # Optional: OIDC configuration (required when auth_type is OPENID_CONNECT)<br/>      oidc_config = optional(object({<br/>        issuer    = string<br/>        client_id = optional(string)<br/>        auth_ttl  = optional(number)<br/>        iat_ttl   = optional(number)<br/>      }))<br/>    })<br/><br/>    # Authentication modes for Event API connection establishment<br/>    connection_auth_modes = list(object({<br/>      auth_type = string<br/>    }))<br/><br/>    # Default authentication modes for publishing events to channels<br/>    default_publish_auth_modes = list(object({<br/>      auth_type = string<br/>    }))<br/><br/>    # Default authentication modes for subscribing to channels<br/>    default_subscribe_auth_modes = list(object({<br/>      auth_type = string<br/>    }))<br/>  })</pre> | `null` | no |
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
| <a name="output_channel_namespace_arns"></a> [channel\_namespace\_arns](#output\_channel\_namespace\_arns) | Map of channel namespace ARNs keyed by namespace name. Returns empty map when no channel namespaces are configured. |
| <a name="output_event_api_arn"></a> [event\_api\_arn](#output\_event\_api\_arn) | ARN of Event API |
| <a name="output_event_api_custom_domain_name"></a> [event\_api\_custom\_domain\_name](#output\_event\_api\_custom\_domain\_name) | The domain name associated with the Event API. Returns the AppSync-provided domain name when Event API domain association is enabled. Use this value to configure DNS records (CNAME or ALIAS) pointing your custom domain to the AppSync endpoint. |
| <a name="output_event_api_endpoint"></a> [event\_api\_endpoint](#output\_event\_api\_endpoint) | Event API endpoint URL |
| <a name="output_event_api_id"></a> [event\_api\_id](#output\_event\_api\_id) | ID of Event API |
<!-- END_TF_DOCS -->

## Authors

Module managed by [Anton Babenko](https://github.com/antonbabenko). Check out [serverless.tf](https://serverless.tf) to learn more about doing serverless with Terraform.

Please reach out to [Betajob](https://www.betajob.com/) if you are looking for commercial support for your Terraform, AWS, or serverless project.

## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-appsync/tree/master/LICENSE) for full details.
